
%   Adding events to EEG signal in EEGLab
%%
%   Sampling rate; change sampling rate only if it's needed
%   Here it's needed for 'Ships' experiment and badly saved .EDF files
    EEG.srate = 499.993987569999;
    eeglab redraw
%%    
%   Adding events
%   File name with events info; may be 'EventList_FULL.txt' or
%   'EventList_SHORT.txt'
    IKS = sprintf('EventList_FULL.txt');    
    EEG = eeg_checkset(EEG);
    EEG = pop_importevent(EEG,'event',IKS,'fields',{'latency' 'type'},'skipline',1,'timeunit',0.001);
    eeglab redraw