%%
function [results]=meta_metric(bb_coords)
clear all
%binary=readtable("F:\Dropbox (UCL)\Dropbox (UCL)\Hannah_Claire_vessel_comps\HREM\Medulla_network\Consensus_optimisation\binary_image_metrics.csv")
%binary_bb_points=read_amira_simple("F:\Dropbox (UCL)\Dropbox (UCL)\Hannah_Claire_vessel_comps\HREM\Medulla_network\Consensus_optimisation\Binary_image_birfircations\SpatialGraph1.am")
filepath_binary="F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\Skeleton_optimisation\binary_bifircation2CL.am";
%binary.Volume=binary.Volume*(50*50*50);
%filenames_csv=dir("F:\Dropbox (UCL)\Dropbox (UCL)\Hannah_Claire_vessel_comps\HREM\Medulla_network\Consensus_optimisation\CL_optimisation\CL_Statistics//*.csv")
filenames_ascii=dir("F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\Skeleton_manual_correction_smoothing\Manual_correction_and_smoothing\After_smoothing_corrections\cc1_multiscale_smoothed-copy.attributegraph.am");
%cl_dice=readtable("F:\Dropbox (UCL)\Dropbox (UCL)\Hannah_Claire_vessel_comps\HREM\Medulla_network\Consensus_optimisation\CL_optimisation\CL_lines\cl_sensitivity_result_CL.xlsx")
%cl_dice.Cl_sense=cellfun(@str2num,cl_dice.Cl_sense);

[edge_network2,vert_network2,point_network2,edge2, point2,vertex2]=ultimate_amira_read(filepath_binary)
edge_nodes_bin=edge_network2.EdgeConnectivity_EDGE{:};
counts_binary = histc(edge_nodes_bin(:),unique(edge_nodes_bin)); %this is the co-ordination number for each node
bifircation_binary=vert_network2.VertexCoordinates_VERTEX{:}(counts_binary>2,:);

for i=1:length(filenames_ascii)
%filename_csv=fullfile(filenames_csv(i).folder,filenames_csv(i).name)
filename_ascii=fullfile(filenames_ascii(i).folder,filenames_ascii(i).name)
%[point_thickness,point_coords,edge_numPoints,edge_nodes,vertex_coords,heading_graph_stats,summary,heading_summary,graph_stats,headings_segments,segment_stats,headings_node_stats,node_stats]= read_stats_csv(filename_csv,filename_ascii);
[edge_network,vert_network,point_network,edge, point,vertex]=ultimate_amira_read(filename_ascii)
%volume(i)=double(summary{5})
%conncom(i)=double(summary{1})
%[vol_max_cc(i) ind]=max(graph_stats{:,5})
%Euler(i)=double(graph_stats{7}(ind)-graph_stats{2}(ind));
%name_stat{i} = filenames_csv(i).name; 
%name_ascii{i} = filenames_ascii(i).name; 

% input bbcoords take this from AMIRA file (in this case they are 107.16
% 107.16,118.68) [xmin,xmax,ymin,ymax,zmin,zmax]
vertex_coords=vert_network.VertexCoordinates_VERTEX{:};
edge_nodes=edge_network.EdgeConnectivity_EDGE{:};
bb_coords=[194,194+150,740,740+150,681,681+150];
bb_coords=bb_coords.*50;

isInBox = @(M,B) (M(:,1)>=B(1)).*(M(:,1)<=B(2)).*(M(:,2)>=B(3)).*(M(:,2)<=B(4).*(M(:,3)>=B(5)).*(M(:,3)<=B(6)));
verts_in_box=isInBox(vertex_coords,bb_coords);
ind_in_bb=find(verts_in_box);

edges = unique(edge_nodes); % Starting edges
counts_orig = histc(edge_nodes(:),edges); %this is the co-ordination number for each node

if length(counts_orig<length(vertex_coords)) %% needed to handle isolated nodes
    node_IDs=ind_in_bb-1;
    ind_branching_nodes=find(counts_orig(ismember(edges,node_IDs))>2);    
else     
ind_branching_nodes=find(counts_orig(ind_in_bb)>2);
end
verts_coord_bb=vertex_coords(ind_in_bb(ind_branching_nodes),:);

bifircation_binary_temp=bifircation_binary;

for j=1:length(verts_coord_bb)
[IND_TP dist_TP]=knnsearch(bifircation_binary_temp,verts_coord_bb(j,:),Distance='euclidean');
if dist_TP<900;
    TP(j)=IND_TP;
    bifircation_binary_temp(IND_TP,:)=NaN;
else
    TP(j)=NaN;
end
end
disp(sum(TP>0))
FN=length(bifircation_binary)-sum(TP>0);
disp(FN)
FP=(length(verts_coord_bb)-sum(TP>0));
disp(FP)

dice_bb(i)=(2*sum(TP>0))/((2*sum(TP>0))+FP+FN)


BB(i)=double(length(ind_branching_nodes))

%Metric(i)=sqrt(((binary.Volume-volume(i))/(binary.Volume))^2 +...
  %        ((binary.CC-conncom(i))/(binary.CC))^2 +...
   %       ((binary.Euler-Euler(i))/(binary.Euler))^2 +...
    %      ((binary.BB-BB(i))/(binary.BB))^2+...
     %     ((binary.CL-cl_dice.Cl_sense(i))/(binary.CL))^2);
clear ind_in_bb verts_in_box edges ind_branching_nodes TP FN FP bifircation_binary_temp IND_TP verts_coord_bb vertex_coords edge_nodes edges counts_orig
end
results=table(name_stat,volume,conncom,Euler,name_ascii,BB,Metric);
writetable(results,fullfile(filenames_csv(i).folder,'result'),"FileType",'spreadsheet')




