%����任
%���������pop�������Ƶĸ�����Ⱥ����pc������ĸ���
%���������newpop����������Ⱥ��
function [newpop] = crossover(pop,pc)
[px,py] = size(pop);
newpop = pop;
x=[1:px];
y=[1:py];

for i = 1:2:px-1
    if(rand<pc)
        cpoint = round(rand*(py-2))+1;%%1:py-1
%         iex=i+1;
        iex=round(rand*(px-1))+1;%%1:px
        newpop(i,:) = [pop(i,1:cpoint),pop(iex,cpoint+1:py)];
        newpop(iex,:) = [pop(iex,1:cpoint),pop(i,cpoint+1:py)];
    end
end