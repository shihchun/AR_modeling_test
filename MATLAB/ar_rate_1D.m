clear all; close all; clc;
% sampling parameters
f = 0.025;
f = 0.05;
f = 0.08;
f = 10; % signal_test, ctrl+R, ctrl+T ���� �h������
% endtime = 5; % �ɶ����� signal_test
endtime = 1000; % �ɶ����� signal 
seq = 10; % test seq length for predition (forcasting length)
lagt = 1; % lag �X�� pause AR(p)�� �ثe�U���p��u�� lag 1
N = f*(endtime+seq); % sample �ƶq ��f
t = linspace(1,endtime+seq,N);
% ��lag�X��sample
p = find( t <= lagt, 1, 'last'); % lagt ���e�@�� index�A�Ҧp�A����10��A���9.xx��
te = find( t <= endtime, 1, 'last'); %ind_endtime = te+1
%fprintf('Index of:\np(pause): %d\nendtime: %d\nsimulation length: %d\n',p,te,length(t));

% define the input as anonymous fcn
signal = @(f,t,alpha) sin(2.*pi.*(f+alpha.*t.^2).*t) + cos(2.*pi.*alpha.*t);
signal_test = @(f,t) sin(2.*pi.*f.*t);
alpha = 0.5;
x = signal_test(f,t);
% x = signal(f,t,alpha);


n_rate = 0.05; % rate of the noise
rng default; % random variable generator
noise = randn(1,length(t));
xt = x + n_rate * noise;

figure();title("signals");
subplot(3,1,1);plot(t,x); legend('original');%hold on;
subplot(3,1,2);plot(t,xt);legend('with noise');
subplot(3,1,3);plot(t,noise*n_rate);legend('noise');

csvdata = zeros(length(t),4);
csvdata(:,1) = t;csvdata(:,2) = x;csvdata(:,3) = xt; csvdata(:,4) = noise*n_rate;
% writematrix(csvdata,'test.csv');%no header 
% csvwrite(test.csv, t); % only one var
csv = array2table(csvdata);
csv.Properties.VariableNames(1:4) = {'t','original','with_noise','noise'};
writetable(csv,'test.csv');

% AR(p) �p��lag p �ɶ��� AR rate
% case 1, r = t/n, a(t) --> a(r)
% a1 = - sumj( aj*hj(t) )
% a --> hj(t) = [t/(n+1)]^j ,j = 0,1,2,...s�A��p������index�j�p
h = @(t,n,j) (t/(n+1)).^j; % basis
r = zeros(1,te+1); % r
for i = 1:length(r)
    %r(i) = i/(length(t)+1);% �άOlength(t)+1
    r(i) = t(i)/(length(t)+1);
    %h(i) = (t(i)/(length(r)+1)).^i;% �άOlength(t)+1
end

ar = zeros(1,length(t));
a = zeros(1,length(t));
D = zeros(1,length(t));
R = zeros(1,length(t));
for i = (p+1):(te) % �֭p�ιw�����
    % ��p�� �ɶ��� sample �n�[�^�� �Ĥ@�����]�w²��ϥ� a = 0.5
    % p+1 ���h�� AR model    
    % ���l aj(s), s is selector
    s = 1;
    if (f==0.08)
        aj = [0.999, -0.0104, -0.0042];
    elseif (f == 0.05)
        aj = [0.9803, 0.0373, -0.0929];
    elseif (f == 0.025)
        aj = [0.9576, 0.0063, -0.1063];
    else
        aj = [0.5, 0.1, 0.9, 0.8, 0.4]; % �Ĥ@����ɭԪ��Ϊ� autoregresive gain
    end
    
    % TVAR gain �ثe�u�� p = 1
    a(i) = 0;
    for k = 1:p
        a(i) = a(i)+ aj(s) + h(i,te+1,k);
    end
    a(i) = -a(i); % �t���i�H���[
    for j = 1: p
        ar(i) = a(i).* xt(i-j) + ar(i);
    end
    
%     if(i == p+1+2)
        theta = 0.5;
        g = struct(...
            'p',p,'N',length(t),'te',te ,'i',i,... % series length (p+1):(te+1)
            'am',a,'ar',ar(1:i), 'input',xt ,'theta' ,theta ,'h', h,... % integral parameters
            'f', f, 't',t,'alpha',alpha ,'signal', signal_test... % signal fcn & input parameter
            );
        [tempD,tempR] = rate(g);
        D(i) = tempD;
        R(i) = tempR;
        fprintf('\niter: (%d/%d), D = %f, R = %f\n',i,te,D(i),R(i)); % DEBUG ��
%     end
end

figure();
subplot(3,1,1);plot(t,xt,t,ar);legend('xt','ar(p)');
subplot(3,1,2);plot(D(2:end),R(2:end));legend('R/D rate');

csvdata = zeros(length(t),3);
csvdata(:,1) = t;csvdata(:,2) = xt; csvdata(:,3) = ar;
% writematrix(csvdata,'test.csv');%no header 
% csvwrite(test.csv, t); % only one var
csv = array2table(csvdata);
csv.Properties.VariableNames(1:3) = {'t','with_noise','ar_p'};
writetable(csv,'ar.csv');

csvdata = zeros(length(D)-1,2);
csvdata(:,1) = D(2:end);csvdata(:,2) = R(2:end);
% writematrix(csvdata,'test.csv');%no header 
% csvwrite(test.csv, t); % only one var
csv = array2table(csvdata);
csv.Properties.VariableNames(1:2) = {'D','R'};
writetable(csv,'DR.csv');