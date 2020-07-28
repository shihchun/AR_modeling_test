function [D,R] = rate(g)
% have g_struct generated and input
% g = struct('p',p,'N',length(t),'te',te, 'i' ,... % series length, (p+1):(te+1) % 累計用預測資料
%     'am',a,'ar',ar(1:i), 'input',xt ,'theta' ,theta , ... % integral parameters
%     'f', f, 't',t,'alpha',alpha ,'signal', signal_test... % signal fcn & input parameter
%     );
%function [D,R] = rate(g_struct)
    %D = 0; %R = 0;
%end

% check input (assert)
field = {'p','N','te','am','ar','input','theta','h','f','t','alpha','signal','i'};
if isfield(g, field) == 0
    error('Some filed is missing, 缺少輸入');
end

% sig_str = char(g.signal);% @(f,t)sin(2.*pi.*f.*t)
% disp(sig_str);
% ind = find(sig_str == ')',1) +1;
% signal_str = sig_str(ind:end) % sin(2.*pi.*f.*t)
% % 1:(ind-1) @(f,t) --> 3:(ind-2)  f,t
% vars_str = sig_str(3:(ind-2)) % f,t

variance = var(g.ar((g.p+1:g.i)));
omega = 2.*pi.*g.f;

% % amr 寫到function amr.m 去 因? 匿名函數 存活時間很短，就會被清除之類的抓不到
% % 選初始 aj(s), s is selector
% s = 1;
% if (g.f==0.08)
%     aj = [0.999, -0.0104, -0.0042];
% elseif (g.f == 0.05)
%     aj = [0.9803, 0.0373, -0.0929];
% elseif (g.f == 0.025)
%     aj = [0.9576, 0.0063, -0.1063];
% else
%     aj = [0.5, 0.1, 0.9, 0.8, 0.4]; % 第一次算時候的用的 autoregresive gain
% end
% % 算法 a(t) = a(t)+ aj(s) + h(t,te+1,k); p=1 所以不用疊代
% amr = @(r) aj(s).*g.h(r,g.te+1,s);
global tee ff ss
ff = g.f;
tee = g.te;
ss = 1;
% assignin('base','ff',g.f);
% assignin('base','tee',g.te);


amexp = '';
for i = g.p+1:g.i
    % str1 = sprintf('%f', g.am(i)); %% 積分變數 r
    str1 = 'amr(r)';
    str2 = '.*exp(-j.*';
    % str3 = sprintf('%f', omega); %% 積分變數 w
    str3 = 'w';
    str4 = ')';
    % amexp = sprintf('%s%s%s%s',str1,str2,str3,str4) % '0.500020.*exp(-j.*62.831853)'
    % 變數 '1./0.002753.*(abs(1+amr(r).*exp(-j.*w)+amr(r).*exp(-j.*w)+amr(r).*exp(-j.*w)).^2)'
    if (i == g.p +1)
        amexp = sprintf('%s%s%s%s',str1,str2,str3,str4);
    else
        amexp = sprintf('%s%s%s%s%s%s', amexp,'+',str1,str2,str3,str4);
    end
end
str1 = '1./';
str2 = sprintf('%f', variance);
str3 = '.*(abs(1+'; % add amexp here
str4 = ').^2)';
amexp = sprintf('%s%s%s%s%s', str1,str2,str3,amexp,str4); % g

% integral D
D_poly = sprintf('%s%s%s%s','@(r,w) ','1./2./pi./(',amexp,')');
D_fun = str2func(D_poly); % str2func
D = integral2(D_fun, 0,1, -pi, pi);
D = min(g.theta,D);

% integral R
R_poly = sprintf('%s%s%s%s','@(r,w) ','1./2./pi./2.*log(1./',amexp,')');
R_fun = str2func(R_poly); % struct()
R = integral2(R_fun, 0,1, -pi, pi);
R = max(0,R);
% fprintf('\nD = %f, R = %f\n',D,R); % DEBUG 用
end