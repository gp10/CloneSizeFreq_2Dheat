# CloneSizeFreq_2Dheat :: Analysis and visualization of clone size distributions as 2D histograms
Tools to summarize and display large, quantitative lineage-tracing datasets of clone sizes as 2D heatmaps of the frequency of clones with different number of basal and suprabasal cells.
The 2D-heatmap plots obtained with this repository were first applied in:
  > Fernandez-Antoran D, Piedrafita G, Murai K, Ong SH, Herms A, Frezza C, Jones PH (2019) Outcompeting p53-mutant cells in the normal esophagus by redox manipulation. _Cell Stem Cell_ 25(3):329-341.e6. doi: 10.1016/j.stem.2019.06.011.

### Graphical abstract
![GraphicalAbstract](https://github.com/gp10/CloneSizeFreq_2Dheat/blob/master/Graphical_abstract_CloneSizeFreq_2Dheat.png)

### Overview
This code helps to visualize the distribution of clone sizes in certain experimental conditions, do statistical analyses and compare what represented clone size are most changed between different conditions and pinpoint treatment-due trends in proliferative cell behavior.

The starting point is the loading of a dataset with multiple clones, each with a given basal and suprabasal number of cells. This is typically the case of clones from stratified epithelial tissues where proliferative cells remain in deeper-most basal layer and suprabasal layers are represented by differentiating cells, so that a two-compartment distinction is convenient when analyzing clone sizes. **Analysis-CloneSizeDist2D.m** handles this data and calls **freq2D-heatmap.m** to plot basal and suprabasal size distributions as 2D heatmaps, with display specifications set by user. One can retrieve too the **geometrical median** of clone sizes for each dataset. Next, one can compare differences in clone size frequencies between two experimental conditions. **freq2D-compare-heatmap.m** displays a 2D enrichment heatmap and statistical differences between 2D distributions of clone sizes can be analyzed by **kstest-2s-2d**.

### Main scripts
- **Analysis-CloneSizeDist2D.m** : main script to load clone-size datasets, plot 2D histograms (heatmaps) of clone size frequencies in distinct experimental conditions, and analyze their differences, both by visual 2D enrichment heatmap plot and by statistical analysis.

### Dependencies
- freq2D-heatmap.m : function to calculate and plot a 2D-histogram of clone size frequencies in a specific dataset, given the list of number of basal and suprabasal cells per clone. The user can specify if clone sizes are to be binned or trimmed. The function retrieves corresponding clone frequencies of clones of those sizes and the geometrical median value.
- freq2D-compare-heatmap.m : function to calculate and plot a 2D-histogram of differences in clone size frequencies between two datasets, given their specific size frequency matrices. Clone sizes are shown binned or trimmed depending on frequency data format coming as output of freq2D-heatmap.m.
- geomedian-calculation.m : function to calculate the geometrical median of a distribution of clone sizes characterized by a list of number of basal and suprabasal cells per clone. The first and second elements of the geometrical median refer to median number of basal and suprabasal cells per clone, respectively.
- `kstest-2s-2d` folder : contains code used to calculate a 2D version of Kolmogorov-Smirnov test, here applied to compare clone size distributions between two samples. See package specifications and license details inside.
- `Data` folder : contains an example of some clone-size datasets from Fernandez-Antoran et al (2019) in an Excel spreadsheet that is read to test the code above.

### Requirements
Matlab R2016b
