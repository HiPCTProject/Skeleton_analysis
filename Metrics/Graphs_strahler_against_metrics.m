% Script to make graphs of all properties against generation
% Could alter this to read in attribute graph
function Graphs_strahler_against_metrics()
clear all
addpath F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\Image_processing_scripts_claire_under_development
%addpath '/Users/clairewalsh/Dropbox (UCL)/HiP-CT_Claire_analysis/Image_processing_scripts_claire_under_development'
datapath='F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\Skeleton_manual_correction_smoothing\Manual_correction_and_smoothing\After_smoothing_corrections'
%datapath='/Users/clairewalsh/Dropbox (UCL)/HiP-CT_Claire_analysis/LADAF-2021-17/Topology_paper/Skeleton_manual_correction_smoothing/Manual_correction_and_smoothing/After_smoothing_corrections'

files=dir(fullfile(datapath,"*Copy.attributegraph.am"));



set(groot,'defaultAxesFontName','Arial')
set(groot,'defaultAxesFontSize',18)
%datapath='/Users/clairewalsh/Dropbox (UCL)/HiP-CT_Claire_analysis/LADAF-2021-17/Topology_paper'
%datapath_wind='F:\Dropbox (UCL)/Dropbox
%(UCL)/HiP-CT_Claire_analysis/LADAF-2021-17/Topology_paper'; 
cc4=readtable(fullfile(datapath,"cc4_multiscale_smoothed--Copy_segments.attributegraph.csv"));
cc1=readtable(fullfile(datapath,"cc1_multiscale_smoothed-copy_segments.attributegraph.csv"));
cc9=readtable(fullfile(datapath,"cc9_multiscale_smoothed---Copy_segments.attributegraph.csv"));

cc4points=readtable(fullfile(datapath,"cc4_multiscale_smoothed--Copy_points.attributegraph.csv"));
cc1points=readtable(fullfile(datapath,"cc1_multiscale_smoothed-copy_points.attributegraph.csv"));
cc9points=readtable(fullfile(datapath,"cc9_multiscale_smoothed---Copy_points.attributegraph.csv"));

cc1.Identified_Graphs(:)=1;
cc4.Identified_Graphs(:)=4;
cc9.Identified_Graphs(:)=9;


cc1points.SubGraphID(:)=1;
cc4points.SubGraphID(:)=4;
cc9points.SubGraphID(:)=9;

all_network=vertcat(cc1,cc4,cc9);

for i=1:length(all_network.SegmentID)
all_network.PointIDs(i)={str2num(cell2mat(all_network.PointIDs(i)))};
end

for i=1:length(files)
filepath_ascii=fullfile(files(i).folder,files(i).name)
[BAedge{i} BAvertex{i}]=branching_angles_with_strahler(filepath_ascii);
end

for i=1:length(files)
filepath_ascii=fullfile(files(i).folder,files(i).name)
[IVD{i}]=intervessel_distance(filepath_ascii);
end

inter_vessel_dist=vertcat(IVD{:});
Branching_Angle=vertcat(BAedge{:});
all_network=addvars(all_network,Branching_Angle );
all_network=addvars(all_network, inter_vessel_dist);
clear Branching_Angle IVD

for i=1:max(all_network.strahler)
tort{i}=all_network.Tortuosity(all_network.strahler==i);
rad{i}=all_network.MeanRadius(all_network.strahler==i);
lDR{i}=all_network.CurvedLength(all_network.strahler==i)./all_network.MeanRadius(all_network.strahler==i);
OrientationTheta{i}=all_network.OrientationTheta(all_network.strahler==i);
OrinetationPhi{i}=all_network.OrientationPhi(all_network.strahler==i);
%Branching_Angle{i}=all_network.Branching_Angle(all_network.strahler==i)
%IVD{i}=all_network.inter_vessel_dist(all_network.strahler==i)
vol{i}=all_network.Volume(all_network.strahler==i)
end


mean_rad=cellfun(@mean, rad);
std_rad=cellfun(@std, rad);
mean_tort=cellfun(@mean, tort);
std_tort=cellfun(@std, tort);
mean_LDR=cellfun(@mean, lDR);
std_lDR=cellfun(@std, lDR);
mean_vol=cellfun(@mean, vol);
std_vol=cellfun(@std, vol);

%% group parameters for kmean analysis and write out (the kmeans is done in python as it is easier)
clusterparams=[all_network.topo,all_network.MeanRadius,...
    all_network.Tortuosity,all_network.Branching_Angle,...
    all_network.CurvedLength./all_network.MeanRadius,all_network.inter_vessel_dist];

clusterparams(isnan(clusterparams(:,4)),4)=0;
csvwrite(fullfile(datapath,'clustering_metrics.csv'),clusterparams);

csvwrite(fullfile(datapath,'strahler_and_topo.csv'),[all_network.strahler,all_network.topo]);


%% plots for each of the parameters
for i=1:max(all_network.strahler)
al_goodplot(IVD{i},i,0.5,[0.62,0.07,0.18]);
end
%ylabel=('Inter-Vessel Distance \mu{m}')
ylabel('Volume \mu{m}^{3}')
xlim([0,10])
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'1','2','3','4','5','6','7','8','9'})
xlabel('Strahler Order')
%ylabel('Length to diameter ratio')
%ylabel('Branching Angle ^{\circ}')
%ylabel('Tortuosity')
%ylabel('Radius \mu{m}')

%% Number of vessels per ordering and branching ratios
% read in from a python script to avoid needing the toolbox for stats in
% matlab graphs for kmeans are made in python script this is just useful
% for histograms
kmeans=readtable(fullfile(datapath,"kmeans_optimal.csv"));
kmeans=kmeans.Var1+1;
kmeans_vessel_no=histc(kmeans,[1:max(kmeans)]);


strahler_vessels_no=histc(all_network.strahler,[1:9]);

topo_vessels_no=histc(all_network.topo,[1:max(all_network.topo)]);

strahler_vessels__cc1=histc(cc1.strahler,[1:9]);
strahler_vessels__cc4=histc(cc4.strahler,[1:9]);
strahler_vessels__cc9=histc(cc9.strahler,[1:9]);

for i =1:length(strahler_vessels_no)-1
branching_ratio(i)=strahler_vessels_no(i)/strahler_vessels_no(i+1);
end

for i =1:length(strahler_vessels_no)-1
branching_ratio_means(i,:)=[strahler_vessels__cc1(i)/strahler_vessels__cc1(i+1),...
    strahler_vessels__cc4(i)/strahler_vessels__cc4(i+1),...
    strahler_vessels__cc9(i)/strahler_vessels__cc9(i+1)];
end
branching_ratio(9)=NaN;

meanbr=nanmean(branching_ratio_means,2);
err=nanstd(branching_ratio_means,0,2);
meanbr(9)=NaN;
err(9)=NaN;

x=[1:9];
x2=[min(all_network.topo):max(all_network.topo)];
x3=[min(kmeans):max(kmeans)];
%% strahler plot
yyaxis left
plot(x,strahler_vessels_no,'sq','LineWidth',1)
%yyaxis right
%plot(x, branching_ratio,'x')
yyaxis right
errorbar(x, meanbr,err,'bo','LineWidth',1)
hold on
plot(x, [repmat(2,9,1)])
%ylim([0,7])
xlim([1,9])
xticks([1 2 3 4 5 6 7 8 9])
xticklabels({'1','2','3','4','5','6','7','8','9'})
xlabel('Strahler Order')
%% topo
plot(x2,topo_vessels_no,'sq','LineWidth',1)
xlim([1,max(all_network.topo)])
xticks([max(all_network.topo)])
xlabel('Topological Generation')

%%kmeans plot
plot(x3,kmeans_vessel_no,'sq','LineWidth',1)
xlim([1,max(kmeans)])
xticks([1:max(kmeans)])
xlabel('kmeans order')




%% Murrays law
files=dir(fullfile(datapath,"*attribute*.am"));

for i=1:length(files)
filepath_ascii=fullfile(files(i).folder,files(i).name);
[Parent_rad{i} sumchild{i}]=murray_law(filepath_ascii);
end

parents=horzcat(Parent_rad{1},Parent_rad{2},Parent_rad{3});
childs=horzcat(sumchild{1},sumchild{2},sumchild{3});
end
