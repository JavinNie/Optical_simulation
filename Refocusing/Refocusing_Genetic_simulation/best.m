%��������Ӧ�Ⱥ���
%���������pop:��Ⱥ��fitvalue:��Ⱥ��Ӧ��
%���������bestindividual:��Ѹ��壬bestfit:�����Ӧ��ֵ
function        [bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit)
% [px,py] = size(pop);
% bestindividual = pop(1,:);
% bestfit = fitvalue(1);
% for i = 2:px
%     if fitvalue(i)>bestfit
%         bestindividual = pop(i,:);
%         bestfit = fitvalue(i);
%     end
% end

ind=find(fitvalue==max(fitvalue));
if fitvalue(ind(1))>bestfit
    bestindividual=pop(ind(1),:);
    bestfit=fitvalue(ind(1));
end