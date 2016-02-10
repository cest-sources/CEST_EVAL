function [Z_flipped] = calc_Z_flipped(P,Z)
%Calculates flipped z-Stack
%
%   input:  x_zspec (vector)
%           Z (1D z-spectrum or 4D or 3D zspec stack)
%
%   output: x_asym (vector)
%           ASYM (asym vector or 4D asym stack )

% get dimension of Z stack
Z_dim = numel(size(Z));

x_zspec=P.SEQ.w;

% % reshape old 3D into 4D stack [(x,y,offset) -> (x,y,slice,offset)]
if Z_dim == 3
    Z = reshape(Z,[size(Z,1),size(Z,2),1,size(Z,3)]);
end

Z_flipped=zeros(size(Z));

%Check if Offsets are  symmetrical
if (numel(x_zspec(x_zspec<=0)) == numel(x_zspec(x_zspec>=0)) && sum(abs(x_zspec(x_zspec<=0))) == sum(abs(x_zspec(x_zspec>=0))) )
    SYM_FLAG=1;
else
    SYM_FLAG=0;
end


if SYM_FLAG==0  % if acquisition was asymmetric
    
    % x,y,slice loop
    h=waitbar(0,'Z-spectrum is interpolated to be able to calculate asymmetry');
            
    for ii = 1:size(Z,1)
        for jj = 1:size(Z,2)
            waitbar(ii/size(Z,1),h,'Z-spectrum is interpolated to be able to calculate asymmetry');
            for kk = 1:size(Z,3)
                                % read z-spectrum
                zspec = squeeze(Z(ii,jj,kk,:));
                if (sum(isnan(zspec)) == 0)
                    
                    Z_flipped(ii,jj,kk,:)=calc_Z_flipped_1D(P,zspec); %calculate mirrored zspectrum
                    
                else
                    
                    Z_flipped(ii,jj,kk,:) = NaN(1,numel(x_zspec));
                    
                end
                
            end
        end
    end
    
else
    Z_flipped= Z(:,:,:,end:-1:1);
        
end



