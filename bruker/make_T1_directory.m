function T1dirpath = make_T1_directory(directory, protocol, TI, ix_T1)
% ** function T1dirpath = make_T1_directory(TI, directory, protocol, ix_T1)
%
% Make folder containing DICOM files of TI images for T1 mapping. Changes
% DICOM header for compatibility with fitting function T1eval_levmar.
% Inputs: 'TI' is a vector of inversion recovery times.
%         'ix_T1' is a vector of protocol entry numbers of T1 images.
% Output is the full path to the new directory of T1 images.
%
% CT 20170115

T1dirpath = fullfile(directory, 'T1dicoms');
mkdir(T1dirpath);
cd(T1dirpath);

if length(ix_T1)==length(TI)
    for i=1:length(TI)
        pathT1 = fullfile(directory, 'T1dicoms', sprintf('TI%04d.dcm', TI(i)));
        copyfile(fullfile(getfolderpath(directory,protocol,protocol(ix_T1(i)).SequenceDescription),...
            'pdata/1/dicom/MRIm1.dcm'), pathT1);
        dmat = dicomread(pathT1);
        dhead = dicominfo(pathT1);
        dhead.AcquisitionNumber = i;
        dhead.InstanceNumber = 1;
        dhead.ImagesInAcquisition = length(TI);
        dicomwrite(dmat, sprintf('TI%04d.dcm', TI(i)), dhead, 'CreateMode', 'copy');
    end
else
    error('Number of TI images does not correspond to number of specified inversion times.')
end