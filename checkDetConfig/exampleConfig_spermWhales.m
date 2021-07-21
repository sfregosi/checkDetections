%%%%%%%%%%%% Example checkDetections config file %%%%%%%%%%%%
% works with example log and sound file in the "example" directory

timeIncr = 1 / (24*60*60);	% check every detections (every second)
% examples...
%timeIncr = 1;			% check one detection per day
%timeIncr = 2 / 24;		% check one detection each 2 hours
% timeIncr = 1 / 24;		% check one detection per hour (default)
%timeIncr = 1 / 48;		% check one detection per half-hour
%timeIncr = 1 / (24*60);	% check one detection per minute
%timeIncr = 2 / (24*60*60);	% check one detection every 2 s
%timeIncr = 1 / (24*60*60);	% check one detection every 1 s


% Sound files and index file:
snddir = 'C:\Users\Selene.Fregosi\Documents\MATLAB\checkDetections\example\'; % dir containing raw wavs (or flacs?)
indexpath = [snddir 'file_dates-spermExample.txt']; %fileDates File 
% if you don't already have one, make a fileDatesIndex file 


% Log files:
logdir   = 'C:\Users\Selene.Fregosi\Documents\MATLAB\checkDetections\example\'; % log file(s)
inlogpath  = [logdir 'example_logfile.log'];
outlogpath = [pathRoot(inlogpath) '-checked.log'];

% Display info:
displayFreq = [0 22500];	% freq range to show in Osprey
selectFreq  = [0 22500];	% freq range shown in yellow for detection
padTime     = [2 4];	% time shown to either side of detection, s
maxDispSec = 120;
selectTimePad = [0.5 0.5];	% time offset for selection
searchstr = 'Call detected'; % label of each call detected
