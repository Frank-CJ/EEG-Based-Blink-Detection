Title: Eyeblink Master Library (Public Set in English)
Ver. 20140714

Author:  Won-Du Chang, ph.D, CoNE Lab, Department of Biomedical Engineering, Hanyang University
Contact: 12cross@gmail.com

This is the library to detect eyeblink artifact from a single channel EEG.


The main function is test_epochextract.m, which includes reading data file (*.txt) and finding contaminated epoch.

Try to run

>> test_epochextract

to check the sample result. I set to use the data from 0 to 60 seconds only.

- You can test this library by changing threshold and window widths. When the data changes, the parameters (thresholds and window widths should be adjsuted)


This library includs five *.m files, one data file (txt), and README.txt file. The simple descriptions of each files are as follows:

1. eogdetection_accdiff.m
	- a function to find eyeblink artifact ranges by using a newly developed algorithms.
2. epochextract.m
    - A function to extract epochs from time-series data. You can send the artifact information wheter each artifacts are included in each epoch or not as a parameter.

3. test_epochextract.m
    	- An example to use epochextract.m

%	    epoch_duration: duration of epoch
%	    epoch_overlaptime: duration of overlapping time for adjusted epochs
%           artifact_process_mode:  0: ignore artifacts (default) 
%                                   1: substitute adjusted epochs for contaminated epochs artifact
%                                   2: remove contaminated epochs (assign null)
	e.g. 	test_epochextract (1, 0.1, 1)  

4. calMultiSDW.m
	- function for MSDW calculation

5. highpass_simple
	- highpass filter by using filtfilt2 function

6. sample.txt
	- sample data

7. README.txt
	- README file

