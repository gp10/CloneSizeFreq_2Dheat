function [dif_cloneFreq2D] = freq2D_compare_heatmap(cloneFreq2D_ref,cloneFreq2D_sample,FigProp)
%% Compares and plots differences in basal and suprabasal clone size frequencies between two experimental conditions (two 2D-histograms)
% It evaluates differences in clone frequency for every basal-size bin
% (number of basal cells) and every suprabasal-size bin (number of
% suprabasal cells), and displays the outcome as a 2D histogram showing
% clone sizes enriched in an experimental condition (test sample) vs. a
% reference one (ref).

%% Input:
% cloneFreq2D_ref: MxN matrix containing frequencies of clones in reference sample with certain number of basal cells and suprabasal cells (n and m, respectively, in simplest case where sizes are non-binned).
% cloneFreq2D_sample: MxN matrix containing frequencies of clones in test sample with certain number of basal cells and suprabasal cells (n and m, respectively, in simplest case where sizes are non-binned).
% FigProp: structure containing general display settings
    % struct{TopFreq, name, colmap, BLsizeSpan, SBsizeSpan, BLsizeCutoff, SBsizeCutoff, colorkey, DoBinning, BLbinSize, SBbinSize, XTick, YTick}
        % TopFreq: specifies the maximum frequency to map to the maximum color in the heatmap colormap
        % name: string used for figure title
        % colmap: heatmap colormap palette
        % colorkey: display the colorkey along with the heatmap (true | false)
        % ScaledAxis: structure containing axis features to fit input data spacing (i.e. actual bin size used for clone size grouping)
            % struct{XTick, YTick, XTickLabel, YTickLabel}
                % XTick: vector with rescaled positions of reference basal clone sizes (ticks).
                % YTick: vector with rescaled positions of reference suprabasal clone sizes (ticks).
                % XTickLabel: array of strings with names of reference basal clone sizes (ticks).
                % YTickLabel: array of strings with names of reference suprabasal clone sizes (ticks).

%% Output:
% dif_cloneFreq2D: MxN matrix of differences in clone frequencies for the distinct basal and suprabasal size categories (n and m, respectively).

%% Example:
% cloneFreq2D_ref = poisspdf([0:27],10)'*poisspdf([0:27],10);
% cloneFreq2D_sample = poisspdf([0:27],15)'*poisspdf([0:27],15);
% FigProp.TopFreq = 0.075;
% FigProp.name = 'Sample vs. CTL';
% FigProp.colmap = [[zeros(1,37) 0:0.02:1]', [zeros(1,37) 0:0.02:1]', [(0.6:0.01:0.96)'; ones(51,1)];   [ones(50,1); fliplr(0.6:0.01:0.96)'], fliplr([zeros(1,37) 0:0.02:0.98])' fliplr([zeros(1,37) 0:0.02:0.98])'];
% FigProp.colorkey = true;
% FigProp.ScaledAxis.XTick = [1 8 15 21 28];
% FigProp.ScaledAxis.YTick = [1 8 15 21 28];
% FigProp.ScaledAxis.XTickLabel = {'0', '20', '40', '60', '\geq80'};
% FigProp.ScaledAxis.YTickLabel = {'0', '20', '40', '60', '\geq80'};
% [dif_cloneFreq2D] = freq2D_compare_heatmap(cloneFreq2D_ref,cloneFreq2D_sample,FigProp);

%% Check input matrices have same dimensions:
if size(cloneFreq2D_ref) ~= size(cloneFreq2D_sample)
    disp('Sizes of matrices being compared are not consistent. Impossible to compute clone size frequency differences');
    return
end
                
%% Calculate matrix of differences in clone size frequencies:
% (x-axis: basal size | y-axis: suprabasal size)
dif_cloneFreq2D = cloneFreq2D_sample - cloneFreq2D_ref;

%% Plotting:
% Plot 2D histogram of differences in clone size frequencies:
hold on
imagesc(dif_cloneFreq2D,[-FigProp.TopFreq FigProp.TopFreq])

% Axis ticks:
set(gca,'YTick',FigProp.ScaledAxis.YTick);
set(gca,'XTick',FigProp.ScaledAxis.XTick);

% Axis labels:
set(gca,'YTickLabel',FigProp.ScaledAxis.YTickLabel);
set(gca,'XTickLabel',FigProp.ScaledAxis.XTickLabel);

% Axis properties:
xlim([0.5 size(dif_cloneFreq2D,2)+0.5]);  ylim([0.5 size(dif_cloneFreq2D,1)+0.5]);
set(gca,'YDir','normal')
xlabel('# B'); ylabel('# SB');
axis square
box on

title(FigProp.name)

% Colormap:
colormap(FigProp.colmap)
if FigProp.colorkey
    colorbar % Displays colorkey
end
