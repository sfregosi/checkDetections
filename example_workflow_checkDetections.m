% example workflow for using checkDetections

% checkDetections originally written by Dave Mellinger (last copied 23 Nov 2020) 
% included within his DaveWhales matlab tools

% modified here to be stand alone tool hosted on github
% 08 June 2021 Selene Fregosi selene.fregosi@gmail.com

% add checkDetections and osprey to the path (if not already there)
addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\checkDetections\'))
addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\osprey\'))

% Make a config file with info on:
    % paths to sound and log files
    % time and frequency plotting settings
    % which detections to view
    % see checkDetConfig folder for example (exampleConfig_spermWhales.m)
edit exampleConfig_spermWhales
% store saved config file in checkDetConfig folder 

% run checkDetections
checkDetections exampleConfig_spermWhales
% %% Manual checking of detections
% addpath(genpath('H:\GoMex2018\noiseDetector\code\'))
% 
% % configuration file is: GoMex_2018_sg639 (in \DaveWhales\checkDetConfig\)
% checkDetections GoMex_2018_sg639
% % 16268 detections

%% cleaning up checked detections

% read in the checked log
checkLog = ['H:\GoMex2018\noiseDetector\ishDetectorRuns\' ...
    'gliderPumpNoise-MF_SG639_GoMex2018_run20190405_20190926-checked.log'];

fid = fopen(checkLog);
C = textscan(fid, '%s', 'Delimiter','\n'); % reads in each line separately
fclose(fid);
c = C{1,1};
% 23666 lines

% extract all lines that start with 'File' bc don't need these
fileList = {}; % file list
fileIdx = [];
for l = 1:length(c)
    startStr = regexp(c{l}, 'File', 'match');
    if ~isempty(startStr)
        fileList = [fileList; c(l)];
        fileIdx = [fileIdx; l];
    end
end
% delete file lines from c (6853 lines)
c(fileIdx, :) = [];
% 16813 lines of checked detections (I repeated scoring some)

% remove any duplicate scores for a single detection
% e.g. I changed the answer, so need the LAST of each one (~600?)

% extract time stamps of all detections
timeTemplate = ['(?<day>\d+)-May-(?<year>\d+) \d\d:\d\d:\d\d.\d\d\d|' ...
    '(?<day>\d+)-Jun-(?<year>\d+) \d\d:\d\d:\d\d.\d\d\d'];
timeStamps = NaT(length(c), 1);
for l = 1:length(c)
    timeStamps(l,1) = datetime(regexp(c{l}, timeTemplate, 'match'), ...
        'InputFormat', 'dd-MMM-yyyy HH:mm:ss.SSS');
end

% get index of last of each unique time stamp
timeStamps.Format = 'dd-MMM-yyyy HH:mm:ss.SSS';
[uts, ia, ic]= unique(timeStamps, 'last');

uc = c(ia,:);
% 16177 unique detections marked (this is short of log above??) Where did I
% lose them??

% *******************need to compare these unique ones to the original log??


% Break into cell arrays by detection type
tp = {}; % true positive (YES glider noise to be removed)
fp = {}; % false positives (ambient noise, leave in)
ns = {}; % not sure's - need to check them

startTemplate = {'Call detected:', 'Not a whale:', 'not sure:'};
for l = 1:length(uc)
    startStr = [];
    i = 0;
    while i < length(startTemplate) && isempty(startStr)
        i = i + 1;
        startStr = regexp(uc{l}, startTemplate{i}, 'match');
    end
    switch startStr{1}
        case startTemplate{1}
            tp = [tp; uc(l)];
        case startTemplate{2}
            fp = [fp; uc(l)];
        case startTemplate{3}
            ns = [ns; uc(l)];
    end
end

length(tp) + length(ns) + length(fp) % 16177...still missing some?
% this leaves 8563 tp, 100 not sures, 7514 false positives


%% Not Sures
% where are they - can I print a new log file to check them?

fid = fopen(['H:\GoMex2018\noiseDetector\ishDetectorRuns\' ...
    'gliderPumpNoise-MF_SG639_GoMex2018_run20190405_20190926_notSures.log'], 'w');
% write a file just so it knows the path to wav files
fprintf(fid, '%s\n', ...
    'StartFile: inputFile=''H:\GoMex2018\wav\sg639-10kHz\180510-190931.wav'' localTimeNow=2019 Apr  5 17:09:44.');
% write not sure detections
fprintf(fid, '%s\n', ns{:});
fclose(fid);

checkDetections GoMex_2018_sg639_notSures
% copied these dets to the bottom of new checked log txt file
% then re-ran above with v2 checked log
% THERE IS SOME SORT OF TIME ISSUE HERE WITH RECHECKING
% just ignore these...its only 100 of them. Shouldn't make a huge
% difference, most are NOT glider noise. 

%% cleaning up checked detections - VERSION 2
% read in the checked log
checkLog = 'H:\GoMex2018\noiseDetector\ishDetectorRuns\gliderPumpNoise-MF_SG639_GoMex2018_run20190405_20190926-checked_v2.log';
fid = fopen(checkLog);
C = textscan(fid, '%s', 'Delimiter','\n'); % reads in each line separately
fclose(fid);
c = C{1,1};
% 23809 lines

% extract all lines that start with 'File' bc don't need these
fileList = {}; % file list
fileIdx = [];
for l = 1:length(c)
    startStr = regexp(c{l}, 'File', 'match');
    if ~isempty(startStr)
        fileList = [fileList; c(l)];
        fileIdx = [fileIdx; l];
    end
end
% delete file lines from c (6893 lines) (extra 40 lines)
c(fileIdx, :) = [];
% down to 16916 lines

% remove any duplicate scores for a single detection
% e.g. I changed the answer, so need the LAST of each one
timeTemplate = ['(?<day>\d+)-May-(?<year>\d+) \d\d:\d\d:\d\d.\d\d\d|' ...
    '(?<day>\d+)-Jun-(?<year>\d+) \d\d:\d\d:\d\d.\d\d\d'];
timeStamps = NaT(length(c), 1);
for l = 1:length(c)
    timeStamps(l,1) = datetime(regexp(c{l}, timeTemplate, 'match'), ...
        'InputFormat', 'dd-MMM-yyyy HH:mm:ss.SSS');
end
timeStamps.Format = 'dd-MMM-yyyy HH:mm:ss.SSS';

% get index of last of each unique time stamp and only save those
[uts, ia, ic]= unique(timeStamps, 'last');

uc = c(ia,:);
% this gives me 16262 detections...where did I lose 6 detections???

% Break into cell arrays by detection type
tp = {}; % true positive (YES glider noise to be removed)
fp = {}; % false positives (ambient noise, leave in)
ns = {}; % not sure's - need to check them

startTemplate = {'Call detected:', 'Not a whale:', 'not sure:'};
for l = 1:length(uc)
    startStr = [];
    i = 0;
    while i < length(startTemplate) && isempty(startStr)
        i = i + 1;
        startStr = regexp(uc{l}, startTemplate{i}, 'match');
    end
    switch startStr{1}
        case startTemplate{1}
            tp = [tp; uc(l)];
        case startTemplate{2}
            fp = [fp; uc(l)];
        case startTemplate{3}
            ns = [ns; uc(l)];
    end
end
% this leaves 8589 tp, 85 not sures, 7588 false positives
length(tp) + length(ns) + length(fp) % this = 16262
% how do I still have not sures?


%% Output for true positives
% create list of start/end times to IGNORE in noise analysis

length(tp)
length(unique(tp)) % good these match

% textscan each line with multiple delimiters?
% or just pull each bit I want?

inputFile = {};
selStart = [];
selEnd = [];
timeStamps = datetime();
for l = 1:length(tp)
    [startIdx(1), startIdx(2)]  = regexp(tp{l}, 'Call detected:');
    [inputIdx(1), inputIdx(2)] = regexp(tp{l}, 'input=');
    [selIdx(1), selIdx(2)] = regexp(tp{l}, 'sel=');
    dashIdx = regexp(tp{l}, '-');
    [peakIdx(1), peakIdx(2)] = regexp(tp{l}, 'peak=');
    timeStamps(l,1) = datetime(regexp(tp{l}, timeTemplate, 'match'), ...
        'InputFormat', 'dd-MMM-yyyy HH:mm:ss.SSS', 'Format', 'dd-MMM-yyyy HH:mm:ss.SSS');
    inputFile{l,1} = tp{l}(inputIdx(2)+1:selIdx(1)-3);
    selStart(l,1) = str2num(tp{l}(selIdx(2)+1:dashIdx(2)-1));
    selEnd(l,1) = str2num(tp{l}(dashIdx(2)+1:peakIdx(1)-4));
end

timeStamps.Format = 'dd-MMM-yyyy HH:mm:ss.SSS';
gliderNoise = table(inputFile, selStart, selEnd, timeStamps, ...
    'VariableNames',{'file','startTime', 'endTime', 'timeStamp'});

writetable(gliderNoise, ['H:\GoMex2018\noiseDetector\ishDetectorRuns\' ...
    'gliderPumpNoiseOutput_sg639_GoMex2018.txt'], 'Delimiter','\t');



