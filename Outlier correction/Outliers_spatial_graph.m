
%this script reads in the attributes graph for the subgraphs of the
%LADAF20217-17 kideny, first it identifies the large outliers, these are
%fully collapsed vessels, it does this by looking for outlier in the
%strahler ordering verses mean radius. It writes these to a table so they
%can be manually verified lookng at the spatial graph. Also after this it
%looks at the smaller collapsed vessels (looking along the thickenss for
%each segment, it identifies the segments with very small thickeness and
%excludes these from calculation in the mean radius of the vessel, it then
%replaces their thickness value with the mean value for the vessel and
%writes a vector for the amira file with the corrected values thickeness values only. 

%datapath='F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\Skeleton_manual_correction_smoothing\Manual_correction_and_smoothing\After_smoothing_corrections'


%datapath='/Users/clairewalsh/Dropbox (UCL)/HiP-CT_Claire_analysis/LADAF-2021-17/Topology_paper/metrics_for_graphs'
datapath='F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\metrics_for_graphs';

cc1=readtable(fullfile(datapath,"50um-LADAF-2021-17_labels_finalised_2_connected_component1_segments.attributegraph.csv"));
cc4=readtable(fullfile(datapath,"50um-LADAF-2021-17_labels_finalised_2_connected_component4_segments.attributegraph.csv"));
cc9=readtable(fullfile(datapath,"50um-LADAF-2021-17_labels_finalised_2connected_component9_segments.attributegraph.csv"));


cc1points=readtable(fullfile(datapath,"50um-LADAF-2021-17_labels_finalised_2_connected_component1.attributegraph_points.csv"));
cc4points=readtable(fullfile(datapath,"50um-LADAF-2021-17_labels_finalised_2_connected_component4_points.attributegraph.csv"));
cc9points=readtable(fullfile(datapath,"50um-LADAF-2021-17_labels_finalised_2_connected_component9.attributegraph_points.csv"));

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

%% outliers for whole collapsed segments

genx_outliers = cell2table(cell(0,21), 'VariableNames', all_network.Properties.VariableNames);

%genx=all_network(find(all_network.strahler==9),:);
genx=all_network(find(all_network.strahler==9 |all_network.strahler==8|all_network.strahler==7|all_network.strahler==6 ),:);
genx_outliers=genx;


for i=max(all_network.strahler)-1:-1:5
    genx=all_network(find(all_network.strahler==i),:);
    genx_outliers=vertcat(genx_outliers,genx(isoutlier(genx.MeanRadius,"percentiles",[10 100]),:))
    
end

figure
scatter(all_network.strahler,all_network.MeanRadius)
hold on
scatter(genx_outliers.strahler,genx_outliers.MeanRadius,'red')
hold off


%% Outliers small collapsed segments
counter=0;
for i=1:height(all_network)
    segment=all_network.PointIDs{i};
    cc=all_network.Identified_Graphs(i);
   if cc==1
          [outlierID,replace_value] = return_outlier(segment,cc1points);
   elseif cc==4
             [outlierID,replace_value]=return_outlier(segment,cc4points);
   elseif cc==9
            [outlierID,replace_value]=return_outlier(segment,cc9points);
   else
     break
           
  end
         
%write updated thicknesses
    if length(outlierID)>0;
        counter=counter+1;
        fprintf('outliers found in subgraph %d for segment %d point IDs ',cc,all_network.SegmentID(i));
        fprintf('%d\n',outlierID)
    

       % all_network.MeanRadius(i)=mean(filled_thickness);
        
       % x_out=repelem(1,length(outliers));
        
        %x=repelem(1,length(segment));
       % figure
        %swarmchart(x,thickness);
        %hold on
        %swarmchart(x_out+1,outliers)
        %swarmchart(x-1,filled_thickness)
        %hold off

        if cc==1
            [~,idx]=intersect(cc1points.PointID,outlierID);
            cc1points.thickness(idx)=replace_value;
             
        elseif cc==4
            [~,idx]=intersect(cc4points.PointID,outlierID);
             cc4points.thickness(idx)=replace_value;
              
        elseif cc==9
             [~,idx]=intersect(cc9points.PointID,outlierID);
             cc9points.thickness(idx)=replace_value;
             
        else 
            break

        end
    end

    clear thickness
    clear outliers
    clear outlierID
    clear segment
    clear idx replace_value
    clear filled_thickness
   end



%% Correct the large outliers and write everything.

oblique_slice_vessel(genx_outliers,cc4points,cc1points,cc9points,'F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\Skeletonisation_raw_data\50um-LADAF-2021-17_labels_finalised_2.tif')



%writetable(genx_outliers,'F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\metrics_for_graphs\outliers_all_networks.csv','Delimiter',',')  



%thickness_outliers = cell2table(cell(0,21), 'VariableNames', all_network.Properties.VariableNames);




