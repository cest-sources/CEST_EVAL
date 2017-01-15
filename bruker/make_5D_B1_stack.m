function Z_stack = make_5D_B1_stack(protocol, directory_M0, M0_stack, Segment, varargin)
% ** function Z_stack = make_5D_B1_stack(protocol, directory_M0, M0_stack, Segment, seqDescr1, ..., seqDescrN)
%
% Creates 5D stack of z-spectra for each saturation field power (B1).
% Input is sequence descriptions of Mz images at different B1 values.
% Output 'Z_stack' dimensions are (x,y,z,w,B1).
%
% CT 20170111

nsat = nargin-4;
directory = regexprep(directory_M0, '/\d{1,2}$', '');

for i = 1:nsat
    fprintf('Processing z-spectrum for ''%s'' ...\n', varargin{i});
    directory_Mz = getfolderpath(directory, protocol, varargin{i});
    Mz_stack = load_Mz(directory_Mz);
    P = wipread_modified(directory_Mz, directory_M0);

    % calculate B0-corrected z-spectra
    [dB0_stack_int,~] = MINFIND_SPLINE_3D(Mz_stack, Segment, P);
    Mz_CORR = B0_CORRECTION(Mz_stack, dB0_stack_int, P, Segment);
    Z_corrExt = NORM_ZSTACK(Mz_CORR, M0_stack, P, Segment);

    Z_stack(:,:,:,:,i) = Z_corrExt;
end