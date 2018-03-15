## Parses .CSV DigiTrack logfiles to calculate event lists + adds them to EEGLab

**NOTE: All scripts are created for a particular experiment, but can be extended later. These are work files which are, in most cases, working only for a specified datasets. More comments and further explanation will be given soon.**

- For internal IBD "Ships" project, but can be customized for any other project
- All scripts regarding working with .EDF/.CSV files from Elmiko DigiTrack system

***

(1) Adding events with EEGlab from Elmiko DigiTrack .csv and .evx files
	- Calculates events latency from .CSV logfiles (computer's time) to milliseconds
	- Creates .txt files with event list
	- Adds events to the EEG signal using EEGlab
	
***

**INFO_EVENTY.txt** -> Instructions in polish for understanding events codes
- Comments inside the scripts are for now in polish only.

**Scripts need two other functions from MATLAB community:**
- struct2File.m and xml2struct.m (added here)

**Event_list_SHORT.m**
Input:
- .csv file from the DigiTrack "Ships" experiment
- .evx file from the DigiTrack experiment 

**Output:**
- .txt list of calculated events latency in 'short' version (sample: EventList_SHORT.txt)


**Event_list_FULL.m**
- Same as above, but creates 'full' version of the events
- Sample: EventList_FULL.txt


**Adding_events_to_EEG_signal_EEGLab.m**
- Adds events from previously created .txt list to already opened EEG file in EEGLab
