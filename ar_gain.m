function [a] = ar_gain(r,n,j,a)
% ------------------------------------------------------%
% 定義匿名函數給 -> integral(積分的匿名函數調用,-inf,inf)
% a(r), r = t./(n+1), t = r(n+1) 
% h = (t./(n+1) ).^j, r.^j % arrayfun(fun)
h = @(t,n,j) (t./(n+1)).^j; % h(r(n+1),n,j)
% n = g_struct.samples; t = r.*(n+1); j = 1:(r.*(n+1));
% a(t) = -sum(a(j).*h(r.*(n+1),n,j))
% a(r) = g_struct.varing_gain( round(r.*(n+1) ) ).*h(r.*(n+1),n,j)
%a = @(r,n,j,a) sum( a( round(r.*(n+1) ) ).*h(r.*(n+1),n,j) );% a use g_struct.varing_gain
a = sum( a( round(r.*(n+1) ) ).*h(r.*(n+1),n,j) ) ;% a use g_struct.varing_gain
% anonymous function is a short term function so need to --> *.m file
% ------------------------------------------------------%