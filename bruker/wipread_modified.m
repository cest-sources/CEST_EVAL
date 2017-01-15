function P = wipread_modified(directory_Mz, directory_M0)
% ** function P = wipread_modified(directory_Mz, directory_M0)
%
% Writes parameters of Mz and M0 images to structure 'P'.
% Modified for compatibility with Bruker/Paravision data format.
%
% CT 20161205

try
    methodpath = [directory_Mz, '/method'];
    acqppath = [directory_Mz, '/acqp'];
    acqppathM0 = [directory_M0, '/acqp'];
    recopath = [directory_Mz, '/pdata/1/reco'];
    dicompath = [directory_Mz, '/pdata/1/dicom/MRIm01.dcm'];
    dicomhdr = dicominfo(dicompath);
catch ME
    ME
end

% cell strings for the string parameters
pulse_shape = {'Gauss' 'Sinc' 'Rect' 'Spinlock' 'Adia Fullpass' 'Adia Spinlock' 'AdiaInvRec' 'Fermi'};
spoiling = {'none' 'constant' 'alternating' 'varying'};
sampling = {'regular' 'alternating' 'List' 'SingleOffset'};

% write all parameters into P struct
try
    P.SEQ.imageflipangle    = dicomhdr.FlipAngle;
    P.SEQ.averages          = dicomhdr.NumberOfAverages;
    P.SEQ.nominalB0         = dicomhdr.MagneticFieldStrength;
    P.SEQ.FS                = round(P.SEQ.nominalB0);
    P.SEQ.FREQ              = dicomhdr.ImagingFrequency;
    P.SEQ.measurements      = dicomhdr.ImagesInAcquisition; % number of repetitions
    P.SEQ.TR                = dicomhdr.RepetitionTime;
    P.SEQ.TE                = dicomhdr.EchoTime;
    P.SEQ.B1                = mineExecFile(methodpath, '##$PVM_MagTransPower');
    P.SEQ.n                 = mineExecFile(methodpath, '##$PVM_MagTransPulsNumb');
    P.SEQ.tp                = mineExecFile(methodpath, '##$PVM_MagTransPulse1')/1000;  % pulse duration in seconds
    P.SEQ.DC                = mineExecFile(acqppath, '##$HDDUTY');  % homodecoupling duty cycle? (CHECK)
    P.SEQ.recovertime       = mineExecFile(acqppath, '##$ACQ_recov_time');
    P.SEQ.recovertimeM0     = mineExecFile(acqppathM0, '##$ACQ_recov_time');
    P.SEQ.sampling          = sampling{1};    % let's assume regular sampling (CHECK)
    P.SEQ.w                 = mineExecFile(acqppath, '##$ACQ_O2_list')'/P.SEQ.FREQ;
    P.SEQ.Offset            = max(P.SEQ.w);
    P.SEQ.stack_dim         = [mineExecFile(recopath, '##$RECO_size'), 1, P.SEQ.measurements];
    P.EVAL.N_asym           = fix((P.SEQ.measurements-1)/2);
    P.EVAL.w_fit            = (min(P.SEQ.w):0.01:max(P.SEQ.w))';
    P.EVAL.w_interp         = P.SEQ.w;
    P.EVAL.lowerlim_slices  = 1;
    P.EVAL.upperlim_slices  = 1;    % we're working on single-slice data
catch ME
    warning(sprintf('Could not write all parameters into P structure.\n'));
    ME
end