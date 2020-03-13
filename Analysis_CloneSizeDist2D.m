%% LOAD EXPERIMENTAL CLONE SIZE DATA (e.g. from an Excel spreadsheet)
% Each data set contains number of basal and suprabasal cells for multiple
% clones in two experimental conditions
dataA_name = 'IR -NAC';
dataB_name = 'IR +NAC';
dataA = xlsread('./Data/example_p53mut_cloneSize_data.xlsx','IR -NAC');
dataB = xlsread('./Data/example_p53mut_cloneSize_data.xlsx','IR +NAC');
mydirectory = pwd;


%% CALCULATE AND PLOT 2D HISTOGRAM OF CLONE SIZE FREQUENCIES (SEPARATED FOR EACH EXPERIMENTAL CONDITION)
% General 2D heatmap settings:
FigProp.TopFreq = 0.125;
FigProp.colmap = colormap(jet(1000));
FigProp.colmap(1,:) = [1 1 1]; % force first element of colormap to be white
FigProp.BLsizeSpan = 200; FigProp.SBsizeSpan = 200; % wide enough margin to contain all clonal sizes
FigProp.BLsizeCutoff = 40; FigProp.SBsizeCutoff = 40; % threshold on clone sizes above which all frequencies are summarized together
FigProp.colorkey = true; % do not print colorkey
FigProp.DoBinning = true; % do bin clone sizes in groups for best granular visualization of heatmap
FigProp.BLbinSize = 2; FigProp.SBbinSize = 2; % each category in the heatmap represents 2 consecutive clone sizes
FigProp.XTick = [0:10:40]; FigProp.YTick = [0:10:40]; % axis ticks

figure()
subplot(1,2,1)
FigProp.name = dataA_name; % plot title
% Calculation and plot for experimental condition A:
[cloneFreq2D_A,geomed_A,ScaledAxis] = freq2D_heatmap(dataA(:,1),dataA(:,2),FigProp);

subplot(1,2,2)
FigProp.name = dataB_name; % plot title
% Calculation and plot for experimental condition B:
[cloneFreq2D_B,geomed_B,ScaledAxis_B] = freq2D_heatmap(dataB(:,1),dataB(:,2),FigProp);

% Retrieve respective geometrical median values (on No. of basal and suprabasal cells):
geomed_A
geomed_B

%% COMPARE DIFFERENCES IN CLONE SIZE FREQUENCIES BETWEEN TWO EXPERIMENTAL CONDITIONS (2D HISTOGRAM OF DIFFERENCES)
% General 2D heatmap settings:
FigProp.TopFreq = 0.125;
FigProp.colmap = [[zeros(1,37) 0:0.02:1]',...
    [zeros(1,37) 0:0.02:1]',...
    [(0.6:0.01:0.96)'; ones(51,1)];...
    [ones(50,1); fliplr(0.6:0.01:0.96)'],...
    fliplr([zeros(1,37) 0:0.02:0.98])'...
    fliplr([zeros(1,37) 0:0.02:0.98])']; % a customized colormap
FigProp.colorkey = true; % do print colorkey
FigProp.ScaledAxis = ScaledAxis; % saves rescaled axis info to fit with clone size grouping in individual heatmaps above (e.g. if data was binned)

% Set comparison plot for binned-versions of individual histograms:
Freq2D_A = cloneFreq2D_A.compact;
Freq2D_B = cloneFreq2D_B.compact;

figure()
FigProp.name = [dataB_name '  versus  ' dataA_name]; % plot title
% Calculation and plot:
[dif_cloneFreq2D] = freq2D_compare_heatmap(Freq2D_A,Freq2D_B,FigProp);    


%% STATISTICAL (2D KOLMOGOROV-SMIRNOV) TEST OF DIFFERENCES IN CLONE SIZE FREQUENCIES BETWEEN EXPERIMENTAL CONDITIONS:
% (see documentation and license in corresponding folder for further details)
cd './kstest_2s_2d/'
[H, pValue, KSstatistic] = kstest_2s_2d(dataA, dataB, 0.05) % H=1 means distributions of clone sizes are significantly different
cd (mydirectory)

