%��������Ӧ�Ⱥ���
%���������pop:��Ⱥ��fitvalue:��Ⱥ��Ӧ��
%���������bestindividual:��Ѹ��壬bestfit:�����Ӧ��ֵ
function        [bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit)
ind=find(fitvalue==max(fitvalue));
if fitvalue(ind(1))>bestfit
    bestindividual=pop(ind(1),:);
    bestfit=fitvalue(ind(1));
end