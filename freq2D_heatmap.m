function [cloneFreq2D,geomed,ScaledAxis,sizes_BL,sizes_SB] = freq2D_heatmap(cloneSizes_BL,cloneSizes_SB,FigProp)
%% Calculate and plot a 2D-histogram of the number of basal and suprabasal cells per clone
% Calculates the clone size frequencies for a list of clones with a given
% number of basal and suprabasal cells, and displays the 2D histogram
% (ie. frequency in the number of basal cells, frequency in the number of
% suprabasal cells) as a 2D heatmap.

%% Input:
% cloneSizes_BL: column vector of size [m,1] containing the number of basal cells in the m different clones.
% cloneSizes_SB: column vector of size [m,1] containing the number of suprabasal cells in the m different clones.
% FigProp: structure containing general display settings
    % struct{TopFreq, name, colmap, BLsizeSpan, SBsizeSpan, BLsizeCutoff, SBsizeCutoff, colorkey, DoBinning, BLbinSize, SBbinSize, XTick, YTick}
        % TopFreq: specifies the maximum frequency to map to the maximum color in the heatmap colormap
        % name: string used for figure title
        % colmap: heatmap colormap palette
        % BLsizeSpan: max. magin of basal clone sizes to extract frequencies from (make it higher than the actual one to make sure all clones are counted)
        % SBsizeSpan: max. magin of suprabasal clone sizes to extract frequencies from (make it higher than the actual one to make sure all clones are counted)
        % BLsizeCutoff: basal-size cutoff for which all clones with a number of basal cells equal or higher than this value are condensed and displayed together.
        % SBsizeCutoff: suprabasal-size cutoff for which all clones with a number of suprabasal cells equal or higher than this value are condensed and displayed together.
        % colorkey: display the colorkey along with the heatmap (true | false)
        % DoBinning: display basal and/or suprabasal clone sizes binned in groups, for better visualization of a coarse-grained frequency histogram (true | false)
        % BLbinSize: bin size used for grouping basal clone sizes and computing grouped size frequencies.
        % SBbinSize: bin size used for grouping suprabasal clone sizes and computing grouped size frequencies.
        % XTick: vector of basal clone sizes at which to set x-axis tick values.
        % YTick: vector of suprabasal clone sizes at which to set y-axis tick values.

%% Output:
% cloneFreq2D: structure containing clone size frequencies
    % struct{full, bin, compact}
        % full: original NxP matrix containing frequencies of clones with n=0,..,N suprabasal cells and p=0,..,P basal cells (N and P set by SBsizeSpan and BLsizeSpan, respectively).
        % bin: QxR matrix containing frequencies of clones with sizes binned in groups of b; i.e. dimensions Q=N/b and R=P/b.
        % compact: the matrix of binned clone size frequencies is further constrained to group together clones exceeding a certain size (BLsizeCutoff and SBsizeCutoff).
% geomed: geometrical median, given as a two-component vector: median number of basal cells, median number of suprabasal cells, respectively
% ScaledAxis: structure containing info on axis position of given clone sizes in compact-size heatmap (after binning and trimming)
    % struct{XTick, YTick, XTickLabel, YTickLabel}
        % XTick: vector with rescaled positions of reference basal clone sizes (ticks).
        % YTick: vector with rescaled positions of reference suprabasal clone sizes (ticks).
        % XTickLabel: array of strings with names of reference basal clone sizes (ticks).
        % YTickLabel: array of strings with names of reference suprabasal clone sizes (ticks).
% sizes_BL: structure containing basal clone sizes represented in each element (bin) of the heatmap x-axis
    % struct{full, bin, compact}
        % full: cell array of all clone sizes mapping to cloneFreq2D.full column elements.
        % bin: cell array with R elements, each showing clone sizes represented in each bin mapping to a specific cloneFreq2D.bin column element.
        % compact: cell array of clone sizes represented in each bin mapping to a specific cloneFreq2D.compact column element.
% sizes_SB: structure containing suprabasal clone sizes represented in each element (bin) of the heatmap y-axis
    % struct{full, bin, compact}
        % full: cell array of all clone sizes mapping to cloneFreq2D.full row elements.
        % bin: cell array with R elements, each showing clone sizes represented in each bin mapping to a specific cloneFreq2D.bin row element.
        % compact: cell array of clone sizes represented in each bin mapping to a specific cloneFreq2D.compact row element.

%% Example:
% cloneSizes_BL = poissrnd(15,[1000 1]);
% cloneSizes_SB = round(poissrnd(15,[1000 1]).*1.4);
% FigProp.TopFreq = 0.125;
% FigProp.name = 'example';
% FigProp.colmap = [1 1 1; colormap(jet(1000))];
% FigProp.BLsizeSpan = 200; FigProp.SBsizeSpan = 200;
% FigProp.BLsizeCutoff = 60; FigProp.SBsizeCutoff = 60;
% FigProp.colorkey = true;
% FigProp.DoBinning = true;
% FigProp.BLbinSize = 3; FigProp.SBbinSize = 3;
% FigProp.XTick = [0:10:60]; FigProp.YTick = [0:10:60];
% [cloneFreq2D,geomed,ScaledAxis,sizes_BL,sizes_SB] = freq2D_heatmap(cloneSizes_BL,cloneSizes_SB,FigProp);

%% Calculation of clone size frequencies:
% Preset a large matrix to contain clone size frequencies:
cloneFreq2D.full = zeros(FigProp.SBsizeSpan,FigProp.BLsizeSpan); % each row = a number of suprabasal cells; each column = a number of basal cells
% Update frequencies given each clone size:
for aja = 1:length(cloneSizes_BL)
    cloneFreq2D.full(cloneSizes_SB(aja,1)+1,cloneSizes_BL(aja,1)+1) = cloneFreq2D.full(cloneSizes_SB(aja,1)+1,cloneSizes_BL(aja,1)+1) + 1;
end
% Normalize clone size frequencies (to 1):
cloneFreq2D.full = cloneFreq2D.full ./ length(cloneSizes_BL);
% Retrieve all possible clone sizes as a cell array of numbers (each mapping to a row or column in cloneFreq2D.full):
sizes_BL.full = num2cell([0:1:FigProp.BLsizeSpan-1]);
sizes_SB.full = num2cell([0:1:FigProp.SBsizeSpan-1]);

%% Geometrical median calculation:
geomed = geomedian_calculation([cloneSizes_BL cloneSizes_SB]);

%% Binning clone sizes in groups (frequencies summed) (if-need-be):
if FigProp.DoBinning
    
    % Expand the cloneFreq2D matrix to accomodate 0-cells as a first, separate bin (i.e. together with -1cells, etc)
    cloneFreq2D_long = [zeros(size(cloneFreq2D.full,1),FigProp.SBbinSize-1) cloneFreq2D.full];
    cloneFreq2D_long = [zeros(FigProp.BLbinSize-1,size(cloneFreq2D_long,2)); cloneFreq2D_long];
    
    % Assign clone sizes to bins:
    cloneFreq2D.bin = [];
    sizes_BL.bin = {};
    sizes_SB.bin = {};
    for aja = 1:floor( (FigProp.SBsizeSpan+FigProp.SBbinSize-1) /FigProp.SBbinSize) % iterate on each suprabasal-size bin
        % Retrieve suprabasal clone sizes contained in each bin (that will map to each row in cloneFreq2D.bin):
        sizes_SB.bin{1,aja} = [ FigProp.SBbinSize*(aja-2)+1 : FigProp.SBbinSize*(aja-1) ];
        for aje = 1:floor( (FigProp.BLsizeSpan+FigProp.BLbinSize-1) /FigProp.BLbinSize) % iterate on each basal-size bin
            % Retrieve basal clone sizes contained in each bin (that will map to each column in cloneFreq2D.bin):
            sizes_BL.bin{1,aje} = [ FigProp.BLbinSize*(aje-2)+1 : FigProp.BLbinSize*(aje-1) ];
            % Pool together frequencies of clones with a size belonging to the same bin:
            mytarget = cloneFreq2D_long( FigProp.SBbinSize*(aja-1)+1 : FigProp.SBbinSize*aja, FigProp.BLbinSize*(aje-1)+1 : FigProp.BLbinSize*aje );
            cloneFreq2D.bin(aja,aje) = sum(sum( mytarget(isnan(mytarget)==0) ));
        end
    end
    
else
    % keep binned data as original one (i.e. bin size = 1)
    cloneFreq2D.bin = cloneFreq2D.full;
    sizes_BL.bin = sizes_BL.full;
    sizes_SB.bin = sizes_SB.full;
end

%% Trimming clone sizes: sizes above a certain threshold are shown as a single elemement (frequencies summed):
% Define cutoff element in the matrix of binned frequencies:
if FigProp.DoBinning
    BL_cutoffBin = ceil( (FigProp.BLsizeCutoff +FigProp.BLbinSize) / FigProp.BLbinSize ); % first element is BLsize=..,-1,0
    SB_cutoffBin = ceil( (FigProp.SBsizeCutoff +FigProp.SBbinSize) / FigProp.SBbinSize ); % first element is SBsize=..,-1,0
else
    BL_cutoffBin = FigProp.BLsizeCutoff + 1; % first element is BLsize=0
    SB_cutoffBin = FigProp.SBsizeCutoff + 1; % first element is SBsize=0
end
% Compact matrix to summarize frequencies of all clone sizes equal or above threshold under the cutoff element:
cloneFreq2D.compact = cloneFreq2D.bin;
BinCol = sum(cloneFreq2D.compact(:,BL_cutoffBin:end),2);
cloneFreq2D.compact = [cloneFreq2D.compact(:,1:BL_cutoffBin-1) BinCol];
BinRaw = sum(cloneFreq2D.compact(SB_cutoffBin:end,:),1);
cloneFreq2D.compact = [cloneFreq2D.compact(1:SB_cutoffBin-1,:); BinRaw];
% Update clone size elements of BL-size-per-bin and SB-size-per-bin to map rows and columns of cloneFreq2D.compact:
sizes_BL.compact = sizes_BL.bin(1,1:BL_cutoffBin);
sizes_SB.compact = sizes_SB.bin(1,1:SB_cutoffBin);
try
    omittedsizes_BL = sizes_BL.bin(1,BL_cutoffBin+1:end);
    sizes_BL.compact{1,end} = [sizes_BL.compact{1,end} [omittedsizes_BL{:}]];
end
try
    omittedsizes_SB = sizes_SB.bin(1,SB_cutoffBin+1:end);
    sizes_SB.compact{1,end} = [sizes_SB.compact{1,end} [omittedsizes_SB{:}]];
end

%% Plotting:
% Plot 2D histogram:
hold on
imagesc(cloneFreq2D.compact,[0 FigProp.TopFreq])

% Plot geometrical median:
if FigProp.DoBinning
    line( ceil([geomed(1,1)+FigProp.BLbinSize geomed(1,1)+FigProp.BLbinSize]./FigProp.BLbinSize) ,[0 SB_cutoffBin+1],'LineStyle',':','Color','k');
    line([0 BL_cutoffBin+1], ceil([geomed(1,2)+FigProp.SBbinSize geomed(1,2)+FigProp.SBbinSize]./FigProp.SBbinSize) ,'LineStyle',':','Color','k');
    plot( ceil((geomed(1,1)+FigProp.BLbinSize)./FigProp.BLbinSize), ceil((geomed(1,2)+FigProp.SBbinSize)./FigProp.SBbinSize) ,'.k');
else
    line([geomed(1,1)+1 geomed(1,1)+1],[0 FigProp.SBsizeSpan+1],'LineStyle',':','Color','k');
    line([0 FigProp.BLsizeSpan+1],[geomed(1,2)+1 geomed(1,2)+1],'LineStyle',':','Color','k');
    plot(geomed(1,1)+1,geomed(1,2)+1,'.k');
end

% Axis ticks:
if FigProp.DoBinning
    ScaledAxis.YTick = ceil((FigProp.YTick+FigProp.SBbinSize)./FigProp.SBbinSize);
    ScaledAxis.XTick = ceil((FigProp.XTick+FigProp.BLbinSize)./FigProp.BLbinSize);
else
    ScaledAxis.YTick = FigProp.YTick+1;
    ScaledAxis.XTick = FigProp.XTick+1;
end
set(gca,'YTick',ScaledAxis.YTick);
set(gca,'XTick',ScaledAxis.XTick);

% Axis labels:
ScaledAxis.YTickLabel = string(FigProp.YTick);
ScaledAxis.XTickLabel = string(FigProp.XTick);
if FigProp.YTick(end) == FigProp.SBsizeCutoff
    ScaledAxis.YTickLabel{end} = ['\geq',ScaledAxis.YTickLabel{end}];
end
if FigProp.XTick(end) == FigProp.BLsizeCutoff
    ScaledAxis.XTickLabel{end} = ['\geq',ScaledAxis.XTickLabel{end}];
end
set(gca,'YTickLabel',ScaledAxis.YTickLabel);
set(gca,'XTickLabel',ScaledAxis.XTickLabel);

% Axis properties:
xlim([0.5 BL_cutoffBin+0.5]);  ylim([0.5 SB_cutoffBin+0.5]);
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
