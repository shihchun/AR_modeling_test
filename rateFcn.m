clc;
rate_test;

lag = g_struct.lag_p;
N = g_struct.samples;
x = g_struct.predict;
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

%theta = max(x) - sigma./4;
theta = 4.7779e-275;

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
k_flat = reshape(k.',1,[]); % flat to 1xN 找N個裏面最小的
% find the index of minumax value
index = find( k_flat == min( k_flat ),1,'last');
[i,j] = find(k == k_flat(index),1,'last'); % 從後面找積分項數比較多的一項
fprintf('\n min(1/g): %d\n theta: %d\n in omega: %d\n',k(i,j),theta,omega(i));
stem(g); figure();stem(1./g);
%ind % use this minimum value in the final iteration
%str_intgral_D
%str_intgral_R
%D
%R
% calc end %