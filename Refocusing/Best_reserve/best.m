%求最优适应度函数
%输入变量：pop:种群，fitvalue:种群适应度
%输出变量：bestindividual:最佳个体，bestfit:最佳适应度值
function        [bestindividual,bestfit] = best(pop,fitvalue, bestindividual,bestfit)
ind=find(fitvalue==max(fitvalue));
if fitvalue(ind(1))>bestfit
    bestindividual=pop(ind(1),:);
    bestfit=fitvalue(ind(1));
end