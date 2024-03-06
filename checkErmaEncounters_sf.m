% This is for checking glider ERMA-detected encounters. It reads ws* files
% uploaded from the glider and decompressed and puts the encounter times up in a
% spectrogram in Osprey. To use it:
%   - Make a file_dates file if you haven't yet (makeHarufileDateIndex.m).
%   - Set up the configuration section. Normally begin with startDiveNum=0.
%   - Run it.
%   - When Osprey appears, set spectrogram settings (have been using
%     1024/none/0.5/Hamming for ~180 kHz files). It also helps to do
%     'Preferences->Misc->Use hr:min:sec labels'.
%   - Check for the target species every N seconds in the files (using 20 s for
%     sperm whales); click 'Next file' in Osprey to advance all the way to the
%     end-time of the encounter as shown in MATLAB's Command Window. Record your
%     yes/no encounter decision somewhere like in a spreadsheet.
%   - Upon reaching the end of one encounter, click 'Continue' in MATLAB's Edit
%     Window to advance to the next encounter.
%
% Also, to keep the disk spinning, can start up another MATLAB and do this:
%     fn="D:\glider_MHI_spring_2023\sg679_MHI_May2023\wav\dummy.txt";while(1),fclose(fopen(fn,'w'));pause(25);end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% Configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% detDataDir = 'C:\Dave\Hawaii_gliders\operation\sg679_HI_Apr2023\ws_reports';
detDataDir = 'F:\sg679_MHI_May2023\piloting\basestationFiles';
sndDataDir = 'F:\sg679_MHI_May2023\wav';
fileTemplate = 'ws%04d%sz';	% e.g., ws0001az or ws0003bz
maxNDives = 2000;
ospreyDur = 5;			% duration of Osprey window, s
ospreyFreqs = [1e3 20e3];	% frequency limits to display in Osprey, Hz
startDiveNum = 37;		% normally 0; change to start up in middle
%%%%%%%%%%%%%%%%%%%%%%%%%%%% End configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read the index file.
if (exist('hIndex', 'var') && 1)
  printf('SKIPPING READING THE DATE INDEX FILE')
else
  hIndexDirEntry = dir(fullfile(sndDataDir, 'file_dates*'));
  hIndex = readHarufileDateIndex(fullfile(sndDataDir, hIndexDirEntry.name));
end

%% Iterate through the dives, and within them, the encounters.
for di = startDiveNum : maxNDives	% di = dive index
  for phi = 1 : 2			% phi = phase index (don't use 'pi'!)
    % Generate a possible file name.
    phase = iff(phi == 1, 'a', 'b');	% a = descent phase, b = ascent phase
    detfile = fullfile(detDataDir, sprintf(fileTemplate, di, phase));
    
    % Read the detection data if any.
    if (exist(detfile, 'file'))
      s = readErmaReport(detfile);		% detections; might be empty
      % Iterate through encounters.
      for ei = 1 : length(s.enc)		% ei = encounter index
	printf('%s encounter %d/%d: %s - %s', pathFile(detfile), ei, ...
	  length(s.enc), datestr(s.enc(ei).encT0_D), ...
	  datestr(s.enc(ei).encT1_D, 'HH:MM:SS'));
	h = harufileFromDate(s.enc(ei).encT0_D + (0:60)/secPerDay, hIndex);
	firstFile = h(find(~ismissing({h.hname}), 1)).hname;
	sndFile = fullfile(sndDataDir, firstFile);
	% Display the spectrogram, put up 'advance' button.
	osprey(sndFile, [0 ospreyDur ospreyFreqs])
	advanceButton('init')
	keyboard
      end
    end
  end
end

function advanceButton(x)
% Call this function as advanceButton('init') to create a button for the user to
% press to advance 20 s in Osprey, and as advanceButton() to actually advance
% (the latter is done in the callback from a button press).
global opT0 opT1 opTMax			% Osprey variables with time bounds
global ermaAdvWinHandle ermaAdvWindowTag	% don't use persistent
advanceSec = 20;
if (nargin > 0 && ~isempty(x))
  % Create a window with an 'advance' button. First check if it already exists.
  if (~isempty(ermaAdvWinHandle) && any(get(0, 'Children') == ermaAdvWinHandle)...
      && get(ermaAdvWinHandle, 'UserData') == ermaAdvWindowTag)
    % Window with button exists. Pop it to topmost.
    figure(ermaAdvWinHandle)
  else
    % Window with button does not exist. Create it.
    ret = uiInput({''}, sprintf('^Advance %d sec', advanceSec), @advanceButton);
    ermaAdvWinHandle = ret(1);
    % windowTag is used so we can find this window again and re-use it. Since
    % uiInput uses the UserData field of the window, we just use the value it
    % sets for windowTag.
    ermaAdvWindowTag = get(ermaAdvWinHandle(1), 'UserData');
  end
else
  % Callback to advance the window.
  opT0 = opT0 + advanceSec; 
  opT1 = opT1 + advanceSec;
  if (opT0 > opTMax)			% advance to next file?
    opNextFile('next')
  else
    if (opT1 > opTMax)
      opT0 = max(0, opT0 - (opT1 - opTMax));
      opT1 = opTMax;
    end
    opRefresh
  end
  figure(ermaAdvWinHandle)		% pop it to the front
end
end
%#ok<*DATST,*GVMIS,*DEFNU>
