
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   TWORZY LISTÊ KRÓTKICH EVENTÓW
%%%   1. TRZEBA WEJŒÆ DO FOLDERU Z PLIKAMI BADANIA I NACISN¥Æ "RUN" NA GÓRNEJ
%%%   BELCE MATLABA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Szuka pliku .evx i .csv w danym folderze
CSV_name = dir('*.csv');
%EVX_name = dir('*.evx');

EVX_name = dir('*.eef');

%% CZAS ROZPOCZECIA W MS
    IKS = sprintf(EVX_name.name);
    xml2struct(IKS);
    %newStr = ans.events.type{1, 1}.event.info.Attributes.time;
    newStr = ans.ElmikoExamFile.exam.info.versions.version.Attributes.creationTime;
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
    
%% Usuniêcie nieistotnych kolumn (dla "krótkiej" wersji)
% kolejnoœæ: accuracy, key_time, target_time, trial_type
    TylkoIstotne = horzcat(info(:,2),info(:,3),info(:,7),info(:,8));
    clearvars info 
    
%% TylkoCzasy
% Key_Time, Target_Time
    TylkoCzasy = horzcat(TylkoIstotne(:,3),TylkoIstotne(:,2)); 
    
%% Obliczenie czasu dla wszystkich kolumn
    [~,n] = size(TylkoCzasy);
    for ii = 1:n
        for kk = 1:length(TylkoCzasy)  
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
% Trial Type | Poprawnoœæ
    TylkoInfo = horzcat(TylkoIstotne(:,4),TylkoIstotne(:,1));
    clearvars info
    
%% Trial Type - kodowanie
% match + non_match = ATT; cont_hor + contr_ver = CON
    
    [n,m] = size(TylkoInfo);
    Przekodowane = cell(n,m); %prealokacja
    Przekodowane{n,m} = [];
    
    for ii = 1:length(TylkoInfo)           
        sprawdzam = TylkoInfo{ii,1};         
        if strcmpi(sprawdzam,'match') == 1
            Przekodowane{ii,1} = 'ATT';
        elseif strcmpi(sprawdzam,'non_match') == 1
            Przekodowane{ii,1} = 'ATT';
        elseif strcmpi(sprawdzam,'control_horizontal') == 1
            Przekodowane{ii,1} = 'CON';
        elseif strcmpi(sprawdzam,'control_vertical') == 1
            Przekodowane{ii,1} = 'CON';
        end          
    end  
%% OdpowiedŸ - kodowanie
% correct: CRT, wrong: WRG; dont know: DNT  
     for ii = 1:length(TylkoInfo)           
        sprawdzam = TylkoInfo{ii,2};         
        if strcmpi(sprawdzam,'correct') == 1
            Przekodowane{ii,2} = 'CRT';
        elseif strcmpi(sprawdzam,'wrong') == 1
            Przekodowane{ii,2} = 'WRG';
        elseif strcmpi(sprawdzam,'dont know') == 1
            Przekodowane{ii,2} = 'DNT';
        end          
     end  
clearvars ii m n newStr newStr1 newStr2 newStr3 sprawdzam TylkoInfo TylkoIstotne
%% Kod próby w ca³oœci
for ii = 1:length(Przekodowane)
    Przekodowane{ii,3} = strcat(Przekodowane{ii,1},'_',Przekodowane{ii,2});
    Przekodowane{ii,4} = 'RESPONS'; % równa liczba znaków z po³¹czonym kodem - dlatego response bez "e"
end
clearvars ii
%% Listy Eventów dla EEGLABA ->
% Jedna wspólna tabela dla wszystkich eventów + dodane event kody
Type = vertcat(Przekodowane{:,3:4});
Latency = vertcat(ObliczoneCzasy{:,1:2});
T = table(Latency, Type);
T = sortrows(T,1); 
%% Zapis do pliku
writetable(T,'EventList_SHORT.txt','Delimiter','\t');  
clearvars CSV_name EVX_name Latency ObliczoneCzasy Przekodowane T Type
