function paramval = mineExecFile(filepath, paramname)
% ** function paramval = mineExecFile(filepath, paramname)
%
% Extracts parameter from a Bruker executable file, e.g. 'method', 'acqp'
% or 'reco' file in the scan directory.
%     e.g. B1value = mineExecFile(methodpath, '##$PVM_MagTransPower')
% See Paravision manual for list/description of (most) parameters.
%
% CT 20170113

FID = fopen(filepath,'r');
A = textscan(FID,'%s','delimiter','=','whitespace','');
fclose(FID);

pos_param = find(strcmp(A{1}, paramname)) + 1;
if ~isempty(pos_param)
    paramval = A{1}{pos_param};
    
    % check for bad value (e.g. '( 1 )')
    if regexp(paramval, '^\( \d.* \)$')
        pos_param = pos_param+1;
        paramval = A{1}{pos_param};
    end
    % check for values (e.g. row vector) continuing on multiple cells
    while isempty(regexp(A{1}{pos_param+1}, '^(#|\$)', 'once'))
        pos_param = pos_param+1;
        paramval = [paramval A{1}{pos_param}];
    end
    % check for parameter list
    if regexp(paramval, '^\(\d.*\)$')
        ix = 1;   % index of parameter in the list (not in manual--check in Paravision GUI!)
        paramlist = regexp(paramval, '([^\(\)\s]+?)(?:,|$)', 'match');
        paramlist = regexprep(paramlist,',','');
        paramval = paramlist{ix};
    end
    
    paramdouble = str2double(cellstr(strsplit(paramval)));
    if ~isnan(paramdouble)
        paramval = paramdouble;
    end
else
    error(['No value found for parameter name ''',paramname,'''']);
end