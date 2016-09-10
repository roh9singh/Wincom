clear 
clc
close all


%% Load the Data 

DateString = '01-Jan-2013';
formatIn = 'dd-mmm-yyyy';
days=14

Dt=DateString
load(['Full/' DateString '.mat'])
load(DateString)



start=763
stop=775
s=0;
f=0;
i=0;


for i=1:size(band_index,1)
    
    if start>=band_index(i,1) && start<band_index(i,2)
        
        rows=i
        if start==band_index(i,1)
            s=1
        else
            s=floor((start-band_index(i,1))/((band_index(i,2)-band_index(i,1))/size(Power_Dt,1)))
        end
    end

    if stop>=band_index(i,1) && stop<=band_index(i,2)      
        rowf=i
        if stop==band_index(i,2)
            f=size(Power_Dt,1)
        else
            f=ceil((stop-band_index(i,1))/((band_index(i,2)-band_index(i,1))/size(Power_Dt,1)))
        end
    end
end




%%

%%%%%%%%%%%%%%First Find the Noise Floor of the band for a week

NoiseFloor=[];
Occu=[]
Peaks(1:f-s,1:days)=NaN;
PeaksI(1:f-s,1:days)=NaN;

for date=1:days

    try 
        load(['Full/' Dt '.mat'])

        P=10.^(Power_Dt/10);


        if rows==rowf
           x=squeeze(P(:,rows:rowf,:));
           x=squeeze(x(s:f,:));
        else
           x=squeeze(P(s:size(Power_Dt,1),rows,:));
            for i=rows+1:rowf
               if i==rowf
                   x=[x;squeeze(P(1:f,rowf,:))];
               else
                   x=[x;squeeze(P(:,i,:))];
               end
            end 
        end

        %%%%%%%%%%%%%%%%%%Plot the PvsF

        Y=10*log10(mean(x,2));

        %figure(date)
        %plot(Y,'DisplayName','Y','YDataSource','Y');

        [e,l]=findpeaks(double(Y));

        for j=1:length(l)
            PeaksI(l(j),date)=1;
            Peaks(l(j),date)=e(j);
        end



        %%%%%%%%%%%%%%%%%%First find the Histogram for the band for a day

        Y=10*log10(x(:)');

        %histfit(Y,200,'kernel');
        [a,b]=hist(Y,200);

        %plot(b,smooth(a,5))

        [M,I]=max(a);

        NoiseFloor=[NoiseFloor,b(I)];



        %%%Increment the date by 24hrs
        Base_Time=(floor(86400 * (datenum(Dt) - datenum('01-Jan-1970')))) + 18000 + (24*60*60) ;
        Date=datestr(datenum('01-Jan-1970 ')+((Base_Time-18000)/86400),'dd-mmm-yyyy');
        Dt=Date
    catch
        disp('Nodata')
        NoiseFloor=[NoiseFloor,NaN];
        Base_Time=(floor(86400 * (datenum(Dt) - datenum('01-Jan-1970')))) + 18000 + (24*60*60) ;
        Date=datestr(datenum('01-Jan-1970 ')+((Base_Time-18000)/86400),'dd-mmm-yyyy');
        Dt=Date
    end
end


N=nanmean(NoiseFloor)


%%
%%%%To find the Occupency of a band 


Occu=[]
Dt=DateString

for date=1:days
    
    try
        load(['Full/' Dt '.mat'])

        P=Power_Dt;

        if rows==rowf
           x=squeeze(P(:,rows:rowf,:));
           x=squeeze(x(s:f,:));
        else
           x=squeeze(P(s:size(Power_Dt,1),rows,:));
            for i=rows+1:rowf
               if i==rowf
                   x=[x;squeeze(P(1:f,rowf,:))];
               else
                   x=[x;squeeze(P(:,i,:))];
               end
            end 
        end

        x=x(:)';
        
        Occu=[Occu,length(x((x>N)==1))/length(x)];


        %%%Increment the date by 24hrs
        Base_Time=(floor(86400 * (datenum(Dt) - datenum('01-Jan-1970')))) + 18000 + (24*60*60) ;
        Date=datestr(datenum('01-Jan-1970 ')+((Base_Time-18000)/86400),'dd-mmm-yyyy');
        Dt=Date
    catch
        disp('Nodata')
        Occu=[Occu,NaN];
        Base_Time=(floor(86400 * (datenum(Dt) - datenum('01-Jan-1970')))) + 18000 + (24*60*60) ;
        Date=datestr(datenum('01-Jan-1970 ')+((Base_Time-18000)/86400),'dd-mmm-yyyy');
        Dt=Date
    end
end

O=nanmean(Occu)


saveString=['Data-2013-' num2str(start) '-' num2str(stop)]
save (saveString, 'PeaksI', 'Peaks', 'NoiseFloor', 'N', 'Occu', 'O')
