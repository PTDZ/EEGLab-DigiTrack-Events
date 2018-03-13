
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   TWORZY LISTÊ D£UGICH EVENTÓW
%%%   1. TRZEBA WEJŒÆ DO FOLDERU Z PLIKAMI BADANIA I NACISN¥Æ "RUN" NA GÓRNEJ
%%%   BELCE MATLABA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Szuka pliku .evx i .csv w danym folderze
CSV_name = dir('*.csv');
EVX_name = dir('*.evx');

%% CZAS ROZPOCZECIA W MS
    IKS = sprintf(EVX_name.name);
    xml2struct(IKS);
    newStr = ans.events.type{1, 1}.event.info.Attributes.time;
    %newStr3 = '13:33:47.198';
    newStr2 = extractAfter(newStr,'T');
    newStr3 = extractBefore(newStr2,'+');
    C = strsplit(newStr3,':');
    X = str2double(C);
    StartingTimeinMill = (X(1)*3600000)+(X(2)*60000)+(X(3)*1000);
    clearvars newStr newStr2 newStr3 C X ans IKS
    
 %% WGRYWANIE PLIKU CSV
    filename = sprintf(CSV_name.name);
    delimiter = ','; startRow = 3; endRow = 102; formatSpec = '%*s%*s%*s%s%*s%s%*s%*s%s%*s%*s%*s%s%*s%*s%*s%*s%*s%s%*s%s%s%*s%*s%*s%s%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID); 
    
% kolejnoœæ: iti_time, accuracy, key_time, probe_time, sample_ship,
% target_ship, target_time, trial_type
    info = cellstr([dataArray{1:end-1}]);
    clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;

%% TylkoCzasy
%ITI_Time, Key_Time, Probe_Time, Target_Time
    TylkoCzasy = horzcat(info(:,1),info(:,3),info(:,4),info(:,7));
    
%% Obliczenie czasu dla wszystkich kolumn
    [~,n] = size(TylkoCzasy);
    for ii = 1:n
        for kk = 1:length(info)  
            newStr = TylkoCzasy{kk,ii};
            SamaGodzina = extractAfter(newStr,' ');
            C = strsplit(SamaGodzina,':');
            X = str2double(C);
            TimeStamp = (X(1)*3600000)+(X(2)*60000)+(X(3)*1000);
            ObliczoneCzasy{kk,ii} = TimeStamp - StartingTimeinMill;
        end
        clearvars C kk newStr SamaGodzina X TimeStamp   
    end
        clearvars ii m n TylkoCzasy StartingTimeinMill

%% TylkoInfoWKolenoœci
% Trial Type | Poprawnoœæ | Sample Ship | Target Ship
    TylkoInfo = horzcat(info(:,8),info(:,2),info(:,5),info(:,6));
    clearvars info
%% Trial Type - kodowanie
% match: 1, non_match: 0; control_horizontal: 2; control_vertical: 3;  
    [n,m] = size(TylkoInfo);
    Przekodowane = cell(n,m); %prealokacja
    Przekodowane{n,m} = [];
    
    for ii = 1:length(TylkoInfo)           
        sprawdzam = TylkoInfo{ii,1};         
        if strcmpi(sprawdzam,'match') == 1
            Przekodowane{ii,1} = '1';
        elseif strcmpi(sprawdzam,'non_match') == 1
            Przekodowane{ii,1} = '0';
        elseif strcmpi(sprawdzam,'control_horizontal') == 1
            Przekodowane{ii,1} = '2';
        elseif strcmpi(sprawdzam,'control_vertical') == 1
            Przekodowane{ii,1} = '3';
        end          
    end  
%% OdpowiedŸ - kodowanie
% correct: 1, wrong: 0; dont know: 2    
     for ii = 1:length(TylkoInfo)           
        sprawdzam = TylkoInfo{ii,2};         
        if strcmpi(sprawdzam,'correct') == 1
            Przekodowane{ii,2} = '1';
        elseif strcmpi(sprawdzam,'wrong') == 1
            Przekodowane{ii,2} = '0';
        elseif strcmpi(sprawdzam,'dont know') == 1
            Przekodowane{ii,2} = '2';
        end          
     end  
    
%% Nazwa SampleShip i TargetShip - kodowanie
% ellipse = 'ell'
     for ii = 1:length(TylkoInfo)  
         
         newStr = TylkoInfo{ii,3};
         newStr1 = extractBefore(extractAfter(newStr,'_'),'.png');
         Przekodowane{ii,3} = newStr1;
         
         newStr2 = TylkoInfo{ii,4};
         
         if strcmpi(newStr2,'ellipse') == 1
            Przekodowane{ii,4} = 'ell';
         else
            newStr3 = extractBefore(extractAfter(newStr2,'_'),'.png');
            Przekodowane{ii,4} = newStr3;
         end
         
     end
clearvars ii m n newStr newStr1 newStr2 newStr3 sprawdzam TylkoInfo

%% Kod próby w ca³oœci
for ii = 1:length(Przekodowane)
    Przekodowane{ii,5} = horzcat(Przekodowane{ii,1:4});
end
clearvars ii

%% Kod próby + Pocz¹tek
%ITI_Time - S (start), Key_Time - R (response), Probe_Time - P, Target_Time - T    
for ii = 1:length(Przekodowane)
    Przekodowane{ii,6} = strcat('S_',Przekodowane{ii,5});
    Przekodowane{ii,7} = strcat('R_',Przekodowane{ii,5});
    Przekodowane{ii,8} = strcat('P_',Przekodowane{ii,5});
    Przekodowane{ii,9} = strcat('T_',Przekodowane{ii,5}); 
end
clearvars ii

%% Listy Eventów dla EEGLABA ->
% Jedna wspólna tabela dla wszystkich eventów + dodane event kody
Type = cellstr(vertcat(Przekodowane{:,6:9}));
Latency = vertcat(ObliczoneCzasy{:,1:4});
T = table(Latency, Type);
T = sortrows(T,1); 

%% Zapis do pliku
writetable(T,'EventList_FULL.txt','Delimiter','\t');  
clearvars CSV_name EVX_name Latency ObliczoneCzasy Przekodowane T Type
