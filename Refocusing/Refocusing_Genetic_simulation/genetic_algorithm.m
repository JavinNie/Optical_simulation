%%�Ŵ��㷨
%%genetic algorithm
%%https://www.cnblogs.com/LoganChen/p/7509702.html

clear;
clc;
%��Ⱥ��С
popsize=30;
%���볤��chromlength
n=20;
chromlength=n*n;
%�������
pc = 0.55;
%�������
pm = 0.002;
%�����λ��
opt_level=15;    
opt=[0:opt_level];
%��ʼ��Ⱥ
pop = initpop(popsize,chromlength, opt_level);
%ɢ�����
load('T.mat');

bestindividual=-inf*ones(1,chromlength);
bestfit=-inf;

tic

for i = 1:20
    %������Ӧ��ֵ������ֵ��
    fitvalue = cal_objvalue(pop,T);    
    
    %��¼����ֵ
    [bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);
    aim_value(i)=bestfit;
    %ѡ�����
    newpop = selection(pop,fitvalue);%����Ⱥ�ڸ���������Ŀ����������Ӧֵ
    %�������
    newpop = crossover(newpop,pc);
    %�������
    newpop = mutation(newpop,pm,opt);
    %������Ⱥ
    pop = newpop;
end
%������Ӧ��ֵ������ֵ��
fitvalue = cal_objvalue(pop,T);    
%��¼����ֵ
[bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);
aim_value(i+1)=bestfit;

toc

%%
%%��������
figure
plot(aim_value)
xlabel('��������')
ylabel('Ŀ�������ǿ��')
%%