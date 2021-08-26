%%�Ŵ��㷨
%%genetic algorithm
%%https://www.cnblogs.com/LoganChen/p/7509702.html

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%������400
%ȡֵ��Χ0-15���ڼ�����Ӧ����ӳ���0-2pi��Χ��
%�����㷨�������䣬ֻ����Сֵ�������������ֵ
%�ص㿴cal_objvalue
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
% clc;
%��Ⱥ��С
global popsize
popsize=100;
%���볤��chromlength
global n
n=20;
chromlength=n*n;%400;

%��Ӣ�������
global Pb
Pb=0.5;
%�������
pc = 0.8;
%�������
pm = 0.4;
%��ʼ��Ⱥ
pop = initpop(popsize,chromlength);
%ɢ�����
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
%��¼����ֵ
[bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);

for i = 1:100
    %�������
    newpop = crossover(pop,pc);
    %�������
    if mod(i,30)==1
        pm=pm*0.2;%������ʽ��½�    
    end
    newpop = mutation(newpop,pm);
    %������Ӧ��ֵ������ֵ��
    fitvalue_new = cal_objvalue(newpop);     
    %��¼����ֵ
    [bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);
    aim_value(i)=bestfit;%ÿһ����Ѹ�����Ӧ��
    
    %������Ⱥ-ѡ�����
    newpop = selection(newpop,fitvalue_new,bestindividual,bestfit);%����Ⱥ�ڸ���������Ŀ����������Ӧֵ

    %��Ӣ����
    [~,ind]=sort(fitvalue,'descend');
    ind=ind(1:round(popsize*Pb));
    ind_new=randperm(popsize,popsize-round(popsize*Pb));
    
    pop=[pop(ind,:);newpop(ind_new,:)];
    fitvalue=[fitvalue(ind,:);fitvalue_new(ind_new,:)];
    
    %����
    indrand=randperm(popsize);
    pop=pop(indrand,:);
    fitvalue=fitvalue(indrand,:);
end
toc
save 'indnone1.mat' bestindividual
%%
%%��������
max(aim_value)
figure
plot(aim_value)
xlabel('��������')
ylabel('Ŀ�������ǿ��')
%%
pos = get(gcf,'position');%��ȡ��ǰfigure��λ����Ϣ
set(gcf,'position',[(1920-pos(3))/2,(1080-pos(4))/2,pos(3),pos(4)])