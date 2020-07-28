function [am] = amr(r)

global tee ff ss
% amr 寫到function去 因? 匿名函數 存活時間很短，就會被清除之類的抓不到
% 選初始 aj(s), s is selector
if (ff==0.08)
    aj = [0.999, -0.0104, -0.0042];
elseif (ff == 0.05)
    aj = [0.9803, 0.0373, -0.0929];
elseif (ff == 0.025)
    aj = [0.9576, 0.0063, -0.1063];
else
    aj = [0.5, 0.1, 0.9, 0.8, 0.4]; % 第一次算時候的用的 autoregresive gain
end
% 算法 a(t) = a(t)+ aj(s) + h(t,te+1,k); p=1 所以不用疊代

h = @(t,n,j) (t./(n+1)).^j;
amrr = @(r) -aj(ss).*h(r,tee,ss);
assignin('base','DEBUG_R',r); % integral2傳進來是nxn的矩陣
% am =r; % nxn 送回去可以運行
% am = amrr(r);
[m,n] = size(r);
am = zeros(m,n);

for i = 1:m
    for j = 1:n
        tmp = r(i,j);
        assignin('base','DEBUG_tmp',[tmp,i,j,m,n,aj(ss)]);
        assignin('base','DEBUG_te',tee);
        assignin('base','DEBUG_ss',ss);
        am(i,j) = amrr(tmp); %amrr(tmp);
        assignin('base','DEBUG_am',am);
    end
end
end