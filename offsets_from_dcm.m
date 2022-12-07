function [offsets,FREQ]=offsets_from_dcm(filename)

if nargin<1
   [FileName,PathName]= uigetfile('*.*','choose dicome file');
   filename=fullfile(PathName,FileName);
end

fid = fopen(filename, 'r'); str='';
while ~feof(fid)% Read the file line by line
    line = fgetl(fid);
    % Check if the line starts with the specific word
    if strncmp(line, 'sWipMemBlock.tFree', length('sWipMemBlock.tFree'))
        offset_str=sprintf('%s\n%s', str,line);
    end
    if strncmp(line,'sTXSPEC.asNucleusInfo[0].lFrequency', length('sTXSPEC.asNucleusInfo[0].lFrequency'))
        freq_str=sprintf('%s\n%s', str,line);
    end
end
fclose(fid);

% offset
regex = 'l:(.*)d:';
match1 = regexp(offset_str, regex, 'tokens');
newStr = split(match1{1}{1},'|');
newStr=newStr(2:end-1);
offsets = cellfun(@(x) str2num(x), newStr);

% FREQ
freq_str = split(freq_str,'=');freq_str=freq_str{2}; FREQ=str2num(freq_str)/10^6;

% offset ppm
offsets=offsets./FREQ;


