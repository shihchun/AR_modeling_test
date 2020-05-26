clear all; clc;
% parameter
N = 100; % quantity of samples
e = randn(N);
e = e / max(e);

% es = sin((1:N))+ sin((1:N).*2+10); % add sin sin wave
% e = 1./6.*(es'+e); % es' is transpose result of es

a = [];
sets = 5; % test sets
lag = 5; % AR(p) p is lag
% (N-lag)>=2 need to be true(==1), '>1' -> lag ,'>2' integral

% Generate the a(r) AR is not able to linear regression but just test
% time varying a --> design varying a
for i = 1:N
    a(i) = (i/N); 
end
ac = zeros(sets,1); % index sets with constant
ac = [0.1, 0.9, -0.9 ,0.3, 0.5]; % constant close to 0, 1...

x = zeros(N,sets);
xc = zeros(N,sets); % 初始化矩陣大小 constant

for j =1:lag % lag not calc
    for i = 1:5 % which data
        x(j,i) = 0; % a(i).*x(j,i)+e(j);
        xc(j,i) = 0; % ac(i).*x(j,i)+e(j);
    end
end
sigma = zeros(1,N); theta = zeros(1,N); r = zeros(1,N); omega = zeros(1,N);
g = zeros(1,N); xx = zeros(1,N); nn = zeros(1,N);
% omega and m don't know the const values
for j = 1:sets % 這裏開始計算distortion rate N-lag-1 筆資料
    for i = (1+lag):N % calc start from AR(p->lag) --> lag+2
        xc(i,j) = ac(j).*x(i-lag,j)+e(i); % 對照組 constant a
        x(i,j) = a(i).*x(i-lag,j)+e(i);
    end
end
sets = 1;
for j = 1:sets % 這裏開始計算distortion rate N-lag-1 筆資料
    for i = (1+lag):N % calc start from AR(p->lag) --> lag+2
        xc(i,j) = ac(j).*x(i-lag,j)+e(i); % 對照組 constant a
        x(i,j) = a(i).*x(i-lag,j)+e(i);
        g_struct = struct('sets_index_now',j,'data_index_now',i,'lag_p',lag,...
            'samples',N, 'varing_gain',a,'predict',x,'noise',(e.*0.9), 'input',e );
        sigma(i) = var(g_struct.predict(:,1)); % get the varience
        theta(i) = max(g_struct.predict(:,1)) - sigma(i)./4; % 暫時這麼算 上限 upper threshold
        r(i) = g_struct.varing_gain(i);
        omega(i) = 2.71828;
        x_in = g_struct.predict(:,1);% x(:,1), x(:,2) is the same...
        % calc g value
        % calcl the g
        g = zeros(length(omega),g_struct.samples);
        for ii = 1:length(omega)
            g(ii,:) = 1./( (sigma).^2 ).*abs(1+ sum(x_in .* exp(-j.*g_struct.varing_gain.*omega(ii)) ) ).^2;
        end
        
        k= 1./g;
        k_flat = reshape(k.',1,[]);
        % find the index of minumax value
        % find( k == min( k(k>theta) ),1,'last'); %get error when k<theta but works
        index = find( k_flat == min( k_flat(k_flat>0) ),1,'last');
        [ii,jj] = find(k == k_flat(index),1,'last'); % 從後面找積分項數比較多的一項
        
        %g(i) = 1./(sigma(i).^2).* abs(1 + sum(1 + x_in.*exp(-j.*length(N-lag+1).*omega(i)))).^2;% omega暫時用2.71828
        % min(g(g~=0)) % g的最小數值
        %ind = find(g == min( g(g>0) ),1,'last'); % 偷吃步一下, 找曲線波動滿有用的
        ind =jj;
        % g(ind) % g的最小值代入ind這一項
        %D_theta = @(r,w) 1./( 1./(sigma(i).^2).* abs(1 + sum(1 + s(i,:).*exp(-j.*length(s(i,:)).*w))).^2 );
        for lengths = 1:length(g_struct.predict(:,1))
            xx(i) = g_struct.predict(i,1);
            %nn = g_struct.noise(i,1);
            nn(i) = 0.212826888264831; % set to const now
            %r = g_struct.data_index_now(i)/g_struct.samples;
            r(i) = a(i);
        end
        str1 = '@(r,w)1./( 1./(';
        str2 = string(sigma(i));
        str3 = ').^2).*abs(1+(';
        for indd = 1:ind % strings of sum part
            list = ['((', string(a(i)), ').*r','+' , '(',string(nn(i)),')']; % x 要改成跟 r.*(輸入_const)+ noise_const
            str4 = sprintf( list(1)+list(2)+list(3) ); 
            str5 = ').*exp(-j.*(';
            str6 = string(indd); % exp(-j.*omega.*m) whatis m?
            str7 = ').*w)+';
            str8 = ').*w)';
            list_fn(indd) = sprintf(str4+str5+str6+str7);
            if indd == ind
                list_fn(indd) = sprintf(str4+str5+str6+str8);
            end
        end
        strff = '';
        for indd = 2:ind
            str9 = strff;
            strff = sprintf(str9+list_fn(indd-1)+list_fn(indd));
        end
        strfin = ').^2)';
        str_intgral_D = sprintf(str1+str2+str3+strff+strfin); % for D
        D_integral_fun = str2func(str_intgral_D); % struct()
        D = integral2(D_integral_fun, 0,1, -pi, pi);
        
        str11 = '@(r,w)1./2.*log(1./';
        str12 = string(theta(i)); % multiple min value of 1/g -integral-> D (1/g), use D
        str13 = './( 1./('; 
        strfin = ').^2))';
        str1 = sprintf(str11+str12+str13);
        str_intgral_R  = sprintf(str1+str2+str3+strff+strfin);
        R_integral_fun = str2func(str_intgral_R); % struct()
        R = integral2(R_integral_fun, 0,1, -pi, pi);
        Deq(i) = D;
        Req(i) = R;
        fprintf('\n\n(iter,Deq,Req): (%d,%d,%d) \n\n',i,D,R);
    end
end
clearvars str11 str12 str13 str1 str2 str3 str4 str5 str6 str7 str8 str9 strff strfin list list_fn;
ind % use this minimum value in the final iteration
str_intgral_D % the last one integral calc
str_intgral_R % the last one integral calc
D
R
% calc end %
% print the distortion rate of x(lag:N) t in [lag, N]
% Plot
str1 = ['AR', '(', string(lag), ')' ];
t = linspace(1,N,N);
ylimit_const = [-0.6, 0.6];
AR = sprintf( str1(1)+str1(2)+str1(3)+str1(4));

figure();
subplot(3, 1, 1);
plot(t(lag:end),e(lag:end));
hold on;
plot(t(lag:end),xc(lag:end,1));
title('gain of a = 0.1 close to 0');
xlim([lag, N]); %xlim(0, N);
ylim(ylimit_const); %ylim(-2, 2);
xlabel('samples');
ylabel('e, x') ;
% legend(['noise', 'AR(2)'], loc='best');
% tight_layout(pad=0.5, w_pad=0.5, h_pad=1.0);
legend('noise', AR)
subplot(3, 1, 2);
plot(t(lag:end),e(lag:end));
hold on;
plot(t(lag:end),xc(lag:end,2));
title('gain of a = 0.9 close to 1')
xlim([lag, N]); %xlim(0, N);
ylim(ylimit_const); %ylim(-2, 2);
xlabel('samples');
ylabel('e, x') ;
% legend(['noise', 'AR(2)'], loc='best');
% tight_layout(pad=0.5, w_pad=0.5, h_pad=1.0);
legend('noise', AR)
subplot(3, 1, 3);
plot(t(lag:end),e(lag:end));
hold on;
plot(t(lag:end),x(lag:end,1));
title('gain of a = r, r = t/N')
xlim([lag, N]); %xlim(0, N);
ylim(ylimit_const); %ylim(-2, 2);
xlabel('samples');
ylabel('e, x') ;
% legend(['noise', 'AR(2)'], loc='best');
% tight_layout(pad=0.5, w_pad=0.5, h_pad=1.0);
legend('noise', AR)
figure()
plot(Deq,Req);
xlabel('D');
ylabel('R') ;
title('distortion D/R');