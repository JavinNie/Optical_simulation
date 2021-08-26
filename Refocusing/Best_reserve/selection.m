%如何选择新的个体
%输入变量：pop二进制种群，fitvalue：适应度值
%输出变量：newpop选择以后的二进制种群
function [newpop,newfitvalue] = selection(pop,fitvalue,bestindividual,bestfit)
global popsize
%首先剔除相同的个体，再根据适应度值构造轮盘
[px,py]=size(pop);
poptemp=[];
fitvaluetemp=[];
for i=1:px
    if sum(ismember(pop(1:i-1,:),pop(i,:),'rows'))        
        continue
    end
    poptemp=[poptemp;pop(i,:)];
    fitvaluetemp=[fitvaluetemp;fitvalue(i,:)];
end
pop=poptemp;
fitvalue=fitvaluetemp;

%构造轮盘
p_fitvalue = cumsum(fitvalue/sum(fitvalue));%概率求和排序
ms = sort(rand(popsize,1));%从小到大排列
newpop=zeros(popsize,py);%新种群
newfitvalue=zeros(size(ms,1),1);

fitin = 1;
newin = 1;
while newin<=popsize
    if(ms(newin))<p_fitvalue(fitin)
        newpop(newin,:)=pop(fitin,:);
        newfitvalue(newin)=fitvalue(fitin);
        newin = newin+1;
    else
        fitin=fitin+1;
    end
end
%%
% %最佳个体替换最劣个体
ind=find(newfitvalue==min(newfitvalue));
if min(newfitvalue)<bestfit
    newpop(ind(1),:)=bestindividual;
    newfitvalue(ind(1),:)=bestfit;
end
% %%mix order
newpop=newpop(randperm(popsize),:);



