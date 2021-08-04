%%遗传算法
%%genetic algorithm
%%https://www.cnblogs.com/LoganChen/p/7509702.html

clear;
clc;
%种群大小
popsize=30;
%二进制编码长度
chromlength=10;
%交叉概率
pc = 0.5;
%变异概率
pm = 0.001;
%初始种群
pop = initpop(popsize,chromlength);

bestindividual=-inf*ones(1,chromlength);
bestfit=-inf;

for i = 1:20
    %计算适应度值（函数值）
    fitvalue = cal_objvalue(pop);    
    
    %记录最优值
    [bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);
    %选择操作
    newpop = selection(pop,fitvalue);%新种群内各类个体的数目正比于其适应值
    %交叉操作
    newpop = crossover(newpop,pc);
    %变异操作
    opt=[0,1];
    newpop = mutation(newpop,pm,opt);
    %更新种群
    pop = newpop;

     if i == 1   
            x1 = binary2decimal(newpop);
            y1 = cal_objvalue(newpop);
            figure;
            fplot('10*sin(5*x)+7*abs(x-5)+10',[0 10]);
            hold on;
            plot(x1,y1,'*');
            title(['迭代次数为n=' num2str(i)]);
     end
end
%%
            x1 = binary2decimal(newpop);
            y1 = cal_objvalue(newpop);
            figure;
            fplot('10*sin(5*x)+7*abs(x-5)+10',[0 10]);
            hold on;
            plot(x1,y1,'*');
            title(['迭代次数为n=' num2str(i)]);
%%

%寻找最优解
[bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);
x2 = binary2decimal(bestindividual);
y2 = cal_objvalue(bestindividual);
plot(x2,y2,'g*');
hold off
fprintf('The best X is --->>%5.2f\n',x2);
fprintf('The best Y is --->>%5.2f\n',bestfit);