%初始化种群大小
%输入变量：
%popsize：种群大小
%chromlength：染色体长度-->>转化的二进制长度
%opt_level:可选值的数目
%输出变量：
%pop：种群
function pop=initpop(popsize,chromlength)
pop = rand(popsize,chromlength)*2*pi;
