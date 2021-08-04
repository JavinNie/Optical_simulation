%关于编译
%函数说明
%输入变量：pop：二进制种群，pm：变异概率，opt：该基因可选的值
%输出变量：newpop变异以后的种群
function [newpop] = mutation(pop,pm,opt)
[px,py] = size(pop);
newpop = pop;
for i = 1:px
    if(rand<pm)
        mpoint =  round(rand*(py-1))+1;%%1:py
        opt1=opt;
        opt1(opt1==newpop(i,mpoint))=[];
        newpop(i,mpoint) = opt1(randperm(length(opt1),1));%随机变异
    end
end