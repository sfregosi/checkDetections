%%%%%%%%%%%% Example checkDetections config file %%%%%%%%%%%%
% works with example log and sound file in the "example" directory

timeIncr = 1 / (24*60*60);	% check every detections
% timeIncr = 1;			% check one detection per day

% Sound files and index file:
snddir = 'C:\Users\Selene.Fregosi\Documents\MATLAB\checkDetections\example\'; % dir containing raw wavs (or flacs?)
indexpath = [snddir 'file_dates-GoMex_2018_sg639.txt']; %fileDates File 
   % if you don't have one of these, make it with XXXXXXXXXXXXXX

% Log files:
logdir   = 'C:\Users\Selene.Fregosi\Documents\MATLAB\checkDetections\example\'; % log file(s)
inlogpath  = [logdir 'example_logfile.log'];
outlogpath = [pathRoot(inlogpath) '-checked.log'];

% Display info:
displayFreq = [0 5e3];	% freq range to show in Osprey
selectFreq  = [0 5e3];	% freq range shown in yellow for detection
padTime     = [2 4];	% time shown to either side of detection, s
maxDispSec = 120;
selectTimePad = [0.5 0.5];	% time offset for selection
searchstr = 'gliderNoiseMF'; % label of each call detected