%%遗传算法
%%genetic algorithm
%%https://www.cnblogs.com/LoganChen/p/7509702.html

clear;
clc;
%种群大小
popsize=30;
%编码长度chromlength
n=20;
chromlength=n*n;
%交叉概率
pc = 0.55;
%变异概率
pm = 0.002;
%最高相位级
opt_level=15;    
opt=[0:opt_level];
%初始种群
pop = initpop(popsize,chromlength, opt_level);
%散射矩阵
load('T.mat');

bestindividual=-inf*ones(1,chromlength);
bestfit=-inf;

tic

for i = 1:20
    %计算适应度值（函数值）
    fitvalue = cal_objvalue(pop,T);    
    
    %记录最优值
    [bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);
    aim_value(i)=bestfit;
    %选择操作
    newpop = selection(pop,fitvalue);%新种群内各类个体的数目正比于其适应值
    %交叉操作
    newpop = crossover(newpop,pc);
    %变异操作
    newpop = mutation(newpop,pm,opt);
    %更新种群
    pop = newpop;
end
%计算适应度值（函数值）
fitvalue = cal_objvalue(pop,T);    
%记录最优值
[bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);
aim_value(i+1)=bestfit;

toc

%%
%%迭代曲线
figure
plot(aim_value)
xlabel('迭代次数')
ylabel('目标点能量强度')
%%