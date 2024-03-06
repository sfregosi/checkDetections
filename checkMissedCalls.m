%checkMissedCalls	check for missed calls after running a detector
%
% Let's say you've run a detector in Ishmael or MATLAB and gotten a log file
% with detections. Now you want to evaluate the detector to see often it
% missed some call(s).  This randomly selects some hours when there are no 
% detections and shows them in Osprey so you can check whether any calls 
% were missed. For each hour to check, it shows sound from that time
% period in Osprey, lets you say whether calls were present, and then goes
% on to another randomly-chosen hour. It stops when you tell it to.
% 
% To use it, edit the Configuation section in the code to define
% your data set and detection log, then run it. This code is currently
% set up for hour-long time periods, but it would be very nice to
% generalize that to arbitrary time periods. This would be done in 
% makeCheckArray.m.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up what data to check. After configuration, you should have these 
% variables defined: 
%   datesfilename	an index file as created by makeHarufileDateIndex
%   inlogname		a detection log (see readDetLog)
%   outlogname		an output file (readable text) with results
%   hrsfilename		an output file (.mat) with results; also gets read in 
%			if you are restarting checking
%   datadir		where to find the sound files
%   dirTranslations	use only if sound files are in a different directory
%			now than what's in the log or index file
%   dispFreqs [1x2]	frequency range to display in Osprey, Hz
%   padTime [1x2]	extra time displayed in Osprey before/after detection, s


% area = 'MHI';
% loc = 'sg679';
% yr = 'May2023';
mission = 'sg679_MHI_May2023';
dispFreqs = [0 20000];	% freq range to display in Osprey
padTime = [0 -2700];	% extra time displayed in Osprey before/after detection

indexdir = 'D:\sg679_MHI_May2023\recordings\wav_gain_adjusted\';
logdir  = 'D:\analysis\spermWhales\';
datadir = 'D:\sg679_MHI_May2023\recordings\wav_gain_adjusted\';
%
% This is for fixing directory names that appear in the detection logs or 
% index file. Set this to {} if the sound files haven't moved.
%dirTranslations = {
%    % This pair is solely for testing this script.
%    %'\\Thefarm\EPR\Nov99-Nov00\08s110w'
%    %'C:\Dave\airguns\ETP\testdata-ETP-SW-Nov99'
%
%    '\\Thefarm\EPR\'
%    '\\Back40\hdd1\EPR\'
%    };


% locyr         = [loc '-' yr];
% datesfilename = [indexdir 'file_dates-' locyr '.txt'];
% inlogname     = [logdir area '-' locyr '.log'];
% outlogname    = [logdir area '-' locyr '-checkMisses.log'];
% hrsfilename   = [logdir area '-' locyr '-checkMisses.mat'];

datesfilename = fullfile(indexdir, ['file_dates-' mission '.txt']);
inlogname     = fullfile(logdir, 'encounter_dets-230510_055705.csv');
outlogname    = fullfile(logdir, [mission '-checkMisses.log']);
hrsfilename   = fullfile(logdir, [mission '-checkMisses.mat']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read index file to get date of each sound file, and detection log file.
hIndex = readHarufileDateIndex(datesfilename);
disp(['Reading detection log ' inlogname ' ...'])
[t0,dummy1,soundfiles,eff] = readDetLog(inlogname, hIndex, '$enc');
% t0 has [start end] cols, in datenum format.  eff is [start end].

% hrs is a Nx24 array with one entry per hour:
%    0 means calls were not detected but this hasn't been verified,
%    1 means calls were detected (these are ignored for checkMissedCalls),
%    2 means they weren't and this has been verified,
%    3 means they weren't but there were calls (i.e., a missed detection).

% Make the boolean array or load it from hrsfilename.  makeCheckArray leaves
% hrs with 0, 1, or NaN, or possibly 2 or 3 if those values have been saved
% in hrsfilename.
[hrs,day0] = makeCheckArray(t0, eff, hrsfilename, soundfiles, datesfilename);

nChecked = 0;

if (1)
  md = sum(hrs(:) == 3);
  cnd = sum(hrs(:) == 2);
  printf(['So far: %d/%d (%.1f%%) missed detections found, ' ...
	  '%d verified non-detections'], md, md+cnd, md/(md+cnd)*100, cnd)
  printf('QUITTING CHECKMISSEDCALLS.M EARLY!')
  return
end

% (NOT IMPLEMENTED YET) Read any existing checkMisses log file.
disp('I''m not currently reading the checkMisses .log file, just the .mat file.')

% Check some calls.
printf
printf('In addition to the usual 0/1 input, you can always use one of these:')
printf('    2  Get a Matlab prompt; continue by typing the word ''return''');
printf('    3  Exit (not required; results are logged no matter what)');
printf
while (1)
  % Find a 0 entry in hrs.
  while (1)
    ix = ceil(rand(1,2) .* [nRows(hrs) 24]);        % index into hrs
    %disp('Using DEBUG ix!!!!!'); ix = ceil(rand(1,2) .* [2 24]);
    if (hrs(ix(1), ix(2)) == 0), break; end
  end
  
  dt = ix(1)-1 + day0 + (ix(2)-1)/24;	% added second '-1' to Balaena 3/24/04
  hmark = harufileFromDate(dt, hIndex);
  if (isnan(hmark.time))
    printf('ALARM! The soundfile for %s (indexed in %s) is MISSING.', ...
	datestr(dt), datesfilename)
    continue
  end
  pname = translateDir([datadir hmark.hname], dirTranslations);
  osprify(pname, [(hmark.time + [-1 1].*padTime + [0 3600])  dispFreqs]);
  while (1)
    str = sprintf('%d %s (%s at %d s): ', sum(hrs(:)==2 | hrs(:)==3) + 1, ...
	datestr(dt,0), hmark.hname, round(hmark.time));
    inp = input([str ': Calls present (1) or not (0)? ']);
    switch inp
    case {0 1},
      break				% exit the while (1)
    case 2,
      keyboard
    case 3,
      return
    end		% end of switch; if it falls through, loop and ask again
  end

  hrs(ix(1), ix(2)) = inp + 2;
  fd = fopen(outlogname, 'a');
  fprintf(fd, [iff(inp, 'Missed call: ', 'Correct non-detection: ') ...
	  'input=%s sel=%.1f-%.1f\n'], hmark.hname,hmark.time,hmark.time+3600);
  fclose(fd);
  save(hrsfilename, 'hrs');
end
