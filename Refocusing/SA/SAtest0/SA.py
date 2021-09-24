import matplotlib.pyplot as plt
import math
import random
import xlrd
from scipy import interpolate

"""
函数里面所有以plot开头的函数都可以注释掉，没有影响
求解的目标表达式为：
y = 10 * math.sin(5 * x) + 7 * math.cos(4 * x)  x belongs to (0,10)
"""


# https://blog.csdn.net/hiudawn/article/details/80156567?utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-5.no_search_link&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-5.no_search_link

def main():
    # 打开文件
    xlsx = xlrd.open_workbook('Lens_Value.xls')
    sheet1 = xlsx.sheets()[0]  # 获得第1张sheet，索引从0开始
    F = sheet1.col_values(0)  # 获得第1列数据
    Pvalue = sheet1.col_values(1)  # 获得第2列数据
    func = interpolate.interp1d(F, Pvalue, 'nearest')

    plt.ion()
    # # 原始数据集
    # plt.plot(F, Pvalue)
    # plt.show()

    T_init = 1000  # 初始最大温度
    alpha = 0.9  # 降温系数
    T_min = 150  # 最小温度，即退出循环条件
    T = T_init
    step=1400

    x = random.random() * len(F)+min(F)  # 初始化x，在0和3000之间v

    # f是一个函数，用这个函数就可以找插值点的函数值了：
    y = func(x)
    results = []  # 存x，y

    count = 0
    while T > T_min:
        x_best = x
        # y_best = float('-inf')  # 设置成这个有可能会陷入局部最优，不一定全局最优
        y_best = y  # 设置成这个收敛太快了，令人智熄
        flag = 0  # 用来标识该温度下是否有新值被接受
        # 每个温度迭代50次，找最优解
        for i in range(20):
            delta_x = (random.random() - 0.5)* step  # 自变量进行波动
            # 自变量变化后仍要求在[0,10]之间
            if min(F) < (x + delta_x) < len(F)+min(F):
                x_new = x + delta_x
            elif min(F) < (x - delta_x) < len(F)+min(F):
                x_new = x - delta_x
            else:
                x_new = x

            y_new = func(x_new)

            # 以上为找最大值，要找最小值就把>号变成<
            if (y_new > y or math.exp(-(y - y_new) / T) > random.random()):
                flag = 1  # 有新值被接受
                x = x_new
                y = y_new
                if y > y_best:
                    x_best = x
                    y_best = y
                # print(str(count)+' '+str(y)+' '+str(y_new))
            print(str(count))
            count = count + 1
        if flag:
            x = x_best
            y = y_best
        results.append((x, y))
        T *= alpha

    print('最优解 x:%f,y:%f' % results[-1])

    plot_final_result(results)
    plot_iter_curve(results)

    # 显示前关掉交互模式
    plt.ioff()
    plt.show()

# 看看我们要处理的目标函数
# def plot_obj_func():
#     plt.figure()
#     """y = 10 * math.sin(5 * x) + 7 * math.cos(4 * x)"""
#     X1 = [i / float(10) for i in range(0, 100, 1)]
#     Y1 = [10 * math.sin(5 * x) + 7 * math.cos(4 * x) for x in X1]
#     plt.plot(X1, Y1)
#     plt.show()


def plot_final_result(results):
    plt.ion()

    xlsx = xlrd.open_workbook('Lens_Value.xls')
    sheet1 = xlsx.sheets()[0]  # 获得第1张sheet，索引从0开始
    F = sheet1.col_values(0)  # 获得第1列数据
    Pvalue = sheet1.col_values(1)  # 获得第2列数据
    func = interpolate.interp1d(F, Pvalue, 'nearest')

    plt.figure()

    plt.plot(F, Pvalue)

    plt.scatter(results[-1][0], results[-1][1], c='r', s=10)
    plt.show()

# 看看最终的迭代变化曲线
def plot_iter_curve(results):
    plt.ion()
    plt.figure()
    X = [i for i in range(len(results))]
    Y = [results[i][1] for i in range(len(results))]
    plt.plot(X, Y)
    plt.show()
    plt.ioff()
    plt.show()

if __name__ == '__main__':
    # for i in range(100):
    main()
