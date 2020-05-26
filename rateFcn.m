% calulate the rate in area [lag+1, N] ---> (g_struct.lag_p+1):g_struct.samples
%g_struct = struct('lag_p',lag,'samples',N, 'varing_gain',a,...
%    'predict',x(:,1)','noise',(e.*0.9), 'input',e );
lag = g_struct.lag_p;
N = g_struct.samples;
x = g_struct.predict(( g_struct.lag_p +1):g_struct.samples);
%function [D,R] = rate(g_struct)
    %D = 0;
    %R = 1;
%end
% initial 宣告
sigma = zeros(1,g_struct.samples);
r = zeros(1,g_struct.samples); 
xx = zeros(1,g_struct.samples);
nn = zeros(1,g_struct.samples);
% calc the parameters
sigma = var(g_struct.predict);

theta = max(x) - sigma./4;
%theta = 1;

r = g_struct.varing_gain; % t/N in the Model
% calc the g from omega = [-pi, pi]
omega = linspace(-pi,pi,1000);
%omega = logspace(-pi,pi,1000);

% calcl the g
g = zeros(length(omega),g_struct.samples);
for i = 1:length(omega)
    g(i,:) = 1./( (sigma).^2 ).*abs(1+ sum(g_struct.predict .* exp(-j.*g_struct.varing_gain.*omega(i)) ) ).^2;
end

k= 1./g;
k_flat = reshape(k.',1,[]);
% find the index of minumax value
% find( k == min( k(k>theta) ),1,'last'); %get error when k<theta but works
index = find( k_flat == min( k_flat(k_flat>0) ),1,'last');
[i,j] = find(k == k_flat(index),1,'last'); % 從後面找積分項數比較多的一項
if k(i,j) > theta
    fprintf('\n\n 1/g is less than theta, use theta = %d\n(%d,%d)\n',theta,i,j);
else
    fprintf('\n\nThe min value of 1/g is :\n(omega,1/g)\n(%d,%d)\nIn iteration: x(%d)\n(%d,%d)\n',omega(i),g(i,j),j,i,j);
end

%ind % use this minimum value in the final iteration
%str_intgral_D
%str_intgral_R
%D
%R
% calc end %