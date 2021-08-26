%交叉变换
%输入变量：pop：二进制的父代种群数，pc：交叉的概率
%输出变量：newpop：交叉后的种群数
function [newpop] = crossover(pop,pc)
[px,py] = size(pop);
newpop = pop;

%每个个体只取一次
indres=randperm(px,px-round(px*pc));
res=pop(indres,:);
%fa&ma，可以重复取个体
indfa=round(rand(round(px*pc),1)*(px-1))+1;
indma=round(rand(round(px*pc),1)*(px-1))+1;
fa=pop(indfa,:);
ma=pop(indma,:);

%binary mask
mask=logical(round(rand(round(px*pc),py)));

%cross
son=zeros(size(fa));
son(mask)=fa(mask);
son(~mask)=ma(~mask);

%combine
newpop=[son;res];
newpop=newpop(randperm(px),:);