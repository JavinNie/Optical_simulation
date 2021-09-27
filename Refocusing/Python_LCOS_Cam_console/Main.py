import sys

from PyQt5 import QtGui, QtCore
from PyQt5.QtGui import QPalette, QColor
from PyQt5.QtWidgets import QApplication, QWidget, QFileDialog
from PyQt5 import QtWidgets
import numpy as np
import PySpin
import cv2
from Mainwindow import Ui_MainWindow
import time
import xlwt


class MainWindow(QtWidgets.QMainWindow, Ui_MainWindow):

    def __init__(self):
        super(MainWindow, self).__init__()  # 父类构造函数，可以调用父类的属性
        self.setupUi(self)
        # QtWidgets调色板
        self.palet = QPalette()
        self.palet.setColor(QPalette.Background, QColor(248, 248, 248))
        self.setPalette(self.palet)

        # 自动算法初始标志
        self.initial_flag = 1
        # 进入
        # Auto状态标志
        self.auto_flag = 0

        # 定时器
        self.timer_camera = QtCore.QTimer()  # 定义定时器，用于控制显示视频的帧率
        self.time = time.time()

        # Camera ini&setting
        self.system = PySpin.System.GetInstance()
        self.cam_list = self.system.GetCameras()
        self.cam = self.cam_list[0]
        self.cam.Init()
        self.cam_setting()

        # cam display
        self.cam_scene = QtWidgets.QGraphicsScene()
        self.cam_image = self.cam_acquisition()

        self.position_left = self.Aim_hor_spinBox.value()
        self.position_top = self.Aim_ver_spinBox.value()
        self.scale = self.Aim_Scale_spinBox.value()
        self.last_aim_value = self.cam_image[self.position_top][self.position_left]
        self.Max_aim_value = -1

        # SLM Display
        self.label = QtWidgets.QLabel()  # 创建显示图窗
        self.SLM_scene = QtWidgets.QGraphicsScene()  # 控制台 scene
        self.SLM_Init()

        self.Hologram = np.random.randint(254, 255, [200, 200], np.uint8)  # initial
        self.HologramPositionTop = int(self.Top_spinBox.value())
        self.HologramPositionLeft = int(self.Left_spinBox.value())

        self.Max_Hologram = self.Hologram

        # Slot bound
        self.Slot_bound()
        # Auto之后必然是自定义自动刷新的函数Auto_clicked(),这里为了简单显示效果采取调用显示接口的函数，
        # 实际上显示接口应该只是一部分, 还有更新全息图，更新显示以及，获取相机值的作用

        # self.Clear_pushButton.clicked.connect(self.Clear_clicked)

    def Slot_bound(self):
        # Exposure & Gain bounding
        self.Exposure_horizontalSlider.valueChanged.connect(
            lambda: self.Exposure_spinBox.setValue(self.Exposure_horizontalSlider.value()))  # 滑块的connect
        self.Exposure_spinBox.valueChanged.connect(
            lambda: self.Exposure_horizontalSlider.setValue(self.Exposure_spinBox.value()))  # 微调框的connect
        self.Gain_horizontalSlider.valueChanged.connect(
            lambda: self.Gain_doubleSpinBox.setValue(float(self.Gain_horizontalSlider.value()) / 10))  # 滑块的connect
        self.Gain_doubleSpinBox.valueChanged.connect(
            lambda: self.Gain_horizontalSlider.setValue(int(self.Gain_doubleSpinBox.value() * 10)))  # 微调框的connect

        # camera setting
        self.Gain_doubleSpinBox.valueChanged.connect(self.cam_Gain_setting)
        self.Exposure_spinBox.valueChanged.connect(self.cam_Exposure_setting)

        # camera display
        self.timer_camera.timeout.connect(self.Cam_display)  # 若定时器结束，则调用Cam_display()

        self.Mark_pushButton.clicked.connect(self.Aim_area_update)

        # bitmap
        self.bitmap_pushButton.clicked.connect(self.bitmap_clicked)
        # clear
        self.Clear_pushButton.clicked.connect(self.clear_clicked)
        # Auto
        self.Auto_pushButton.clicked.connect(self.Auto_clicked)
        # End
        self.End_pushButton.clicked.connect(self.End_clicked)
        # Save
        self.Save_pushButton.clicked.connect(self.Save_clicked)

    def SLM_Init(self):
        desktop = QtWidgets.QApplication.desktop()
        self.label.setGeometry(desktop.screenGeometry(1))  # 副屏显示
        self.label.show()  # 开始显示，最小显示
        self.label.showFullScreen()  # 全屏显示 label.width(), label.height()=3840*2160

    #     可以把图片和位置都换成调用其他的函数，因为输入是从窗口输入，图片是程序生成的
    def cam_Gain_setting(self):
        # Ensure desired Gain value does not exceed the maximum
        gain_to_set = min(self.cam.Gain.GetMax(), self.Gain_doubleSpinBox.value())
        self.cam.Gain.SetValue(gain_to_set)

    def cam_Exposure_setting(self):
        exposure_time_to_set = min(self.cam.ExposureTime.GetMax(), self.Exposure_spinBox.value() * 100)
        self.cam.ExposureTime.SetValue(exposure_time_to_set)
        # print('MAXShutter time set to %s us...\n' % cam.ExposureTime.GetMax())

    def cam_release(self):
        self.timer_camera.stop()  # 关闭定时器
        self.cam.DeInit()
        del self.cam
        self.cam_list.Clear()
        self.system.ReleaseInstance()

    def cam_acquisition(self):
        # exposure_time_to_set = min(self.cam.ExposureTime.GetMax(), self.Exposure_spinBox.value() * 100)
        # self.cam.ExposureTime.SetValue(exposure_time_to_set)
        # # print('MAXShutter time set to %s us...\n' % cam.ExposureTime.GetMax())
        #
        # # Ensure desired Gain value does not exceed the maximum
        # gain_to_set = min(self.cam.Gain.GetMax(), self.Gain_doubleSpinBox.value())
        # self.cam.Gain.SetValue(gain_to_set)
        #
        # get image
        image_result = self.cam.GetNextImage(1000).GetNDArray()

        return image_result

    def cam_setting(self):
        nodemap = self.cam.GetNodeMap()
        nodemap_tldevice = self.cam.GetTLDeviceNodeMap()

        sNodemap = self.cam.GetTLStreamNodeMap()
        # Change bufferhandling mode to NewestOnly
        node_bufferhandling_mode = PySpin.CEnumerationPtr(sNodemap.GetNode('StreamBufferHandlingMode'))
        # Retrieve entry node from enumeration node
        node_newestonly = node_bufferhandling_mode.GetEntryByName('NewestOnly')
        # Retrieve integer value from entry node
        node_newestonly_mode = node_newestonly.GetValue()
        # Set integer value from entry node as new value of enumeration node
        node_bufferhandling_mode.SetIntValue(node_newestonly_mode)

        # image Acquisition
        node_acquisition_mode = PySpin.CEnumerationPtr(nodemap.GetNode('AcquisitionMode'))
        # Retrieve entry node from enumeration node
        node_acquisition_mode_continuous = node_acquisition_mode.GetEntryByName('Continuous')
        # Retrieve integer value from entry node
        acquisition_mode_continuous = node_acquisition_mode_continuous.GetValue()
        # Set integer value from entry node as new value of enumeration node
        node_acquisition_mode.SetIntValue(acquisition_mode_continuous)
        print('Acquisition mode set to continuous...')

        # auto mode close
        self.cam.GainAuto.SetValue(PySpin.GainAuto_Off)
        self.cam.ExposureAuto.SetValue(PySpin.ExposureAuto_Off)

        #  Image acquisition must be ended when no more images are needed.
        self.cam.BeginAcquisition()

        #  Retrieve device serial number for filename
        node_device_serial_number = PySpin.CStringPtr(nodemap_tldevice.GetNode('DeviceSerialNumber'))
        if PySpin.IsAvailable(node_device_serial_number) and PySpin.IsReadable(node_device_serial_number):
            device_serial_number = node_device_serial_number.GetValue()
            print('Device serial number retrieved as %s...' % device_serial_number)

        self.timer_camera.start(40)  # 定时器开始计时30ms，结果是每过30ms从摄像头中取一帧显示
        print('timer_camera start ...')
        # if self.timer_camera.isActive() == False:  # 若定时器未启动
        num_cameras = self.cam_list.GetSize()
        if num_cameras == 0:  # 没有相机
            msg = QtWidgets.QMessageBox.warning(self, 'warning', "请检查相机于电脑是否连接正确",
                                                buttons=QtWidgets.QMessageBox.Ok)

        # camera display setting
        self.Camera.setAlignment(QtCore.Qt.AlignLeft | QtCore.Qt.AlignTop)
        self.Camera.setSceneRect(0, 0, self.Camera.viewport().width(),
                                 self.Camera.viewport().height())  # 设置图形场景大小和图形视图大小一致

    def Cam_display(self):

        # aim area
        '''
        获取设定的目标区域，计算目标值
        标记目标区域用于交互
        '''
        # 目标区域的中心坐标及大小
        # position_left = self.Aim_hor_spinBox.value()
        # position_top = self.Aim_ver_spinBox.value()
        # scale = self.Aim_Scale_spinBox.value()
        position_left = self.position_left
        position_top = self.position_top
        scale = self.scale

        # 目标区域的 mean value, H代表水平方向上，即横坐标，x坐标，left坐标，V代表垂直方向上，即纵坐标，y坐标，top坐标
        Hmin = np.clip(position_left - scale, 0, self.cam_image.shape[1] - 1)
        Hmax = np.clip(position_left + scale, 1, self.cam_image.shape[1])
        Vmin = np.clip(position_top - scale, 0, self.cam_image.shape[0] - 1)
        Vmax = np.clip(position_top + scale, 1, self.cam_image.shape[0])
        # 计算目标区域的值
        aim_area_value = int(np.mean(
            self.cam_image[Vmin:Vmax, Hmin:Hmax]))
        if self.initial_flag == 1:
            self.Initial_lineEdit.setText(str(aim_area_value))
            self.initial_flag = 0
        # 更新窗口值
        self.Latest_lineEdit.setText(str(aim_area_value))  # 最新值
        self.Promotion_lineEdit.setText(str(int(aim_area_value) - int(self.last_aim_value)))  # 提升值
        self.last_aim_value = aim_area_value

        # # time
        # print('Time cost = %fs' % (time.time() - self.time))
        # self.time = time.time()

        '''
        显示相机图片部分
        '''
        # 将图片转换成彩色格式
        jet_image = self.Cam_gray2color()
        # 添加标记窗口
        cv2.rectangle(jet_image, (Hmin, Vmin), (Hmax, Vmax), (255, 255, 255), 3)
        image = QtGui.QImage(jet_image.data, jet_image.shape[1], jet_image.shape[0], jet_image.shape[1] * 3,
                             QtGui.QImage.Format_RGB888)
        # image.save("cam_Qimage.jpg","JPG", 100)

        self.cam_scene.clear()
        # part 2:  update the graphicview in the mainwindow
        PixImg_zoom = QtGui.QPixmap(image).scaled(self.Camera.width(), self.Camera.height())  # 创建像素图pixmap
        item = QtWidgets.QGraphicsPixmapItem(PixImg_zoom)
        self.cam_scene.addItem(item)
        # self.cam_scene.update()
        self.Camera.setScene(self.cam_scene)

    def Cam_gray2color(self):
        self.cam_image = self.cam_acquisition()
        jet_image = cv2.applyColorMap(255 - self.cam_image, cv2.COLORMAP_JET)
        # image = QtGui.QImage(jet_image.data, jet_image.shape[1], jet_image.shape[0], jet_image.shape[1] * 3,
        #                      QtGui.QImage.Format_RGB888)
        # QtWidgets.QApplication.processEvents()
        return jet_image

    def Aim_area_update(self):
        self.position_left = self.Aim_hor_spinBox.value()
        self.position_top = self.Aim_ver_spinBox.value()
        self.scale = self.Aim_Scale_spinBox.value()
        return

    def bitmap_clicked(self):
        # 1、更新SLM显示器
        self.Hologram = self.openimage()  # np.random.randint(254, 255, [200, 200], np.uint8)
        self.SLM_display()
        # 是不是停止SLM，根据open的情况

    def openimage(self):
        imgName, imgType = QFileDialog.getOpenFileName(self, "打开图片", "", "*.bmp;;All Files(*)")
        if imgName:  # 打开资源管理器，选择了正确的图片
            img = cv2.imread(imgName)
            img = img[:, :, 1]
            self.SLM_position_update()
            self.auto_flag = 0
            # 2、Auto程序清空，关闭自动定时器，开始相机定时器
            self.End_clicked()
        else:  # 打开资源管理器，点了取消
            img = self.Hologram
        return img

    def clear_clicked(self):
        # 1、清空 SLM显示器
        self.Hologram = np.random.randint(254, 255, [200, 200], np.uint8)
        self.SLM_display()
        # 2、Auto程序清空，关闭自动定时器，开始相机定时器
        self.End_clicked()

    def Auto_clicked(self):
        # 开始重新计算初始值
        self.initial_flag = 1

        if self.auto_flag == 0:
            self.auto_flag = 1
            self.timer_camera.stop()  # 关闭相机自动刷新计时器ms
            self.SLM_position_update()  # 全息图位置参数更新

        self.Auto_model()

    def Auto_model(self):
        self.SA_for_flen()

    def SA_for_flen(self):
        Iteration = 0  # 迭代计数器
        runtime_start = time.time()  # 运行时间起始点

        # SA参数设置
        T_init = 500  # 初始最大温度
        alpha = 0.75  # 降温系数
        T_min = 50  # 最小温度，即退出循环条件
        step = 1400  # 随机扰动步长
        scale_upper = 10000
        scale_lower = 0
        search_depth = 15  # 搜索深度
        T = T_init  #

        # 写入excel表格
        workbook = xlwt.Workbook()
        sheet = workbook.add_sheet("Sheet Name1")

        while self.auto_flag == 1:
            # 窗口实施刷新，后台计算不影响界面刷新
            QtWidgets.QApplication.processEvents()

            results = []  # 存x，y
            count = 0
            x = 500  # 初始位置
            self.update_flens(x)  # 更新flens全息图
            y = self.last_aim_value
            while T > T_min:
                x_best = x
                y_best = y  # 设置成这个收敛太快了，令人智熄
                flag = 0  # 用来标识该温度下是否有新值被接受
                # 扰动步长递减
                step = step * T / T_init
                # 每个温度迭代多次，找最优解
                for i in range(search_depth):
                    delta_x = np.random.randn() * step  # 自变量进行扰动
                    # 自变量变化后仍要求在[0,10]之间
                    if scale_lower < (x + delta_x) < scale_upper:
                        x_new = x + delta_x
                    elif scale_lower < (x - delta_x) < scale_upper:
                        x_new = x - delta_x
                    else:
                        x_new = x

                    self.update_flens(x_new)  # 更新flens全息图
                    y_new = self.last_aim_value

                    # 以上为找最大值，要找最小值就把>号变成<
                    if (y_new >= y or np.exp(-(y - y_new) / T) > np.random.rand()):
                        flag = 1  # 有新值被接受
                        x = x_new
                        y = y_new
                        if y > y_best:
                            x_best = x
                            y_best = y

                    print(str(count)+' '+str(y)+' '+str(y_new))
                    count = count + 1
                    # 写入excel表格
                    Iteration = Iteration + 1
                    sheet.write(Iteration, 0, str(x))
                    sheet.write(Iteration, 1, str(y))
                if flag:
                    x = x_best
                    y = y_best
                T *= alpha  # 温度下降
            workbook.save('Lens_Value.xls')
            self.End_clicked()

        #
        #     # 迭代次数限制自动退出 及 刷新显示
        #     if Iteration > 3000:
        #         self.End_clicked()
        #         break
        #     Iteration = Iteration + 1
        #     self.Iteration_lineEdit.setText(str(Iteration))
        #     # 运行时间计算 及 刷新显示
        #     runtime = time.time() - runtime_start
        #     hour = int(runtime // 3600)
        #     minute = int((runtime - hour * 3600) // 60)
        #     sec = int((runtime - hour * 3600 - minute * 60))
        #     self.RunTime_lineEdit.setText(str(hour).zfill(2) + ":" + str(minute).zfill(2) + ":" + str(sec).zfill(2))
        #
        #     # 算法部分 计算 Hologram
        #     f_lens = f_lens + 1
        #
        #     output_phase = np.angle(np.exp(1j / f_lens * R ** 2)) + np.pi
        #     m1 = 0.0205
        #     m2 = 2.4219
        #     m_phase = np.arange(0, 256) / 255 * (m2 - m1) + m1
        #     m_grey = np.arange(0, 256)
        #     m_bitmap = np.uint8(np.interp(output_phase, m_phase, m_grey))
        #     # 更新hologram
        #     self.Hologram = m_bitmap
        #     # 更新值
        #     self.update_cam_value()
        #
        #     # 写入excel表格
        #     sheet.write(Iteration, 0, str(f_lens))
        #     sheet.write(Iteration, 1, str(self.last_aim_value))
        #
        #     if self.last_aim_value > self.Max_aim_value:
        #         self.Max_Hologram = self.Hologram
        #
        # workbook.save('Lens_Value.xls')

    def update_flens(self, f_lens):
        # 图像参数设置
        # f_lens = 200  # 250#-1 / 22  # mm
        width_Hologram = 200
        # 绘图坐标基础
        X, Y = np.meshgrid(np.arange(-width_Hologram, width_Hologram),
                           np.arange(-width_Hologram, width_Hologram))  # 2生成绘制3D图形所需的网络数据
        R = (X ** 2 + Y ** 2) ** 0.5

        output_phase = np.angle(np.exp(1j / f_lens * R ** 2)) + np.pi
        m1 = 0.0205
        m2 = 2.4219
        m_phase = np.arange(0, 256) / 255 * (m2 - m1) + m1
        m_grey = np.arange(0, 256)
        m_bitmap = np.uint8(np.interp(output_phase, m_phase, m_grey))
        # 更新hologram
        self.Hologram = m_bitmap

        self.update_cam_value()  # 获得最新的值

        # if self.last_aim_value >= 230:
        #     self.reset_Cam()

    def reset_Cam(self):
        self.update_cam_value()
        EX_value = self.Exposure_spinBox.value()
        # 曝光值的调节左右侧
        left = 0
        right = EX_value
        # 目标值的上下边界
        upper = 170
        lower = 120
        while not (lower <= self.last_aim_value <= upper):
            if self.last_aim_value > upper:
                EX_value = (left + EX_value) / 2
            elif self.last_aim_value < lower:
                EX_value = (EX_value + right) / 2
            self.Exposure_horizontalSlider.setValue(EX_value)
            self.cam_Exposure_setting()
            self.update_cam_value()

        self.Max_aim_value = self.last_aim_value

    # def update_WF(self):

    def update_cam_value(self):
        # 调用此函数前必须更新 self.Hologram

        # 2、更新全息图位置参数和SLM显示器
        self.SLM_display()
        # 窗口实施刷新，后台计算不影响界面刷新
        QtWidgets.QApplication.processEvents()
        # 3、刷新相机，更新相机目标区域的值 self.last_aim_value
        # self.update_cam_value()
        for i in range(8):
            self.Cam_display()
            # 窗口实施刷新，后台计算不影响界面刷新
            QtWidgets.QApplication.processEvents()

    def End_clicked(self):
        self.auto_flag = 0
        self.timer_camera.start(50)  # 开启自动程序计时器ms，顺序刷新取值

    def Save_clicked(self):
        cv2.imwrite('Max_f.bmp', self.Max_Hologram)

    def SLM_position_update(self):
        self.HologramPositionTop = int(self.Top_spinBox.value())
        self.HologramPositionLeft = int(self.Left_spinBox.value())

    def Hologram_Auto_genaration(self):
        Hologram = np.random.randint(0, 255, [800, 800], np.uint8)
        # f=
        # Hologram
        # 改成遗传算法
        return Hologram

    def SLM_display(self):
        """
        attach the hologram to the background at right position,
        then update the screen and "graphicview" at the same time with the same picture

        :param Hologram:
        :param HologramPositionTop: vertical position
        :param HologramPositionLeft: horizon position
        :return: none
        """
        Hologram = self.Hologram  # np.random.randint(0, 255, [200, 200], np.uint8)
        HologramPositionTop = self.HologramPositionTop  # int(self.Top_spinBox.value())
        HologramPositionLeft = self.HologramPositionLeft  # int(self.Left_spinBox.value())

        # part 1: generate the complete picture with the size of screen, then update the screen

        # 生成背景板
        Final_Hologram = np.random.randint(254, 255, [self.label.height(), self.label.width()], np.uint8)
        # 计算坐标，考虑溢出，
        Start_Point_Left = max(HologramPositionLeft - np.size(Hologram, 1) // 2, 0)
        Start_Point_Top = max(HologramPositionTop - np.size(Hologram, 0) // 2, 0)
        End_Point_Left = min(HologramPositionLeft + np.size(Hologram, 1) - np.size(Hologram, 1) // 2 - 1,
                             self.label.width() - 1)
        End_Point_Top = min(HologramPositionTop + np.size(Hologram, 0) - np.size(Hologram, 0) // 2 - 1,
                            self.label.height() - 1)

        Start_Holo_Left = np.size(Hologram, 1) // 2 - (HologramPositionLeft - Start_Point_Left)
        Start_Holo_Top = np.size(Hologram, 0) // 2 - (HologramPositionTop - Start_Point_Top)
        End_Holo_Left = np.size(Hologram, 1) // 2 + End_Point_Left - HologramPositionLeft
        End_Holo_Top = np.size(Hologram, 0) // 2 + End_Point_Top - HologramPositionTop
        # 组合全息图和背景板
        Final_Hologram[Start_Point_Top:End_Point_Top, Start_Point_Left:End_Point_Left] = Hologram[
                                                                                         Start_Holo_Top:End_Holo_Top,
                                                                                         Start_Holo_Left:End_Holo_Left]
        # 将图片转换成qtgui识别格式
        image = QtGui.QImage(Final_Hologram.data, Final_Hologram.shape[1], Final_Hologram.shape[0],
                             Final_Hologram.shape[1], QtGui.QImage.Format_Grayscale8)
        PixImg = QtGui.QPixmap(image)  # 创建像素图pixmap
        self.label.setPixmap(PixImg)  # Qtlabel显示图片

        # part 2:  update the graphicview in the mainwindow
        PixImg_zoom = QtGui.QPixmap(image).scaled(self.SLM.width(), self.SLM.height())  # 创建像素图pixmap
        item = QtWidgets.QGraphicsPixmapItem(PixImg_zoom)
        # self.SLM_scene = QtWidgets.QGraphicsScene()
        self.SLM_scene.clear()
        self.SLM_scene.addItem(item)
        self.SLM.setAlignment(QtCore.Qt.AlignLeft | QtCore.Qt.AlignTop)
        self.SLM.setSceneRect(0, 0, self.SLM.viewport().width(),
                              self.SLM.viewport().height())  # 设置图形场景大小和图形视图大小一致
        self.SLM.setScene(self.SLM_scene)


if __name__ == '__main__':
    # 创建应用程序和对象
    app = QtWidgets.QApplication(sys.argv)
    slm_control = MainWindow()
    slm_control.setWindowTitle("Auto_SLM_Cam_Console")
    slm_control.show()
    sys.exit(app.exec_())
