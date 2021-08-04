%求最优适应度函数
%输入变量：pop:种群，fitvalue:种群适应度
%输出变量：bestindividual:最佳个体，bestfit:最佳适应度值
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