function B1_vector = get_protocol_B1_values(directory, protocol, varargin)
% ** function B1_vector = get_protocol_B1_values(directory, protocol, sequenceDescription1, ... sequenceDescriptionN)
%
% Returns B1 values for the specified sequence(s).
% Input is one or more sequence description strings.
%     e.g. 'protocol(3:6).SequenceDescription' for protocol entries 3-6.
% Output is a vector of B1 field strength (in microTesla) of each sequence.
%
% CT 20170111

if nargin<3
    error('Must specify one or more input strings')
end

B1_vector = nan(1, nargin-2);
for i=1:nargin-2
    seqdirec = getfolderpath(directory, protocol, varargin{i});
    methodpath = [seqdirec, '/method'];
    B1_vector(i) = mineExecFile(methodpath, '##$PVM_MagTransPower');
end