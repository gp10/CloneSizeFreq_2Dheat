function geomedian = geomedian_calculation(mydata)
%% Geometrical median calculation for a sample of two-component data points
% Takes a mx2 matrix of m 2-coordinate objects as input and calculates the
% geometrical median of their distribution from the pairwise Euclidean
% distances between any pair of data.

%% Input:
% mydata: matrix of size [m,2] containing m different elements with two
%       components (e.g. basal clone size and suprbasal clone size).

%% Output:
% geomedian: vector of length=2 with the two-component value of the
%       geometrical median, i.e. median of first and second component of elements
%       in mydata.

%% Example:
% mydata = [1 1; 2.1 1; 2.3 1; 3.0 1; 3.3 1; 3.4 1; 3.4 1; 5 1; 9.1 1];
% geomedian = geomedian_calculation(mydata);

%% Calculate matrix of pairwise distances between any two (x,y)-elements in mydata:
D = squareform(pdist(mydata,'euclidean'));

%% Calculate geometrical median:
geomedian = mydata(find(sum(abs(D),1)==min(sum(abs(D),1)),1),:);
