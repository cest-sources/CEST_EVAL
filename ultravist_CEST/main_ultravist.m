% ======================= main_ultravist ======================= %
% Script for pH mapping with Ultravist phantom (work in progress)
% CT 20170113

%% calculate log10ratio
CESTratiomap = log10ratio(popt, P, Segment, [4.2 5.6]);

%% -------------------- CEST-pH calibration --------------------
%% Load phantom scans and fit z-spectra
LOAD_BATCH_cest-sources
Segment = make_Segment(M0_stack, 'ellipse', mean(M0_stack(M0_stack>0)).*[0.3]); 
Z_uncorr = NORM_ZSTACK(Mz_stack,M0_stack,P,Segment);
[~, ~, P, popt] = lorentzianfit_main(Z_uncorr, P, Segment, 'ultravist');

%% log10 ratio of MTR_Rex
delta = [4.2 5.6];
CESTratio = log10ratio(popt, P, Segment, delta);
figure; imagesc(CESTratio); colorbar;
title('log_{10}[MTR_{4.2ppm} / MTR_{5.6ppm}]')

%% extract mean log10ratio from phantom ROIs
W = evalin('base','whos');
doesSegmentExist = ismember('Segment_ph',[W(:).name]);
if ~doesSegmentExist
    Segment_ph = nan(size(CESTratio,1), size(CESTratio,2), 7);
    for i=1:7
        Segment_ph(:,:,i) = make_Segment(CESTratio, 'ellipse');
    end
end

CESTratio_ROIs = nan(1,7);
for i=1:7
    roivals = CESTratio .* Segment_ph(:,:,i);
    CESTratio_ROIs(i) = nanmean(roivals(:));
end
clear roivals

%% pH-CEST curve
ph =        [6.1   6.3   6.5   6.7   6.9   7.1   7.3];
% phantom#   7     6     5     4     3     2     1
CESTratio_ROIs = flip(CESTratio_ROIs);
figure;
plot(ph, CESTratio_ROIs, '+', 'markersize', 8)
set(gca,'xtick',ph);
xlabel('pH')
ylabel('log_{10}[((M0-Mz)/Mz)_{4.2ppm} / ((M0-Mz)/Mz)_{5.6ppm}]')
title(sprintf('pH-CEST calibration at B1=%duT', P.SEQ.B1))
hold on
lsline

%% linear regression fit
% calibration model (pH ~ CESTratio)
calibmdl = fitlm(CESTratio_ROIs,ph);

%% ----------------------- pH map ------------------------
pH_pred = predict_pH(calibmdl,CESTratiomap);
figure; imagesc(pH_pred); colorbar;
title('pH map')