%���ڱ���
%����˵��
%���������pop����������Ⱥ��pm��������ʣ�opt���û����ѡ��ֵ
%���������newpop�����Ժ����Ⱥ
function [newpop] = mutation(pop,pm,opt)
[px,py] = size(pop);
newpop = pop;
for i = 1:px
    if(rand<pm)
        mpoint =  round(rand*(py-1))+1;%%1:py
        opt1=opt;
        opt1(opt1==newpop(i,mpoint))=[];
        newpop(i,mpoint) = opt1(randperm(length(opt1),1));%�������
    end
end