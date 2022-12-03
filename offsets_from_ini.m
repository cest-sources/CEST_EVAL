function [offsets]=offsets_from_ini(filename)

if nargin<1
   [FileName,PathName]= uigetfile('*.*','choose ini file');
   filename=fullfile(PathName,FileName);
end

str = fileread(filename);

% Define the regular expression
regex = 'cestoffset\[\d+\]\s*=\s*([\d\.]+)';
% Extract the values of cestoffset
match = regexp(str, regex, 'tokens')
offsets = str2double([match{:}])



