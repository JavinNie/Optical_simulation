%���ѡ���µĸ���
%���������pop��������Ⱥ��fitvalue����Ӧ��ֵ
%���������newpopѡ���Ժ�Ķ�������Ⱥ
function [newpop,newfitvalue] = selection(pop,fitvalue,bestindividual,bestfit)
global popsize
%�����޳���ͬ�ĸ��壬�ٸ�����Ӧ��ֵ��������
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

%��������
p_fitvalue = cumsum(fitvalue/sum(fitvalue));%�����������
ms = sort(rand(popsize,1));%��С��������
newpop=zeros(popsize,py);%����Ⱥ
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
% %��Ѹ����滻���Ӹ���
ind=find(newfitvalue==min(newfitvalue));
if min(newfitvalue)<bestfit
    newpop(ind(1),:)=bestindividual;
    newfitvalue(ind(1),:)=bestfit;
end
% %%mix order
newpop=newpop(randperm(popsize),:);



