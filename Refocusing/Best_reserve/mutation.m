%关于编译
%函数说明
%输入变量：pop：二进制种群，pm：变异概率，opt：该基因可选的值
%输出变量：newpop变异以后的种群
%20210810 聂杰文
%连续实数取值范围0~2pi
function [newpop] = mutation(pop,pm)
[px,py] = size(pop);
newpop = pop;
p=rand(px,py);
pop_temp=newpop(p<pm);
newpop(p<pm)=rand(size(pop_temp))*2*pi;