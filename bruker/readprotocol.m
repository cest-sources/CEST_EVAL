function P = readprotocol(directory)
% ** function P = readprotocol(directory)
%
% Given patient directory, creates structure 'P' with fields:
%   'FolderNum': name of folder (in Bruker's directory structure, a number)
%   'SequenceDescription': extracted from DICOM header file as either the
%       'SeriesDescription' (sequence name set by the user at the scanner)
%       or the 'ProtocolName' parameter.
%
% CT 20170113

P = dir(directory);
[P.FolderNum] = P.name;
P = rmfield(P, {'name', 'date', 'bytes', 'isdir', 'datenum'});

nonnumericmask = cellfun('isempty', regexp({P.FolderNum},'^\d+$'));
P(nonnumericmask) = [];  % sequence folder names must be numbers
for i=1:length(P)
    nzeros=0;
    ERR=1;
    while ERR
        nzeros = nzeros+1;
        try
            dicomhdr = dicominfo(fullfile(directory,P(i).FolderNum,'pdata/1/dicom',sprintf('MRIm%0*d.dcm',nzeros,1)));
            ERR=0;
        catch
        end
    end
    if isfield(dicomhdr, 'SeriesDescription')
        P(i).SequenceDescription = dicomhdr.SeriesDescription;
    elseif isfield(dicomhdr, 'ProtocolName')
        P(i).SequenceDescription = dicomhdr.ProtocolName;
    else
        P(i).SequenceDescription = '';
        warning(sprintf('Could not extract sequence description of folder ''%s''.', P(i).FolderNum));
    end
end

% sort entries by increasing folder number (to preserve sequence order)
[~,ixsort] = sort(str2double({P.FolderNum}));
P = P(ixsort);