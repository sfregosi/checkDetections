function [hrs,day0] = makeCheckArray(t0, eff, hrsfilename, soundfiles, ...
    								datesfilename)
%makeCheckArray		convert log file info to boolean present/absent array
%
% [hrs,day0] = makeCheckArray(abstime, efforttimes, hrsfilename, ...
%                                                     soundfiles,datesfilename)
%    Given the Nx2 array abstime (t0) and the 1x2 vector efforttimes (eff)
%    as read by readDetLog, construct a Nx24 array 'hrs' that shows, for each 
%    hour, whether a call was detected during that hour.  If hrsfilename is 
%    not '', try reading it to get hrs (provided user wants to) and check 
%    that hrs's size is correct.  To make such an hrsfilename, simply save hrs
%    to it.
%   
%    The return arg hrs is a Nx24 array, one row per day and one column
%    per hour.  Its entries are
%        0    calls were not detected in that hour
%        1    calls were detected in that hour
%       NaN   no data; this hour is outside the range of efforttimes; occurs 
%                 only in the first or last row
%    hrs can also have other values if it is read from hrsfilename.  See
%    checkMissedCalls for an example.
%   
%    The first row of this array corresponds to the first day in efforttimes.
%    This day number (encoded as in datenum by readDetLog.m) is returned as 
%    day0.
%   
%    The input args soundfiles and datesfilename are used only for reporting 
%    errors.  They are typically used in calls to readDetLog (which gets 
%    abstime and efforttimes) and readHarufileDateIndex (which gets hIndex 
%    for readDetLog), respectively.
%
% See also readDetLog, checkDetections, checkMisses, readHarufileDateIndex.

day0 = floor(eff(1));		% the datenum day corresponding to hrs(1,:)

% Get rowIx, the row number within hrs, and colIx, the col number, for each
% value in t0.  These are the same size as t0.
rowIx = floor(t0) - day0 + 1;	% 
colIx = [floor(mod(t0(:,1),1) * 24)+1   ceil(mod(t0(:,2),1) * 24)];

hrs = zeros(ceil(eff(2)) - day0, 24);

% Try loading the file the user specified.
if (exist(hrsfilename, 'file'))		% works even if hrsfilename is ''
  while (1)
    yn = input(['A .mat file with previously saved work exists; load it?' ...
	    ' [y/n] '],...
      's');
    switch lower(yn)
    case 'y',
      load(hrsfilename);			% load 'hrs'
      hrs1 = hrs;
      if (any(size(hrs) ~= size(hrs1)))		% check hrs's size
	error(sprintf(['Array size in %s (%dx%d) is not the same as ' ...
		'indicated by efforttimes (%dx%d)'], hrsfilename, ...
	    nRows(hrs), nCols(hrs), nRows(hrs1), nCols(hrs1)));
      end
      return		% Done!  Don't need code below.
    case 'n', 
      disp(['WARNING: Answering 0 or 1 below will stomp on your ' ...
	      existing .mat file.']);
      break
    end
  end
end

% The first day's data don't start until partway through the day; similarly for
% the last day.  The fractional hour on each end gets ignored here.
hrs(1,   1 :  ceil(mod(eff(1), 1) * 24    )     ) = NaN;
hrs(end,     floor(mod(eff(2), 1) * 24 + 1) : 24) = NaN;

% Mark detected calls as 1's in 'hrs'.
for i = 1 : nRows(t0)
  if (isnan(rowIx(i,1)))
    printf(['Warning: Detection log shows call detected in %s, but that ' ...
	'file is missing from %s.'], soundfiles{i}, datesfilename);
  else
    hrs(rowIx(i,1)+1 : rowIx(i,2)-1, 1:24) = 1;		% whole days
    if (rowIx(i,1) == rowIx(i,2))
      hrs(rowIx(i,1), colIx(i,1) : colIx(i,2)) = 1;	% all within one day
    else
      hrs(rowIx(i,1),     colIx(i,1) : 24) = 1;		% end of one day...
      hrs(rowIx(i,2), 1 : colIx(i,2)     ) = 1;		% ...and start of next
    end
  end
end
