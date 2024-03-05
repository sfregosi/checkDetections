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

