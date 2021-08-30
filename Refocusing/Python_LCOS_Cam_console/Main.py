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

        # SLM Display
        self.label = QtWidgets.QLabel()  # 创建显示图窗
        self.SLM_scene = QtWidgets.QGraphicsScene()  # 控制台 scene
        self.SLM_Init()

        self.Hologram = np.random.randint(254, 255, [200, 200], np.uint8)  # initial
        self.HologramPositionTop = int(self.Top_spinBox.value())
        self.HologramPositionLeft = int(self.Left_spinBox.value())

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
        Iteration = 0  # 迭代计数器
        runtime_start = time.time()  # 运行时间起始点

        # 迭代阀值，当两次迭代损失函数之差小于该阀值时停止迭代
        epsilon = 4
        f_lens = 250#-1 / 22  # mm
        w_slm = 200e-6
        width_Hologram = 200
        x = np.arange(-width_Hologram, width_Hologram)
        y = np.arange(-width_Hologram, width_Hologram)
        X, Y = np.meshgrid(x, y)  # 2生成绘制3D图形所需的网络数据
        R = (X ** 2 + Y ** 2) ** 0.5

        while self.auto_flag == 1:
            # # time
            # self.time = time.time()
            # print('Time cost = %fs' % (time.time() - self.time))

            # 窗口实施刷新，后台计算不影响界面刷新
            QtWidgets.QApplication.processEvents()
            # 迭代次数限制自动退出 及 刷新显示
            if Iteration > 2:
                self.End_clicked()
                break
            Iteration = Iteration + 1
            self.Iteration_lineEdit.setText(str(Iteration))
            # 运行时间计算 及 刷新显示
            runtime = time.time() - runtime_start
            hour = int(runtime // 3600)
            minute = int((runtime - hour * 3600) // 60)
            sec = int((runtime - hour * 3600 - minute * 60))
            self.RunTime_lineEdit.setText(str(hour).zfill(2) + ":" + str(minute).zfill(2) + ":" + str(sec).zfill(2))

            # 算法部分 计算 Hologram
            # f_lens=f_lens/1e3
            output_phase = np.angle(np.exp(1j / 2 / f_lens * R ** 2)) + np.pi
            m1 = 0.0205
            m2 = 2.4219
            m_phase = np.arange(0, 256) / 255 * (m2 - m1) + m1
            # m_phase = np.arange(0, 256) / 255 * 2 * np.pi
            m_grey = np.arange(0, 256)
            m_bitmap = np.uint8(np.interp(output_phase, m_phase, m_grey))

            # 1、更新hologram
            self.Hologram = m_bitmap
            # self.Hologram = self.Hologram_Auto_genaration()
            # 2、更新全息图位置参数和SLM显示器
            self.SLM_display()
            # 窗口实施刷新，后台计算不影响界面刷新
            QtWidgets.QApplication.processEvents()
            # 3、刷新相机，更新相机目标区域的值 self.last_aim_value
            time1 = time.time()
            for i in range(8):
                self.Cam_display()
                # 窗口实施刷新，后台计算不影响界面刷新
                QtWidgets.QApplication.processEvents()
            print('Time cost = %fs' % (time.time() - time1))

            f_lens = f_lens / 100

    def End_clicked(self):
        self.auto_flag = 0
        self.timer_camera.start(50)  # 开启自动程序计时器ms，顺序刷新取值

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
