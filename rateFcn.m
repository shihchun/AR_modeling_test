function [D,R] = rateFcn(g_struct)
% have g_struct generated
% g_struct = struct('lag_p',lag,'samples',N, 'varing_gain',a,...
%        'predict',x,'noise',e, 'input',e );
%function [D,R] = rate(g_struct)
    %D = 0;
    %R = 1;
%end

% initial �ŧi
sigma = zeros(1,g_struct.samples);
% calc the parameters
sigma = var(g_struct.predict);

%theta = max(x) - sigma./4;
theta = 1.0893e-86;

% calcl the g
omega = linspace(-pi,pi,1000);
%omega = logspace(-pi,pi,1000);
g = zeros(length(omega),g_struct.samples);
% g(i,:) = 1./( (sigma).^2 ).*abs(1+ sum(g_struct.varying_gain .* exp(-j.*m*omega(i)) ) ).^2;
for i = 1:length(omega)
    poly_of_sum = 0;
    for m = 1:g_struct.samples
        poly_of_sum = poly_of_sum + g_struct.varing_gain(m) .* exp(-j.*m.*omega(i));
        g(i,m) = 1./( (sigma).^2 ).*abs(1+ poly_of_sum ).^2;
    end
end

k= 1./g;
k_flat = reshape(k.',1,[]); % flat to 1xN ��N���ح��̤p��
% find the index of minumax value
if isempty(min( k_flat(k_flat>theta) ))
    fprintf('\nmin>theta\n');
    index = find( k_flat == min( k_flat ),10,'last'); 
else
    index = find( k_flat == min( k_flat(k_flat>theta) ),10,'last');
end

%iter = mod(index, g_struct.samples)+1 % searching the iteration of min value
mod(index,g_struct.samples);
iter = max(mod(index,g_struct.samples))+1; % 10���I��̤j��
% �C�������D?���򤣬O�̤j�N�O�̤p�A�����Ĥ@���άO�̫�@���H
% 42    43    44    45    46    47    48    49    50     1

% [i,j] = find(k == k_flat(index),1,'last'); % �q�᭱��n�����Ƥ���h���@��
%fprintf(' We get the MIN at:');
%fprintf('\n seq = %d\n min(1/g): %d\n theta: %d\n in omega: %d\n',iter,k_flat(index),theta,omega(i));
%figure();stem(g);title('stem g seqs'); figure();stem(1./g); title('stem 1/g seqs');

% generator integral string of 'iter' seqs

% D_theta = @(r,w) 1./( 1./(sigma(i).^2).* abs(1 + sum(1 + a(r).*exp(-j.*length(s(i,:)).*w) ) ).^2 );
str1 = '@(r,w) 1./(1./ ('; 
str2 = string(sigma);
str3 = '.^2).* abs(1+';
% ------------------------------------------------------%
% �w�q�ΦW��Ƶ� -> integral(�n�����ΦW��ƽե�,-inf,inf)
% a(r), r = t./(n+1), t = r(n+1) 
% h = (t./(n+1) ).^j, r.^j % arrayfun(fun)
h = @(t,n,j) (t./(n+1)).^j; % h(r(n+1),n,j)
% n = g_struct.samples; t = r.*(n+1); j = 1:(r.*(n+1));
% a(t) = -sum(a(j).*h(r.*(n+1),n,j))
% a(r) = g_struct.varing_gain( round(r.*(n+1) ) ).*h(r.*(n+1),n,j)
ar_gain = @(r,n,j,a) sum( a( round(r.*(n+1) ) ).*h(r.*(n+1),n,j) );% a use g_struct.varing_gain
% anonymous function is a short term function so need to --> *.m file
% ------------------------------------------------------%

poly_str4 = string('');
for k = 1:iter % with a(k), g_struct.varing_gain(k)
    % ar(r, g_struct.samples, k ,g_struct.varing_gain) % k is the �������� j
    gain_list_str = '['; %ex: [ 0.6800    0.7000    0.7200    0.740]
    for length_of_a = 1:length(g_struct.varing_gain)
        if length_of_a == length(g_struct.varing_gain)
            gain_list_str = sprintf(gain_list_str+ string(g_struct.varing_gain(length_of_a))+']' );
        else
            gain_list_str = sprintf(gain_list_str+ string(g_struct.varing_gain(length_of_a))+',' );
        end       
    end
    gain = sprintf('ar_gain(r,'+string(g_struct.samples)+','+string(k)+','+gain_list_str+')');
    %gain = string(g_struct.varing_gain(k)); %-jwm  m is eq to iter
    m = string(k);
    str_temp = '.*exp(-j.*';
    if k==1
        poly_str4 = sprintf(  gain + str_temp + m +'.*w)' );
    else
        poly_str4 = sprintf( poly_str4 + '+' + gain + str_temp + m +'.*w)' );
    end
end
% for k = 1:iter % with a(k), g_struct.varing_gain(k) this no r in integral
%     gain = string(g_struct.varing_gain(k)); %-jwm  m is eq to iter
%     m = string(k);
%     str_temp = '.*exp(-j.*';
%     if k==1
%         poly_str4 = sprintf(  gain + str_temp + m +'.*w)' );
%     else
%         poly_str4 = sprintf( poly_str4 + '+' + gain + str_temp + m +'.*w)' );
%     end
% end

% str4: a1(r)*exp(-jmw)+a2(r)*exp(exp(-jmw)+...
str4 =sprintf('('+poly_str4+')');% (sum)
str5 = ').^2)';
D_poly = sprintf(str1+str2+str3+str4+str5);
D_fun = str2func(D_poly) % str2func
% D = int_fcn(D_fun, g_struct)%
D = integral2(D_fun, 0,1, -pi, pi);

str1 = sprintf('@(r,w) 1./2.*log10(1./'+string(theta)+'./(1./ ('); % add 1./2log(1./theta./g)to fun
str5 = ').^2) )';
R_poly = sprintf(str1+str2+str3+str4+str5);
R_fun = str2func(R_poly); % struct()
% R = int_fcn(R_fun, g_struct) %
R = integral2(R_fun, 0,1, -pi, pi);
%fprintf(' D: %d  , R: %d\n',D,R);
% k_flat(iter) % use this minimum value in the final iteration
% R_poly
% D_poly
% D
% R
% calc end %
end