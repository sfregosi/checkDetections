function ret = checkDetections(cmd)
% checkDetections       Check a detection logfile for correct detections
%
% checkDetections <configuration_file_name>
%
% To use this, make your own configuration file in the ./checkDetConfig
% directory, then run this (checkDetections) as shown above. 
% You'll get a spectrogram display of each detection; adjust the
% spectrogram parameters as you like.  You'll also get a small box with buttons
% that let you specify whether each detection is correct.  Clicking a button
% will write a line to the outlogpath file (see below) and then advance to
% the next detection.  You can also move forward or backward in the set of
% detections by typing a new value into the date/time text box you'll see.
%
% If the timeIncr variable is set to, say, 1 hour, that means that you want
% to check in each hour whether there is a detection, but that you don't care
% if there is more than one.  (A lot of our data analysis is done this way.)
% As soon as you find a detection in a given hour (i.e., click the 'Correct'
% button), you don't need to check any more within that hour, so this code will
% skip ahead to the first detection in the succeeding hour.  If you want to
% check every single detection, set timeIncr to something small, like 1 second.
%
% To use this, you'll need to have utils, wutils, and osprey in your MATLAB
% path.
%
%#ok<*UNRCH>
% See also icelandRwDates.m, goaspermdates.m, etc. for plotting results.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Variable descriptions and default values %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Don't change the default values here.  Instead, override these by setting
% these variables to different values in your config file.


% These specify where your input and output files are. Set them in your
% configuration file since these are dummy values.
snddir = '';		% directory with the sound files
indexpath = '';		% pathname of index file made by makeHaruFileIndex
inlogpath = '';		% pathname of input detection log file
outlogpath = '';	% pathname of output log file

% These control how this program operates.  If checkMethod is 'user', it
% means the user is asked about each detection.  If checkMethod is 'savefile'
% and saveprefix is set, the user is not asked; instead I just make "sound
% clips", short sound files containing each detection.
checkMethod = 'user';				% may get overridden below
clear saveprefix                                % may get overridden below

% This controls what detections you want to check.  If you set it higher than
% the threshold used in Ishmael, it will ignore any detections that are in
% the log file but below this new threshold.  (In log files, the height of the
% detection peak is called 'peak' or 'peak value' or 'detection peak'.)  Use
% -inf (the default here) if you want to check all detections in the log file.
newthresh = -inf;				% may get overridden below

% This has pairs of strings for converting directory names.  This is useful
% because sometimes files (e.g., sound files) are moved to a different place
% between the time you run a detector and the time you run this.  Or sometimes
% the detector is run with the soundfile directory mapped to 'J:' or something,
% and this mapping is not valid anymore.  dirTranslations consists of pairs
% of strings: when the first string appears at the start of a filename in the
% detection log, it will get converted to the second string.  Leave it as an
% empty cell if you don't need any translations.
dirTranslations = {};                           % may get overridden below

% This specifies when to start checking detections. The default value here
% is before any of our deployments; using this date (i.e. not overriding it) 
% means to start at the very beginning of the deployment.
startdate = '1-Jan-1994  0:00';			% may get overridden below

% timeIncr says how often detections should be checked.  The value is in
% days.  To check all detections, use a small number, like 1 second.  Choose
% one of these and use it (uncommented-out) in your configuration file.
%timeIncr = 1;			% check one detection per day
%timeIncr = 2 / 24;		% check one detection each 2 hours
timeIncr = 1 / 24;		% check one detection per hour (default)
%timeIncr = 1 / 48;		% check one detection per half-hour
%timeIncr = 1 / (24*60);	% check one detection per minute
%timeIncr = 2 / (24*60*60);	% check one detection every 2 s
%timeIncr = 1 / (24*60*60);	% check one detection every 1 s

% This controls the format of log files.  The 0 here (the default) means
% that log files are the usual text files output by Ishmael or Matlab 
% detectors.  A 1 value means that the log files have just date values (a la
% datenum) in the variable 'detTimes', and that 'snddir' says where to find
% the data files.
onlyDates = 0;			% may get overridden below

% These control the total T/F area displayed for each detection in Osprey.
% displayFreq is the frequency band to show, in Hertz.  padTime is the time
% to show on sides of the detection, in seconds.  It can be a 2-element vector
% (use positive numbers), or a scalar, which means to use the same pad time on
% both left and right.
displayFreq = [0 1000];		% gets overridden below
padTime = [10 10];		% gets overridden below

% These control how the yellow selection box is displayed in Osprey.  
% selectFreq is the upper and lower bounds of the selection box, in Hertz.
% selectTime is the time to add on the left and right of a detection for the
% selection box, in seconds.   [0 0] means just use the detection times as is;
% use positive numbers to make the selection box bigger.
selectFreq  = [10 50];		% gets overridden below
selectTimePad = [0 0];		% may get overridden below

% These are optional, and are used to construct the file names used for input
% and output -- the input log file name, the index file name, the directory
% where the sound files are, and the output log file.  They are used only as
% strings in file names, so for instance 'yr' can contain letters (like
% 'bow07').  They should not be used outside your Configuration file.
loc = '';			% may get overridden below
yr = '';			% may get overridden below

% This is for hacking the sample rate because the value in the sound file
% is wrong.  hackSampleRate can be either 
%
%    '', which means the sample rate is read from the header of the sound
%		file (this is the default); or
%    'fromFile', which means to figure out the sample rate from the number of
%		samples in a file divided by the duration in s of the file; or
%    a string like 'fixedValue 112', meaning to use 112 Hz no matter what.
%
hackSampleRate = '';		% may get overridden below

% 'buttons' defines the button names and what gets written to the log.  If an
% element here has two parts, like {'correct' 'call detected'}, then the first
% part ('correct') is what's displayed on the button and the second part ('call
% detected') is what is written to the log file. If it has only one part, like
% 'not sure', then that name is used for both the button and the log file.  The
% 'correct' button has special meaning, in that it causes skipping ahead
% according to timeIncr (see above).  
% If an element has three or more parts, then the first is the name, the second
% is what's written to the log file, and the third has special instructions
% for what to do.  Currently the only special instructions known to the code
% are 'skipahead', meaning skip ahead timeIncr seconds before looking for the
% next detection, and 'ignore', meaning don't write anything in the logfile.
% So one element might be {'Ignore' '' 'ignore'}.
buttons = {{'correct' 'Call detected' 'skipahead'} {'wrong' 'Not a whale'} ...
	'not sure'};

% This defines what string(s) to look for in the log file to find lines
% containing detections.  If it's empty, then the default is used from
% readDetLog, which is  {'Call detected:' 'Is a whale:'}.
searchstr = '';			% may get overridden below

% Check every Nth detection.  Default is to check them all.  If everyNth is
% a 2-element vector, the second element is the offset (default 0) within
% every set of N detections.
everyNth = 1;

% This sets the maximum length, in seconds, of a detection to display at once.
% It was created for the case of airgun sounds that go on for many minutes, or
% even hours.  Only the first maxDispSec seconds of each detection will be
% shown in Osprey.
maxDispSec = inf;		% in seconds; inf means there is no limit

% Noise removal: If you define noiselogpath, it is the name of an Ishmael-type
% detection log of 'noise' sounds. If any call detection from your inlogpath is
% encompassed in a detected noise sound, it is removed from the set of possible
% detections. Actually the call detection doesn't have to be strictly within the
% noise detection, it has to be within noisePad seconds of the noise detection
% -- that is, if the noise detection is from time n0 to n1, then the call has to
% be within n0+noisePad(1) to n1+noisePad(2). Note that those are both '+'
% signs, so you probably want a negative number for noisePad(1).
noiselogpath = '';         % if defined, a set of noise detections to ignore
noisePadTime = [-1 1];     % in seconds; time for padding noise detections
noiseSearchStr = 'Call detected:';      % for finding lines in Ishmael log file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% end of user-settable variables %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (0)
  % Sometimes a calling routine (extractDetections) wants to set loc and yr. In
  % this case you want the definitions of loc and yr commented out in whatever
  % config file you use.  Best to leave a comment in that file if you do this.
  global exdLoc exdYear
  loc = exdLoc;			% "extractDetections loc"
  yr = exdYear;			% "extractDetections year"
end


if (nargin < 1)
  error(['%s now requires you to specify a configuration file name.\n'...
      'Config files live in the directory %s%scheckDetConfig. Here''s an\n' ...
      'example:\n     %s ETPblue'], ...
      mfilename, pathDir(mfilename('fullpath')), filesep, mfilename);
end

% Internal calls:
% checkDetections('init')
% checkDetections('date/time')
% checkDetections('not a whale')
% checkDetections('1 whale')
% checkDetections('>= 2 whales')
% checkDetections(...any button name...)

global cdAbsTimes cdRelTimes cdFileNames cdOutLogPath cdIx cdPeakInfo
global cdLastNameWritten cdLastTime cdNoMore opHaruSrate cdConfig

callMyself = str2func(mfilename);

% Read user's configuration file.
if (~isempty(cdConfig)), eval(cdConfig); end

% Make sure directory name ends in '\'.
if (exist('snddir', 'var') && ~isempty(snddir) && snddir(end) ~= filesep)
  snddir = [snddir filesep];
end

buttonNames = {};
for i = 1 : length(buttons)
  if (iscell(buttons{i})), buttonNames(end+1) = buttons{i}(1);       %#ok<AGROW>
  else buttonNames(end+1) = buttons(i);                              %#ok<AGROW>
  end
end

switch(cmd)
case 'init'
  % Begin!  Read the index file and log file, then set up the GUI.

  if (1)		% print file names for error-checking
    printf('Starting %s.', mfilename)
    printf('   snddir       %s', snddir)
    printf('   indexpath    %s', indexpath)
    printf('   inlogpath    %s', char(inlogpath)')  % inlogpath may be cell array
    printf('   outlogpath   %s', outlogpath)
    if (~isempty(noiselogpath)), printf('   noiselogpath %s', noiselogpath); end
  end

  cdOutLogPath = outlogpath;
  cdLastNameWritten = '';
  cdLastTime = inf;

  % Read times at which each soundfile begins.
  disp('Reading file index times from indexpath.');
  hIndex = readHarufileDateIndex(indexpath);

  % Read the log file, storing abs times (a la datenum), rel times (in seconds
  % relative to start of each soundfile), sound file names, and peak values.
  disp('Reading detections log from inlogpath.')
  if (onlyDates)
    [cdAbsTimes,cdRelTimes,cdFileNames,cdPeakInfo] = ...
	readDetTimes(inlogpath, hIndex, snddir);
  elseif (1)
    [cdAbsTimes,cdRelTimes,cdFileNames,cdPeakInfo] = ...
	readDetLog(inlogpath, hIndex, searchstr, newthresh);
  else
    mprintf('Using funky readDetLog call.')
    [cdAbsTimes,cdRelTimes,cdFileNames] = ...
	readDetLog(inlogpath, hIndex, 'Manual detection:', newthresh); 
  end
  printf('   %d call detections read.', nRows(cdAbsTimes));
  
  % Make absolute pathnames out of relative ones.
  if (~(any(cdFileNames{1} == '/') || any(cdFileNames{1} == '\')))
    cdFileNames = strcat(snddir, cdFileNames);
  end
  
  if (everyNth(1) ~= 1)
    if (length(everyNth) == 1), everyNth = [everyNth 0]; end
    cdAbsTimes  =  cdAbsTimes(1+everyNth(2) : everyNth : end, :);
    cdRelTimes  =  cdRelTimes(1+everyNth(2) : everyNth : end, :);
    cdFileNames = cdFileNames(1+everyNth(2) : everyNth : end);
    cdPeakInfo  =  cdPeakInfo(1+everyNth(2) : everyNth : end, :);
    printf('   But using only %d of them.', nRows(cdAbsTimes));
  end

  % Read noise log, if there is one.
  if (~isempty(noiselogpath))
    disp('Reading noise detection log from noiselogpath.')
    [nsAbsTimes] = ...                %,nsRelTimes,nsFileNames,nsPeakInfo] = ...
      readDetLog(noiselogpath, hIndex, noiseSearchStr);
    %if (~(any(nsFileNames{1} == '/') || any(nsFileNames{1} == '\')))
      %nsFileNames = strcat(snddir, nsFileNames);
    %end
    printf('   %d noise detections read.', nRows(nsAbsTimes));
    % Remove the 'call' detections that were also detected as noise.
    noiseLims = [nsAbsTimes(:,1) + noisePadTime(1)/secPerDay  ...
                 nsAbsTimes(:,2) + noisePadTime(2)/secPerDay];
    [cdAbsTimes,cdRelTimes,cdFileNames,cdPeakInfo] = removeNoiseDets(...
      cdAbsTimes, cdRelTimes, cdFileNames, cdPeakInfo, noiseLims);
  end
  
  % Hack: Fix sampling rate for Osprey.
  if (~isempty(hackSampleRate))
    if (strcmp(hackSampleRate, 'fromFile'))
      mid = round(length(cdFileNames)/2 + 0.5);  % pick random file from middle
      cdfn = translateDir(cdFileNames{mid}, dirTranslations);
      [~,~,nSamTotal] = soundIn(cdfn,0,0);
      opHaruSrate = nSamTotal / hIndex.dur;
      mprintf('opHaruSrate = %.6f', opHaruSrate);
    elseif (strncmp(hackSampleRate, 'fixedValue', 10))
      opHaruSrate = str2double(hackSampleRate(11:end));
      mprintf('Ignoring file''s sample rate; matching Ishmael''s %g Hz.', ...
	  opHaruSrate); 
    else
      error('hackSampleRate is not either fromFile or fixedValue<n>: %s', ...
	  hackSampleRate);
    end
  end

  % Create figure if needed.
  openfig('checkDetectionsFig', 'reuse');
  if (isempty(findobj('Tag', 'DateText')))  % openfig is sometimes wrong; check
    openfig('checkDetectionsFig', 'new');
  end

  % Make the GUI do callbacks to this function, even if its name has changed.
  mfn = mfilename;

  % Create buttons.  The 'correct' button comes from the .fig file, others are
  % made here.
  cb = findobj('Tag', 'correctButton');
  set(cb, 'Units', 'pixels');
  p = get(cb, 'Pos');
  bgcolor = get(cb, 'BackgroundColor');
  delete(findobj('Type', 'uicontrol', '-and', 'Style', 'pushbutton'));
  hsp = 8;			% horizontal space between buttons
  vsp = 10;			% vertical space between buttons
  for i = 0 : length(buttons)-1
    btn = uicontrol('Style', 'pushbutton', 'String', buttonNames{i+1}, ...
	'Callback', [mfn '(''' buttonNames{i+1} ''')'], 'Units', 'pixels', ...
	'Position', [p(1)+(p(3)+hsp)*mod(i,3) p(2)+(p(4)+vsp)*(floor(i/3)) ...
	    p(3:4)], 'BackgroundColor', bgcolor);
    if (i == 0), set(btn, 'Tag', 'correctButton'); end
    set(gcf, 'Units', 'pixels', ...	% make figure tall enough
	'Pos', [sub(get(gcf, 'Pos'), 1:3) p(2)+(p(4)+vsp)*(floor(i/3)+1)]);
  end

  % Set initial date/time and go!
  set(findobj('Tag', 'DateText'), 'String', startdate);
  callMyself('date/time')
  return

case 'date/time'
  % New date and/or time entered; find next detection.
  % First read date/time strings and check for validity.
  dtstr = get(findobj('Tag', 'DateText'), 'String');
  ixNext = find(cdAbsTimes(:,1) >= datenum(dtstr), 1);
  cdNoMore = isempty(ixNext);
  if (cdNoMore)
    disp(['There are no detections after ' dtstr ' in this log file.']);
    return
  else
    cdIx = ixNext;

    % Set date/time string for start-time of new detection.  Round down
    % to nearest second, so that if user presses return in date/time string,
    % this same detection is found and its time is redisplayed as selection.
    t = cdAbsTimes(cdIx, 1);
    set(findobj('Tag', 'DateText'), 'String', ...
        datestr(floor(t * 24*60*60) / (24*60*60), 'dd-mmm-yyyy HH:MM:SS.FFF'));

    % Give user message about passage of time.
    if (gexist4('cdLastTime') && strcmp(checkMethod, 'user'))
      if (t < cdLastTime), disp('Just went to a previous time/date.');
      elseif (t == cdLastTime), disp('Redisplaying same date/time.');
      else
        dt = t - cdLastTime;
        dthrs = datestr(dt, 'HH:MM:SS.FFF');
        if (strncmp(dthrs, '00:', 3)), dthrs = dthrs(4:end); end
        printf('This selection is %s%s after the previous one.', ...
            iff(dt >= 1, [num2str(floor(dt)) ' day(s), '], ''), dthrs)
      end
    end
    cdLastTime = t;

    cdfn = cdFileNames{cdIx};
    fname = translateDir(cdfn, dirTranslations);
    % The following line is a hack for testing sperm whale extraction.
    %fname = [fname '.dat'];disp('checkDetections: appending .dat to filename')
    u = cdRelTimes(cdIx,1:2);
    switch(checkMethod)
    case 'user'
      % Apply maximum display time.
      if (u(2) > u(1) + maxDispSec)
	warning('Actual detection is %g s long; displaying only %g s of it',...
	    diff(u), maxDispSec);
	u(2) = u(1) + maxDispSec;
      end
      % Display the detection.
      osprify(fname, [(u + padTime.*[-1 1]) displayFreq], ...
	  [(u + selectTimePad.*[-1 1]) selectFreq]);
      % Somewhy Osprey creates an extra axes in the button figure.  Delete it.
      ch = get(get(findobj('Tag', 'DateText'), 'Parent'), 'Children');
      delete(ch(strcmp('axes', get(ch, 'Type'))));

    case 'savefile'
      if (exist('saveprefix', 'var'))
	% Save sound clip in saveprefix.  extractDetections wants this enabled.
	[~,sRate,left] = soundIn(fname, 0, 0);
	s = round([mean(u) diff(padTime.*[-1 1])]*sRate); % samples: [s0 nsam]
	if (s(1) > 0 && sum(s)-1 <= left)	% is all of sound within file?
	  sams = soundIn(fname, s(1), s(2));
	  if (strcmp(pathExt(cdfn), 'dat'))
	    fnum = sub(pathFile(pathRoot(cdfn)), 5:8);% names like 00000022.dat
	  else
	    fnum = pathExt(pathFile(cdfn));	% names like datafile.022
	  end
	  secs = sprintf('%0*.0f', ceil(log10(left/sRate)), s(1)/sRate);
	  fout = [saveprefix '-f' fnum '@' secs '.wav'];
	  soundOut(fout, sams, sRate);
	end
      end

    case 'crunchnnet'
      
      
    end
  end

case 'testmore'
  ret = ~cdNoMore;

case buttonNames
  % Get name to write to log file.
  ignore = 0;
  skipahead = 0;
  lump = 0;
  for i = 1 : length(buttons)
    if (iscell(buttons{i}) && strcmp(cmd,buttons{i}{1}))
      lstr = buttons{i}{2};
      skipahead = any(strcmp('skipahead', buttons{i}(2:end)));
      ignore    = any(strcmp('ignore',    buttons{i}(2:end)));
      lump      = any(strcmp('lump',      buttons{i}(2:end)));
    elseif (strcmp(cmd, buttons{i}))
      lstr = buttons{i};
    end
  end
  
  %relT0 = cdRelTimes(cdIx,1);
  %relT1 = cdRelTimes(cdIx,2);
  %pkT = cdPeakInfo(cdIx,1);
  %pkHi = cdPeakInfo(cdIx,2);
  if (lump)
    if (~opSelect(opc))
      warnbox(['You need a selection to use the ''' cmd ''' button.'], '')
      return
    end
    % Lump next detection together with previous one(s).
    fileStart = cdAbsTimes(cdIx,1) - cdRelTimes(cdIx,1)/24/60/60;
    selT1Abs = fileStart + opSelT1/24/60/60;
    ixs = find(cdAbsTimes(cdIx : end, 2) < selT1Abs).' + cdIx-1;
    printf('Lumping together %d detections.', length(ixs));
    if (isempty(ixs))
      warnbox('Your selection needs to include at least one detection.', '');
      return
    end
    %[~,ixHi] = max(cdPeakInfo(ixs, 2));
    %pkT = cdPeakInfo(ixHi,1);
    %relT1 = cdRelTimes(max(ixs), 2);
    cdIx = max(ixs);     % set it to the last det in the selection
  end

  if (~ignore)
    % Write to log file.
    fd = fopen(cdOutLogPath, 'a');
    if (~strcmp(cdLastNameWritten, cdFileNames{cdIx}))
      cdLastNameWritten = cdFileNames{cdIx};
      fprintf(fd, 'File %s\n', cdFileNames{cdIx});
    end
    fprintf(fd, '%s: input=%s, sel=%.2f-%.2f s, peak=(%.4f s, %.4f), %s\n', ...
      lstr, pathFile(cdFileNames{cdIx}), cdRelTimes(cdIx,1), ...
      cdRelTimes(cdIx,2), cdPeakInfo(cdIx,1), cdPeakInfo(cdIx,2), ...
      datestr(cdAbsTimes(cdIx,1), 'dd-mmm-yyyy HH:MM:SS.FFF'));
    fclose(fd);
  end

  % Figure out time of the next detection to use.
  if (skipahead)
    % Is a whale.  Advance past the current time increment, then find the
    % next detection.  Important: start advancing from the same time point
    % -- the mean of start- and end-times -- used by the analysis routine.
    %
    t = ceil(mean(cdAbsTimes(cdIx,:)) / timeIncr) * timeIncr;
  else
    % Not a whale.  Check the very next detection.
    t = cdAbsTimes(cdIx, 2) + 0.001/24/60/60; % end-time of this call + 1 ms
  end
  % Writing the time to the window and the re-reading it is a heavily
  % bass-ackward way to do it.  But it works.
  set(findobj('Tag', 'DateText'), 'String', ...
    datestr(t, 'dd-mmm-yyyy HH:MM:SS.FFF'));
  callMyself('date/time');

case 'saveToFile'
  % Not sure that this is here for...

otherwise
  % Not one of the known commands or buttons.  See if it's a config file.
  addpath([pathDir(mfilename('fullpath')) filesep 'checkDetConfig'], '-begin');
  if (exist([cmd '.m'], 'file'))
    cdConfig = cmd;
    callMyself('init')
  elseif (exist(cmd, 'file'))	% in case user puts a .m on the end
    cdConfig = cmd(1:end-2);
    callMyself('init')
  else
    error('Unknown configuration file name (or command) in %s: %s', ...
	mfilename, cmd);
  end

end     % of switch

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [absT,relT,fname,pk] = removeNoiseDets(absT, relT, fname, pk, nsAbsT)
% Find indices of all elements to be removed.
ix = false(1, length(absT));
for i = 1 : length(ix)
  ix(i) = any(absT(i,1) >= nsAbsT(:,1) & absT(i,2) <= nsAbsT(:,2));
end
printf('Removing %d "call" detections that were found to be noise.', sum(ix))
% Remove the offending elements.
absT(ix,:) = [];
relT(ix,:) = [];
fname(ix)  = [];
pk(ix,:)   = [];
