%% This is a matlab code for clustering epidemic growth rate curves into a given
%% number of clusters and then computing average shape in each cluster
%% The code reads in the cumulative data from an excel file for a number of places
%% (states or countries)

%% Input -- name of the Excel file entered in "ReadDataExcel" function
%% Output -- A set of displays of clustered and aligned curves




    clear;
    %%
    usa = 1;
    world = 0;
    
    
    %% Read Data from Excel File
    Tstart = 0;
    Tend = 3;
    [f,TXT,RAW,T,n,sDate,sDateD] = ReadDataExcel(usa,world, Tstart, Tend);
    forig = f;
    
   

%% Form growth rate curves

    %% Smooth thecumulative count data
    for i=1:n
        f(:,i) = smooth(f(:,i),5);
    end   
    
    %% Take finite differences
    g= diff(f);
    gold = g;
    for i=1:n
        rr(i) = sum(g(:,i));
        g(:,i) = g(:,i)/rr(i);
    end
    scMat = diag(rr);
    
    %% Smooth
    t =  (0:T-2)/(T-2);
    for i=1:n
        g(:,i) = smooth(g(:,i),5);       
    end    
    binsize = mean(diff(t));
   
    
    %% Display Data
    dTicks = sDateD(1:20:end);
    
    figure(100); clf; 
    subplot(1,4,1);
    plot(sDate,forig,'LineWidth',2);
    xticks(dTicks);
    title('Cumulative Count Data');
    set(gca,'fontsize', 20);
    ylim([0 inf]);
    xlim([min(sDate) max(sDate)]);
    pbaspect([ 1 1 1]);
    
    subplot(1,4,2);
    plot(sDateD,gold,'LineWidth',2);
    xticks(dTicks);
    title('Daily New Incidences');
    set(gca,'fontsize', 20);
    ylim([0 inf]);
    xlim([min(sDate) max(sDate)]);
    pbaspect([ 1 1 1]);
    
    subplot(1,4,3);
    plot(sDateD,g,'LineWidth',2);
    xticks(dTicks);
    title('Smoothed and Scaled');
    set(gca,'fontsize', 20);
    ylim([0 inf]);
    xlim([min(sDate) max(sDate)]);
    pbaspect([ 1 1 1]);
     
    subplot(1,4,4); hold on;
    %plot(sDateD,mean(g,2),'LineWidth',2);
    plot(sDateD,mean(gold,2),'LineWidth',2);
    xticks(dTicks);
    title('Gross Overall Average Curve');
    set(gca,'fontsize', 20);
    ylim([0 inf])
    xlim([min(sDate) max(sDate)]);
    pbaspect([ 1 1 1]);
    box;
    
    sgtitle('Preprocessing of daily count data to form growth rate curves','FontSize',30);

 
    
    
    %% Clustering Using pairwise distances   
    D = zeros(n);
    cnt = 1;
    for i=1:n
        for j=i+1:n
            D(i,j) = norm(g(:,i) - g(:,j));
            YY(cnt) = D(i,j);
            cnt = cnt + 1;
        end
    end
    
    
    figure(600);
    nClust = 4;
    Z = linkage(YY,'ward');
    color = Z(end- nClust+2,3)-eps; 
    [h,TT,outperm]= dendrogram(Z,0,'orientation', 'right', 'colorthreshold', color); %,'reorder',leafOrder); %   
    set(h,'LineWidth',3);
    set(gca,'YTickLabel', TXT(outperm));
    set(gca,'fontsize', 16);
    CC = cluster(Z,'MaxClust',nClust);
    box;

    %% Display
    figure(101); clf; 
    for i=1:nClust
        subplot(1,nClust,i);
        id = find(CC == i);
        plot(sDateD,g(:,id)*scMat(id,id), 'LineWidth',2); %*scMat(id,id)
        xticks(dTicks);
        ylim([0 inf])
        xlim([min(sDateD) max(sDateD)]);
        pbaspect([ 1 1 1]);
        set(gca,'fontsize', 18);
        sgtitle('Daily Covid-19 Counts in Each Cluster','FontSize',30);
    end

    
    %% Compute Cluster Means and Display
    
    figure(200); clf;
    sgtitle('Aligned and Scaled Growth Curves in Each Cluster','FontSize',30);
    figure(250); clf;
    sgtitle('Aligned Covid-19 Daily Counts in Each Cluster','FontSize',30);
    figure(300); clf; 
    sgtitle('Average Shapes of Growth Curves in Each Cluster','FontSize',30);

    for i=1:nClust
        str= sprintf('id%d = find(CC == %d);',i,i);
        eval(str);
        
        str = sprintf('id = id%d',i);
        eval(str);
        if length(id) > 1
            [fnn,gam,qn] = mainWarpingWrapper(t,g(:,id),0);
        else
            fnn= g(:,id);
        end
          
        figure(200);
        subplot(1,nClust,i);
        %plot(sDate,fnn*scMat(id,id),'LineWidth',2);
        plot(sDateD,fnn,'LineWidth',2);
        xticks(dTicks);
        ylim([0 inf]);
        xlim([min(sDateD) max(sDateD)]);
        pbaspect([ 1 1 1]);
        set(gca,'fontsize', 20);
        
        figure(250);
        subplot(1,nClust,i);
        plot(sDateD,fnn*scMat(id,id),'LineWidth',2);
        %plot(sDate,fnn,'LineWidth',2);
        xticks(dTicks);
        ylim([0 inf]);
        xlim([min(sDateD) max(sDateD)]);
        pbaspect([ 1 1 1]);
        set(gca,'fontsize', 20);
     
        cmean(:,i)= mean(fnn,2);
        
        figure(300);
        subplot(1,nClust,i);
        if length(id) > 1
            snn= std(fnn');
            plot(sDateD,mean(fnn,2),'m','LineWidth',2); hold on; 
            plot(sDateD,mean(fnn,2)-snn','-.b','LineWidth',1); 
            plot(sDateD,mean(fnn,2)+snn','-.b','LineWidth',1);
            %plot(sDate,mean(g(:,id)'),'k','LineWidth',2); 
        else
            plot(sDateD,fnn,'m','LineWidth',2); hold on; 
            plot(sDateD,g(:,id),'k','LineWidth',2); 
        end
        xticks(dTicks);
        ylim([0 inf]);
        xlim([min(sDateD) max(sDateD)]);
        set(gca,'fontsize', 20);
        pbaspect([ 1 1 1]);
    end
    
    figure(800); clf;
    plot(sDateD,cmean,'LineWidth',3);
    xticks(dTicks);
        ylim([0 inf]);
        xlim([min(sDateD) max(sDateD)]);
        pbaspect([ 1 1 1]);
        set(gca,'fontsize', 18);
        legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5');
        sgtitle('Average Growth Curves in Each Cluster','FontSize',30);
    for i=1:nClust
        str= sprintf('string(strjoin(TXT(id%d)))',i);
        eval(str);
    end

    
    %% Save the final results for map display
    if usa
        save StateClusterNames;
    elseif world
        save EuropeClusterNames;
    end