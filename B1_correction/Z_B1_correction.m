function [Z_stack_corr] = Z_B1_correction(Z_stack,rel_B1map,B1_input,B1_output,SEGMENT,fit_type,B1_input_index)
% [Z_stack_corr] = Z_B1_correction(Z_stack,rel_B1map,SEGMENT_2D,B1_input,fit_type,B1_input_index,B1_output)
% output: B1 corrected Z-stack (5D-stack)
% input:    Z_stack = 5D-stack of Z-spectra (y,x,z,offset,B1)
%           rel_B1map = relative B1map
%           B1_output = output B1 (scalar or vector)
%           SEGMENT = voxel/pixel mask for evaluation
%           fit_type = fit or interpolation type
%           B1_input_index = index vector of B1 samples that should be used
%           for correction
%
%   Date: 2015/04/01 
%   Version for CEST-sources.de
%   Author: Johannes Windschuh  - johannes.windschuh@dkfz.de
%   CEST sources  Copyright (C) 2014  Moritz Zaiss
%   **********************************
%   This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or(at your option) any later version.
%    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%    You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
%   **********************************
%
%   References:
%   Windschuh, J., Zaiss, M., Meissner, J.-E., Paech, D., Radbruch, A., Ladd, M. E., and Bachert, P.(2015), 
%   Correction of B1-inhomogeneities for relaxation-compensated CEST imaging at 7?T. 
%   NMR Biomed., 28: 529–537. doi: 10.1002/nbm.3283.
%
%   Zaiss M, Windschuh J, Paech D, Meissner JE, Burth S, Schmitt B, Kickingereder P, Wiestler B, Wick W, Bendszus M, Schlemmer HP, Ladd ME, Bachert P, Radbruch A.
%   Relaxation-compensated CEST-MRI of the human brain at 7T: Unbiased insight into NOE and amide signal changes in human glioblastoma.
%   Neuroimage. 2015 May 15;112:180-8. doi: 10.1016/j.neuroimage.2015.02.040.


mysize=size(Z_stack);

if nargin<7
    B1_input_index=[1:numel(B1_input)];
end

if nargin<6
    fit_type='smoothingspline';
end

if nargin<5
    SEGMENT=ones(mysize(1),mysize(2),mysize(3));
end

if nargin<4
    B1_output=mean(B1_input);
end

% Define absolute B1map
rel_B1map(rel_B1map>=3)=3;
rel_B1map(rel_B1map<=0)=0.01;

abs_B1map=ones(mysize(1),mysize(2),mysize(3),numel(B1_input));

if mysize(3)==1 % CEST is 2D
        for ii=1:numel(B1_input)
            abs_B1map(:,:,1,ii)= abs_B1map(:,:,1,ii)*B1_input(ii);
            abs_B1map(:,:,1,ii)=abs_B1map(:,:,1,ii).*rel_B1map;
        end
else % CEST is 3D
    if ndims(rel_B1map)==3
        for jj=1:mysize(3)
            for ii=1:numel(B1_input)
                abs_B1map(:,:,jj,ii)= abs_B1map(:,:,jj,ii)*B1_input(ii);
                abs_B1map(:,:,jj,ii)=abs_B1map(:,:,jj,ii).*rel_B1map(:,:,jj);
            end
        end   
    else
        sprintf('careful B1map is only 2D');
        for jj=1:mysize(3)
            for ii=1:numel(B1_input)
                abs_B1map(:,:,jj,ii)= abs_B1map(:,:,jj,ii)*B1_input(ii);
                abs_B1map(:,:,jj,ii)=abs_B1map(:,:,jj,ii).*rel_B1map(:,:);
            end
        end  
        
    end
    % add 3rd dimension to SEGMENT if necessary
    if ismatrix(SEGMENT)
        sprintf('careful SEGMENT is only 2D!');
        for jj=1:mysize(3)
            SEGMENT(:,:,jj)=SEGMENT(:,:,1);
        end
    end
    
end

%Choose fit/interpolation type
if (strcmp(fit_type,'smoothingspline'))
    fo_ = fitoptions('method','SmoothingSpline','SmoothingParam',0.998);
    ft_ = fittype('SmoothingSpline');
elseif(strcmp(fit_type,'poly2'))
    ft_ = fittype(fit_type);
    fo_ = fitoptions(ft_);
elseif(strcmp(fit_type,'poly3'))
    ft_ = fittype(fit_type);
    fo_ = fitoptions(ft_);
elseif(strcmp(fit_type,'poly4'))
    ft_ = fittype(fit_type);
    fo_ = fitoptions(ft_);
elseif(strcmp(fit_type,'poly5'))
    ft_ = fittype(fit_type);
    fo_ = fitoptions(ft_);
elseif(strcmp(fit_type,'spline'))
    inter_method=fit_type; 
elseif(strcmp(fit_type,'linear'))
    inter_method=fit_type;
end

% parallel 
if (0==1)% (exist('Composite')>0)

    % DEFINE COMPOSITS
    SEGMENT_c = Composite();
    abs_B1map_c = Composite();
    Z_stack_corr_c = Composite();
    Z_stack_c = Composite();
    % wieviele matlabpools
    npools=size(Z_stack_corr_c,2); 
    np=mysize(2)/npools;
    % teilintervalle
    IV = @(i) 1+fix(np*(i-1)):fix(np*(i)); %InterVals

    for ii = 1:npools
        SEGMENT_c{ii}=SEGMENT(:,IV(ii),:);
        abs_B1map_c{ii}=abs_B1map(:,IV(ii),:,:);
        Z_stack_c{ii}=Z_stack(:,IV(ii),:,:,:);
        Z_stack_corr_c{ii}=NaN(mysize(1),numel(IV(ii)),mysize(3),mysize(4),numel(B1_output));

    end

    spmd
                     
        for ll=1:mysize(3) %slice
            for ii=1:mysize(1) %y
                  for jj=1:numel(IV(labindex)) %x
                      for kk=1:mysize(4) % Offset
                          if(SEGMENT_c(ii,jj,ll)==1 && max(isnan(Z_stack_c(ii,jj,ll,kk,B1_input_index)))==0 && max(isinf(Z_stack_c(ii,jj,ll,kk,B1_input_index)))==0 && max(isnan(abs_B1map_c(ii,jj,ll,:)))==0 )
%                               
                              if (strcmp(fit_type,'linear') || strcmp(fit_type,'spline'))
                                  Z_stack_corr_c(ii,jj,ll,kk,:) = interp1(squeeze(abs_B1map_c(ii,jj,ll,B1_input_index)),squeeze(Z_stack_c(ii,jj,ll,kk,B1_input_index)),B1_output,inter_method,'extrap');
                              else
                                  cf_ = fit(squeeze(abs_B1map_c(ii,jj,ll,B1_input_index)),squeeze(Z_stack_c(ii,jj,ll,kk,B1_input_index)),ft_,fo_);
                                  Z_stack_corr_c(ii,jj,ll,kk,:)=cf_(B1_output);  
                              end
                              
                          else
                              Z_stack_corr_c(ii,jj,ll,kk,:)  = NaN(numel(B1_output),1);
                          end
                      end

                  end    
            end
        end
    

    end 
    
    % reallocate labs to local
    Z_stack_corr=cat(2,Z_stack_corr_c{:});
    
else % not parallel

   Z_stack_corr=NaN(mysize(1),mysize(2),mysize(3),mysize(4),numel(B1_output));

    for ll=1:mysize(3) %slice
        for ii=1:mysize(1) % y
              for jj=1:mysize(2) %x
                  for kk=1:mysize(4) % Offsets
                      if(SEGMENT(ii,jj,ll)==1 && max(isnan(Z_stack(ii,jj,ll,kk,B1_input_index)))==0 && max(isinf(Z_stack(ii,jj,ll,kk,B1_input_index)))==0 && max(isnan(abs_B1map(ii,jj,ll,B1_input_index)))==0)
                          if (strcmp(fit_type,'linear') || strcmp(fit_type,'spline'))
                                Z_stack_corr(ii,jj,ll,kk,:) = interp1(squeeze(abs_B1map(ii,jj,ll,B1_input_index)),squeeze(Z_stack(ii,jj,ll,kk,B1_input_index)),B1_output,inter_method,'extrap');
                          else
                                cf_ = fit(squeeze(abs_B1map(ii,jj,ll,B1_input_index)),squeeze(Z_stack(ii,jj,ll,kk,B1_input_index)),ft_,fo_);  
                                Z_stack_corr(ii,jj,ll,kk,:)=cf_(B1_output);
                          end
                      else
                          Z_stack_corr(ii,jj,ll,kk,:)  = NaN(numel(B1_output),1);
                      end
                  end

              end  
        end 
    end 
    
end %if parallel
