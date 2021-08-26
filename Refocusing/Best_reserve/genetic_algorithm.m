%%遗传算法
%%genetic algorithm
%%https://www.cnblogs.com/LoganChen/p/7509702.html

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%基因数400
%取值范围0-15，在计算适应性中映射成0-2pi范围内
%基因算法，工具箱，只求最小值，本代码求最高值
%重点看cal_objvalue
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
% clc;
%种群大小
global popsize
popsize=100;
%编码长度chromlength
global n
n=20;
chromlength=n*n;%400;

%精英保存比例
global Pb
Pb=0.5;
%交叉概率
pc = 0.8;
%变异概率
pm = 0.4;
%初始种群
pop = initpop(popsize,chromlength);
%散射矩阵
global T
load('T.mat');
% load('indnone1.mat')
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TEST
% pop=bestindividual;

bestindividual=-inf*ones(1,chromlength);
bestfit=-inf;

tic

%%
fitvalue = cal_objvalue(pop);    
%记录最优值
[bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);

for i = 1:100
    %交叉操作
    newpop = crossover(pop,pc);
    %变异操作
    if mod(i,30)==1
        pm=pm*0.2;%变异概率渐下降    
    end
    newpop = mutation(newpop,pm);
    %计算适应度值（函数值）
    fitvalue_new = cal_objvalue(newpop);     
    %记录最优值
    [bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);
    aim_value(i)=bestfit;%每一代最佳个体适应度
    
    %更新种群-选择操作
    newpop = selection(newpop,fitvalue_new,bestindividual,bestfit);%新种群内各类个体的数目正比于其适应值

    %精英保存
    [~,ind]=sort(fitvalue,'descend');
    ind=ind(1:round(popsize*Pb));
    ind_new=randperm(popsize,popsize-round(popsize*Pb));
    
    pop=[pop(ind,:);newpop(ind_new,:)];
    fitvalue=[fitvalue(ind,:);fitvalue_new(ind_new,:)];
    
    %乱序
    indrand=randperm(popsize);
    pop=pop(indrand,:);
    fitvalue=fitvalue(indrand,:);
end
toc
save 'indnone1.mat' bestindividual
%%
%%迭代曲线
max(aim_value)
figure
plot(aim_value)
xlabel('迭代次数')
ylabel('目标点能量强度')
%%
pos = get(gcf,'position');%获取当前figure的位置信息
set(gcf,'position',[(1920-pos(3))/2,(1080-pos(4))/2,pos(3),pos(4)])