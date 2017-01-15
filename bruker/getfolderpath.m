function varargout = getfolderpath(directory, protocol, varargin)
% ** function [path1, ..., pathN] = getfolderpath(directory, protocol, SequenceDescription1, ..., SequenceDescriptionN)
%
% Retrieves path of a sequence's directory. A sequence is identified by
% its 'SequenceDescription' string, stored in protocol structure 'protocol'
% created by function 'readprotocol'.
% Input is one or more 'SequenceDescription' strings.
% Output is one or more 'path' strings.
%
% CT 20170113

if nargin<3
    error('Must specify one or more input strings')
end

nseq = nargin-2;
if nargout~=nseq
    error('Number of outputs must be equal to number of input strings.')
end

for n=1:nseq
    ix = find(strcmp({protocol.SequenceDescription}, varargin{n}));
    if ~isempty(ix)
        varargout{n} = fullfile(directory, protocol(ix).FolderNum);
    else  
        error(['No folder number is associated with sequence description ''', varargin{n}, '''.']);
    end
end