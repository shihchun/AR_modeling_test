function [aa] = ar_gain(r,n,j,a)
% ------------------------------------------------------%
% 定義匿名函數給 -> integral(積分的匿名函數調用,-inf,inf)
% a(r), r = t./(n+1), t = r(n+1) 
% h = (t./(n+1) ).^j, r.^j % arrayfun(fun)
h = @(t,n,j) (t./(n+1)).^j; % h(r(n+1),n,j)
% n = g_struct.samples; t = r.*(n+1); j = 1:(r.*(n+1));
% a(t) = -sum(a(j).*h(r.*(n+1),n,j))
% a(r) = g_struct.varing_gain( round(r.*(n+1) ) ).*h(r.*(n+1),n,j)
%a = @(r,n,j,a) sum( a( round(r.*(n+1) ) ).*h(r.*(n+1),n,j) );% a use g_struct.varing_gain
if r >=0.99
    aa = -sum( a( ceil(r.*(n) ) ).*h(ceil( r.*(n) ) ,n,j) ) ;% r ==1 .* n+1 exceed the samples number don't what to do 
else
    %--------------------------------%
    %Array indices must be positive integers or logical values
    % assemble -> workspace -> debuging
%     assignin('base','bug_r',r);
%     assignin('base','bug_n',n);
%     assignin('base','bug_fcn_h',h);
%     assignin('base','bug_j',1:10);
    %g_struct.varing_gain( round(bug_r.*(bug_n+1) ) )
    %bug_fcn_h(round( bug_r.*(bug_n+1) ) ,bug_n,bug_j)
    %bug_a = g_struct.varing_gain( round(bug_r.*(bug_n+1) ) ).*bug_fcn_h(round( bug_r.*(bug_n+1) ) ,bug_n,bug_j)
    %--------------------------------%
%     a( round(r.*(n+1) ) )
%     h(round( r.*(n+1) ) ,n,j) 
    aa = -sum( a( ceil(r.*(n) ) ).*h(ceil( r.*(n+1) ) ,n,j) ); % a use g_struct.varing_gain
end
% anonymous function is a short term function so need to --> *.m file
% ------------------------------------------------------%