%%�Ŵ��㷨
%%genetic algorithm
%%https://www.cnblogs.com/LoganChen/p/7509702.html

clear;
clc;
%��Ⱥ��С
popsize=30;
%�����Ʊ��볤��
chromlength=10;
%�������
pc = 0.5;
%�������
pm = 0.001;
%��ʼ��Ⱥ
pop = initpop(popsize,chromlength);

bestindividual=-inf*ones(1,chromlength);
bestfit=-inf;

for i = 1:20
    %������Ӧ��ֵ������ֵ��
    fitvalue = cal_objvalue(pop);    
    
    %��¼����ֵ
    [bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);
    %ѡ�����
    newpop = selection(pop,fitvalue);%����Ⱥ�ڸ���������Ŀ����������Ӧֵ
    %�������
    newpop = crossover(newpop,pc);
    %�������
    opt=[0,1];
    newpop = mutation(newpop,pm,opt);
    %������Ⱥ
    pop = newpop;

     if i == 1   
            x1 = binary2decimal(newpop);
            y1 = cal_objvalue(newpop);
            figure;
            fplot('10*sin(5*x)+7*abs(x-5)+10',[0 10]);
            hold on;
            plot(x1,y1,'*');
            title(['��������Ϊn=' num2str(i)]);
     end
end
%%
            x1 = binary2decimal(newpop);
            y1 = cal_objvalue(newpop);
            figure;
            fplot('10*sin(5*x)+7*abs(x-5)+10',[0 10]);
            hold on;
            plot(x1,y1,'*');
            title(['��������Ϊn=' num2str(i)]);
%%

%Ѱ�����Ž�
[bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit);
x2 = binary2decimal(bestindividual);
y2 = cal_objvalue(bestindividual);
plot(x2,y2,'g*');
hold off
fprintf('The best X is --->>%5.2f\n',x2);
fprintf('The best Y is --->>%5.2f\n',bestfit);