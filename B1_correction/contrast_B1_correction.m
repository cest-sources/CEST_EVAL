function [corr_img]=contrast_B1_correction(img,rel_B1map,B1_input,B1_output,SEGMENT_2D,fit_type,B1_input_index)
% [corr_img]=contrast_B1_correction(img,rel_B1map,B1_input,B1_output,SEGMENT_2D,fit_type,B1_input_index)
% output: B1 corrected images (2D or 3D-stack) (x,y,B1)
% input:    img = 3D-stack of images (x,y,B1) which are used for B1-correciton
%           rel_B1map = relative B1map
%           B1_output = output B1 (scalar or vector)
%           SEGMENT_2D = pixel mask for evaluation
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
%   Windschuh, J., Zaiss, M., Meissner, J.-E., Paech, D., Radbruch, A., Ladd, M. E., and Bachert, P., 
%   Correction of B1-inhomogeneities for relaxation-compensated CEST imaging at 7?T. 
%   NMR Biomed. 2015, 28: 529–537. doi: 10.1002/nbm.3283.
%
%   Zaiss M, Windschuh J, Paech D, Meissner JE, Burth S, Schmitt B, Kickingereder P, Wiestler B, Wick W, Bendszus M, Schlemmer HP, Ladd ME, Bachert P, Radbruch A.
%   Relaxation-compensated CEST-MRI of the human brain at 7T: Unbiased insight into NOE and amide signal changes in human glioblastoma.
%   Neuroimage. 2015 May 15;112:180-8. doi: 10.1016/j.neuroimage.2015.02.040.




mysize=size(img);

if nargin<7
    B1_input_index=[1:numel(B1_input)];
end

if nargin<6
    fit_type='smoothingspline';
end

if nargin<5
    SEGMENT_2D=ones(mysize(1),mysize(2));
end

if nargin<4
    B1_output=mean(B1_input);
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

rel_B1map(rel_B1map>3)=3;
rel_B1map(rel_B1map<=0)=0.01;

abs_B1map=ones(mysize(1),mysize(2),mysize(3));

for ii=1:numel(B1_input)
    abs_B1map(:,:,ii)= abs_B1map(:,:,ii)*B1_input(ii);
    abs_B1map(:,:,ii)=abs_B1map(:,:,ii).*rel_B1map;
end

for ii=1:mysize(1)
      for jj=1:mysize(2)
          if(sum(isnan(squeeze(img(ii,jj,:))))==0 && sum(isinf(squeeze(img(ii,jj,:))))==0 && sum(sum(squeeze(img(ii,jj,:)))~=0) && sum(isnan(squeeze(rel_B1map(ii,jj,:))))==0 && sum(isinf(squeeze(rel_B1map(ii,jj,:))))==0 && SEGMENT_2D(ii,jj)==1)
              
              if (strcmp(fit_type,'linear') || strcmp(fit_type,'spline'))
                    corr_img(ii,jj,:)=interp1(abs_B1map(ii,jj,B1_input_index),squeeze(img(ii,jj,B1_input_index)),B1_output,inter_method,'extrap');
              else
                    cf_ = fit(squeeze(abs_B1map(ii,jj,B1_input_index)),squeeze(img(ii,jj,B1_input_index)),ft_,fo_);
                    corr_img(ii,jj,:)  = cf_(B1_output);
              end         
 
          else
              corr_img(ii,jj,:)  = zeros(numel(B1_output),1);
          end
         
      end    
end
