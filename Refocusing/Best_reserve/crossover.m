%����任
%���������pop�������Ƶĸ�����Ⱥ����pc������ĸ���
%���������newpop����������Ⱥ��
function [newpop] = crossover(pop,pc)
[px,py] = size(pop);
newpop = pop;

%ÿ������ֻȡһ��
indres=randperm(px,px-round(px*pc));
res=pop(indres,:);
%fa&ma�������ظ�ȡ����
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