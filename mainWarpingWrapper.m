function [fn,gam,qn] = mainWarpingWrapper(t,f,dispFlag)

binsize = mean(diff(t));
[M, N] = size(f);
f0 =f;

%% compute the q-function of the plot 
for i = 1:N
    q(:,i) = gradient(f(:,i), binsize)./sqrt(abs(gradient(f(:,i), binsize))+eps);
end

%%% set initial using the original f space
disp(sprintf('\n Initializing...\n'));
mnq = mean(q,2);
dqq = sqrt(sum((q - mnq*ones(1,N)).^2,1));
[ignore, min_ind] = min(dqq);
mq = q(:,min_ind); 
mq = q(:,ceil(rand*N));



%%% compute mean
disp(sprintf(' Computing amplitude mean of %d functions in SRVF space...\n',N));
ds = inf; 
MaxItr = 20;
for r = 1:MaxItr
    disp(sprintf('updating step: r=%d', r)); 
    if r == MaxItr
        disp(sprintf('maximal number of iterations is reached. \n'));
    end   
    
    ds(r+1) = sum(trapz(t, (mq*ones(1,N)-q).^2))
    %%%% Matching Step %%%%
    clear gam gam_dev;
    
    %% Find the mean amplitude function
    for k = 1:N
        q_c = q(:,k)'; mq_c = mq';
        gam0 = DynamicProgrammingQ_Adam(q_c/norm(q_c),mq_c/norm(mq_c),0,0)';
        gam(k,:) = (gam0-gam0(1))/(gam0(end)-gam0(1));
        
        
        fn(:,k) = interp1(t, f0(:,k), (t(end)-t(1)).*gam(k,:) + t(1))';    
        qn(:,k) = gradient(fn(:,k), binsize)./sqrt(abs(gradient(fn(:,k), binsize))+eps);
    end
    
            
    
    %%%% Minimization Step %%%
    % compute the mean of the matched function
    mqold = mq;
    mq = mean(qn,2);
    
    qun(r) = norm(mq-mqold)/norm(mqold);
    if (ds(r) < ds(r+1) || qun(r) < 1e-3)
        break;
    end
end

%% Centering in the orbit
disp(sprintf('Centering the mean function in its orbit...\n',N));
    gamI = SqrtMeanInverse(gam);
    gamI_dev = gradient(gamI, 1/(M-1));
    mq = interp1(t, mq, (t(end)-t(1)).*gamI + t(1))'.*sqrt(gamI_dev');
    for k = 1:N
        q_c = q(:,k)'; mq_c = mq';
        gam0 = DynamicProgrammingQ_Adam(q_c/norm(q_c),mq_c/norm(mq_c),0,0);
        gam(k,:) = (gam0-gam0(1))/(gam0(end)-gam0(1));
        
        
        fn(:,k) = interp1(t, f0(:,k), (t(end)-t(1)).*gam(k,:) + t(1))';   
    end        


if(dispFlag)
figure(1); clf; axes('FontSize',20);
plot(t, f0, 'linewidth', 2);
title('Original data', 'fontsize', 16);
%pause(0.1);
set(gca,'FontSize',20);

figure(2); clf;axes('FontSize',20);
plot((0:M-1)/(M-1), gam, 'linewidth', 2);
axis square;
title('Warping functions', 'fontsize', 16);
set(gca,'FontSize',20);

figure(3); clf;axes('FontSize',20);
plot(t, fn, 'LineWidth',2);
title('Warped data', 'fontsize', 16);
set(gca,'FontSize',20);

end


