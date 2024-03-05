%%%%%%%%%%%% Seaglider SG639 in Gulf of Mexico, May-June 2018 %%%%%%%%%%%%

timeIncr = 1 / (24*60*60);	% check all detections
% timeIncr = 1;			% check one detection per day

% Sound files and index:
snddir = 'G:\GoMex2018\wav\sg639-10kHz\';
indexpath = [snddir 'file_dates-GoMex_2018_sg639.txt'];

% Log files:
logdir   = 'C:\Users\fregosi\Desktop\checkDetectionsCode\ishDetectorRuns\'; 	% log file(s)
inlogpath  = [logdir 'gliderPumpNoise-MF_SG639_GoMex2018_run20190405.log'];
outlogpath = [pathRoot(inlogpath) '-checked.log'];

% Display info:
displayFreq = [0 5e3];	% freq range to show in Osprey
selectFreq  = [0 5e3];	% freq range shown in yellow for detection
padTime     = [2 4];	% time shown to either side of detection, s
maxDispSec = 120;
selectTimePad = [0.5 0.5];	% time offset for selection
searchstr = 'gliderNoiseMF'; % label of each call detected