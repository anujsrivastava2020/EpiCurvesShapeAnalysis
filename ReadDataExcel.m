function [f,TXT,RAW,T,n,sDate,sDateD] = ReadDataExcel(usa,world, Tstart, Tend)

%% File Reading
   
    if usa
        filen = sprintf('../ExcelData/US_COVID_tracking_5_12.xlsx');
        [NUM,TXT,RAW]=xlsread(filen,1);
        [T,n]= size(NUM);
        f = NUM(Tstart+1:T-Tend,2:n-1);
        sDate = datetime(NUM(Tstart+1:T-Tend,1),'ConvertFrom','excel','format','MM/dd');
        sDateD = sDate(1:end-1);
    elseif world
        filen = sprintf('../ExcelData/WHO_countries_May16.xlsx');
        [NUM,~,RAW]=xlsread(filen,5); %5, 8
        NUM= NUM';
        
        %% Removing Monaco
        NUM(:,36) = [];
        %NUM(:,59) = [];
        RAW(36,:)= [];
        %RAW(59,:)= [];
        
        
        [T,n]= size(NUM);
        f = NUM(Tstart+1:T-Tend,2:n);       
        sDate = datetime(NUM(Tstart+1:T-Tend,1),'ConvertFrom','excel','format','MM/dd');
        sDateD = sDate(1:end-1);
        
        TXT = RAW(2:end-2,1);      
    end
    [T,n]= size(f);