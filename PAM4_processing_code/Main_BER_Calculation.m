%%20210704
%�������������̣�������������
%njw

%%

tic
clear
%%
%-----------------------------�������ݼ���---------------------------------
% local=['D:\document\Research\ˮ�¹�ͨ��\mfile\communication\ACP21-07-04\pam4\'];
% seq=csvread([local '100M_15m_clean.csv'],2,0,'A3..B62502');

local='D:\document\Research\ˮ�¹�ͨ��\mfile\communication\ACP21-07-04\PAM_ACP\pam4\';
% seq=csvread([local '20m_50M_clean.csv'],2,0,'A3..B62502');

fre=100;
% seq=csvread([local '25m_' num2str(fre) 'M_clean1.csv'],2,0,'A3..B50002');
seq=csvread([local '20m_' num2str(fre) 'M.csv'],2,0,'A3..B50002');

Array=seq(:,2);
Tinterval=mean(diff(seq(:,1)));
Length=length(Array);
%%
%--------------------------------�ź�Դ���ò���(�ֶ�)----------------------------
baud_per_pattern=250;
Fsend=fre/250*1e6;%frequency send :200k
order=2;%PAM ���ƽ���

Ttotal=Tinterval*Length;
Npat=Fsend*Ttotal;%number of pattern
sample_per_baud=Length/(baud_per_pattern*Npat);%ÿ�������ڵĲ�������

%%
%���ڽ�ԭʼ���з��������������ٻ������

%----------------------------------�źŲ�������----------------------------
%�ȼ��������Ȼ��Ӳ�о��������о����������㷽����о���
%1\���ַ���������飬�����Ӳ�о����ޣ�2���ȼ��������Ȼ��ʹ��֮ǰ��Ӳ�о����޽��������,ͬ���Ƕ��ַ������㷽�����֮����С�ľ�����Ѳ����㡣
%����1�����벨�κ͹���������ַ���������о����ޣ�
%����2������ȡ��֮��Ĳ��κ͸����о����ޣ������������������������������ֵ

%----------���ݲ���������������Եķ��Ѱ����Ѳ����㣨��󷽲--------
threshold= Detection(Array,order);%����2^n-1������ֵ
for i=1:ceil(sample_per_baud)
    a=Array(round([i:sample_per_baud:end]));
    variance(i)=variance_calcualtion(a,threshold);
end
ind=find(variance==max(variance));
Bstream=Array(round([ind:sample_per_baud:end]));%����Ѳ��������
if ind>sample_per_baud
    Bstream=[Array(1); Bstream];
    disp('sample again')
end
%----------------����ͬ������������ֵ------------------------------------
%%
source_signal = load([local 'AWG_250bit_PAM4_.csv']);
T_sample=round(length(source_signal)/baud_per_pattern);
Bstream_source=source_signal(1:T_sample:end);
Bstream_source=repmat(Bstream_source,floor(Npat),1);
%ά�Ƚ���
Bstream=Bstream(1:length(Bstream_source));
for shift=1:baud_per_pattern
    Bstream_temp= circshift(Bstream,shift-1);
    R = corrcoef(Bstream_source,Bstream_temp);
    R_result(shift) = R(1,2);
end
Shift = find(R_result == max(max(R_result)));
Bstream_shift= circshift(Bstream,Shift-1);

%---------------------��β��ת��bit�����������----------------------------
Bstream_shift=Bstream_shift(1:baud_per_pattern*(Npat-1));
Bit_stream_shift=Baud2bit(Bstream_shift,order,threshold);

Bstream_source=Bstream_source(1:baud_per_pattern*(Npat-1));
Threshold_source= Detection(Bstream_source,order);%����2^n-1������ֵ
Bit_stream_source=Baud2bit(Bstream_source,order,Threshold_source);

BER=sum(xor(Bit_stream_source,Bit_stream_shift))/length(Bit_stream_source)
