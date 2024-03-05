%% Code for Strahler Ordering
function [NetworkStrahlerOrder,NetworkTopoGen]=run_ordering(filepath_ascii,filepath_ascii_write)

%% read in the data 
[point_thickness,point_coords,edge_numPoints,network,vertex_coords,identified_graph_verts]=read_data2(filepath_ascii);

%% should run find_bad_edges here and update edge_nodes

     s=network.edge_nodes(:,1);
     t=network.edge_nodes(:,2);
     G=digraph(s+1,t+1);
     G.Nodes.Isterminal = G.outdegree == 0;
     figure
     plot(G, 'NodeCdata', G.Nodes.Isterminal+1,'Layout','layered');
     rootIDs= find(G.outdegree==0)-1;
     
     corrected=0;
     if size(rootIDs,1)>1
         corrected=1;
         prompt='input the correct Root_node ID'

         answer = (inputdlg(prompt))
         answer=str2num(cell2mat(answer))
         if ismember(answer,rootIDs)
             rootIDs=answer;
         end
         [new_edge_nodes,bad_edge_indices] =Find_bad_edges(network.edge_nodes,rootIDs);
         identified_graph_edges=network.identified_graph_edges;
         original_edges=network.edge_nodes;
         clear network
         network=table(new_edge_nodes,identified_graph_edges);   %% put the new nodes into the table network to be used for the rest of the Strahler stuff
         network.Properties.VariableNames= [{'edge_nodes'}    {'identified_graph_edges'}];
     end

     
  %% now do the Strahler and topo ordering       

    for i=1:max(identified_graph_verts)
        fprintf('subgraph it is subgraph %d \n',i)
        clear subgraph
        subgraph=network(network.identified_graph_edges==i,:);
        root_nodeID=rootIDs(ismember(rootIDs,subgraph.edge_nodes(:,2)));
    if length(subgraph.edge_nodes)==2
       NetworkStrahlerOrder{i}=[subgraph.edge_nodes(1),1;subgraph.edge_nodes(2),1]
       NetworkTopoGen{i}=[subgraph.edge_nodes(1),1;subgraph.edge_nodes(2),1]
       EdgeNodesTopo{i}=[subgraph.edge_nodes(1),subgraph.edge_nodes(2),1]
       EdgeNodesStrahler{i}=[subgraph.edge_nodes(1),subgraph.edge_nodes(2),1]
    else
    [NetworkStrahlerOrder{i},EdgeNodesStrahler{i}]=strahler_graph(subgraph,root_nodeID)
    [NetworkTopoGen{i}{i},EdgeNodesTopo{i}]=topological_gen(subgraph,root_nodeID)
    %save('/Users/clairewalsh/Dropbox (UCL)/HiP-CT_Claire_analysis/LADAF-2021-17/Topology_paper/metrics_for_graphs/After_Corrections/Manual_correction_and_smoothing/cc4_multiscale_smoothed_stahler_nodes.mat', NetworkStrahlerOrder)
    %save('/Users/clairewalsh/Dropbox (UCL)/HiP-CT_Claire_analysis/LADAF-2021-17/Topology_paper/metrics_for_graphs/After_Corrections/Manual_correction_and_smoothing/cc4_multiscale_smoothed_topo_nodes.mat', NetworkTopoGen)
    end
    end

    if corrected==1;
    clear network
    network=table(original_edges,identified_graph_edges); % reset this table before writing out incase there were bad edges.
    network.Properties.VariableNames= [{'edge_nodes'}    {'identified_graph_edges'}];
    end

  % network_strahler = cat(1,NetworkStrahlerOrder{:});
    edge_nodes_strahler = cat(1,EdgeNodesStrahler{:});
    %network_topo = cat(1,NetworkTopoGen{:});
    edge_nodes_topo = cat(1,EdgeNodesTopo{:});
    write_back_strahler(edge_nodes_strahler,network.edge_nodes,edge_numPoints,filepath_ascii_write)
    write_back_topo(edge_nodes_topo,network.edge_nodes,edge_numPoints,filepath_ascii_write)

    %% outlier corrections

end


function write_back_strahler(edge_nodes_strahler,edge_nodes,edge_numPoints,filepath_ascii)
for i=1:length(edge_nodes_strahler)
    first_node=find(edge_nodes(:,1)==edge_nodes_strahler(i,1));
    second_node=find(edge_nodes(:,2)==edge_nodes_strahler(i,2));
    index_to_write=second_node(ismember(second_node,first_node));
    edge_nodes(index_to_write,3)=edge_nodes_strahler(i,3);
end

strahler=repelem(edge_nodes(:,3),edge_numPoints);
%prompt='please add the text \n POINT { float strahler } @8 \n just before the Data section in the ascii file and then save, once done enter 1'
prompt='please add the text \n EDGE { int strahler } @8 \n just before the Data section in the ascii file and then save, once done enter 1'
renamed=input(prompt);

if renamed==1
disp('Reading in data');
%open file

[fileID msg] = fopen(filepath_ascii, 'a+');
fprintf(fileID,'\n');
fprintf(fileID,'@8');
fprintf(fileID,'\n');
fprintf(fileID,'%f\n',edge_nodes_strahler(:,3));
%fprintf(fileID,'%f\n',strahler);
fclose(fileID)

else 
    print('if you do not add to the old file this wont work')
end
end
%% write the topo generations back
function write_back_topo(edge_nodes_topo,edge_nodes,edge_numPoints,filepath_ascii)
for i=1:length(edge_nodes_topo)
    first_node=find(edge_nodes(:,1)==edge_nodes_topo(i,1));
    second_node=find(edge_nodes(:,2)==edge_nodes_topo(i,2));
    index_to_write=second_node(ismember(second_node,first_node));
    edge_nodes(index_to_write,3)=edge_nodes_topo(i,3);
end

%topo=repelem(edge_nodes(:,3),edge_numPoints);
prompt='please add the text \n EDGE { int topo } @9 \n just before the Data section in the ascii file and then save, once done enter 1'
renamed=input(prompt);

if renamed==1
disp('Reading in data');
%open file

[fileID msg] = fopen(filepath_ascii, 'a+');
fprintf(fileID,'\n');
fprintf(fileID,'@9');
fprintf(fileID,'\n');
fprintf(fileID,'%f\n',edge_nodes_topo(:,3));
fclose(fileID)

else 
    print('if you do not add to the old file this wont work')
end
end

%%
function[point_thickness,point_coords,edge_numPoints,network,vertex_coords,identified_graph_verts]=read_data(filepath_ascii)
% Read in data
%Input:fielpath_ascii Vessel network as an Amira spatial graph exported in ascii file format
       %filepath_csv   Result of Amira Spatial graph statistics as csv

 
%% Use this for reading identified graph networks
disp('Reading in data');
%open file

[fileID msg] = fopen(filepath_ascii, 'r');

%read in contents
while true
    thisline = fgets(fileID);
    if contains(thisline,'define VERTEX'); break; end;
        disp(thisline)
end
    
%fgets(fileID);%skip header line
%fgets(fileID);%skip next line

%vertex = fscanf(fileID, '%*s %*s %u\n', [1, 1]); %moves to next line after each of thes
vertex= str2double(regexp(thisline,'\d*','Match'));
edge = fscanf(fileID, '%*s %*s %u\n', [1, 1]);
point = fscanf(fileID, '%*s %*s %u\n', [1, 1] );

while true
    thisline = fgets(fileID);
    if contains(thisline,'# Data section follows'); break; end;
        
end

%fgets(fileID);%skips 'data section follows' line 
fgets(fileID)%skips @1 line

vertex_coords = (fscanf(fileID, '%f %f %f\n', [3 vertex]))';

fgets(fileID)%skips @2 line
identified_graph_verts = (fscanf(fileID, '%u %u\n', [1 vertex]))';

fgets(fileID)%skips @3 line
edge_nodes = (fscanf(fileID, '%u %u\n', [2 edge]))';

fgets(fileID)%skips @4 line
edge_numPoints = (fscanf(fileID, '%u\n', [1 edge]))';

fgets(fileID)%skips @5 line
identified_graph_edges = (fscanf(fileID, '%u\n', [1 edge]))';

fgets(fileID)%skips @6 line
point_coords = (fscanf(fileID, '%f %f %f\n', [3 point]))';

fgets(fileID)%skips @7 line

point_thickness = (fscanf(fileID, '%f\n', [1 point]))'; %radius?


fclose(fileID);

network= table(edge_nodes,identified_graph_edges);

% Check
if(sum(edge_numPoints) ~= point)
    disp('Warning: edge_numPoints does not equal the number of points');
end

if(length(edge_numPoints) ~= edge)
    disp('Warning: edge_numPoints does not equal the number of edges');
end

if(length(edge_nodes) ~= edge)
    disp('Warning: edge_nodes does not equal the number of edges');
end

if(length(point_coords) ~= point)
    disp('Warning: point_coords does not equal the number of points');
end

if(length(point_thickness) ~= point)
    disp('Warning: point_thickness does not equal the number of points');
end

if(length(vertex_coords) ~= vertex)
    disp('Warning: vertex_coords does not equal the number of vertex');
end

end
%******************************************************************
%% Use this for reading graph networks where the strahler and topo have already been defined.
function [point_thickness,point_coords,edge_numPoints,network,vertex_coords,identified_graph_verts]=read_data2(filepath_ascii) %% reads data when Strahler has already been calculated previously


disp('Reading in data1');
%open file

[fileID msg] = fopen(filepath_ascii, 'r');

%read in contents
while true
    thisline = fgets(fileID);
    if contains(thisline,'define VERTEX'); break; end;
        disp(thisline)
end
    
%fgets(fileID);%skip header line
%fgets(fileID);%skip next line

%vertex = fscanf(fileID, '%*s %*s %u\n', [1, 1]); %moves to next line after each of thes
vertex= str2double(regexp(thisline,'\d*','Match'));
edge = fscanf(fileID, '%*s %*s %u\n', [1, 1]);
point = fscanf(fileID, '%*s %*s %u\n', [1, 1] );

while true
    thisline = fgets(fileID);
    if contains(thisline,'# Data section follows'); break; end;
        
end

%fgets(fileID);%skips 'data section follows' line 
fgets(fileID)%skips @1 line

vertex_coords = (fscanf(fileID, '%f %f %f\n', [3 vertex]))';

fgets(fileID)%skips @2 line
identified_graph_verts = (fscanf(fileID, '%u \n', [1 vertex]))';

fgets(fileID)%skips @3 line
edge_nodes = (fscanf(fileID, '%u %u\n', [2 edge]))';

fgets(fileID)%skips @4 line
edge_numPoints = (fscanf(fileID, '%u\n', [1 edge]))';

fgets(fileID)%skips @5 line
identified_graph_edges = (fscanf(fileID, '%u\n', [1 edge]))';
fgets(fileID)%skips @6 line

point_coords = (fscanf(fileID, '%f %f %f\n', [3 point]))';

fgets(fileID)%skips @7 line
point_thickness = (fscanf(fileID, '%f\n', [1 point]))'; %radius?

fgets(fileID)%skips @8 line

strahler = (fscanf(fileID, '%f\n', [1 edge]))'; %radius?

fgets(fileID)%skips @9 line

topo = (fscanf(fileID, '%f\n', [1 edge]))'; %radius?






fclose(fileID);

network= table(edge_nodes,identified_graph_edges);

% Check
if(sum(edge_numPoints) ~= point)
    disp('Warning: edge_numPoints does not equal the number of points');
end

if(length(edge_numPoints) ~= edge)
    disp('Warning: edge_numPoints does not equal the number of edges');
end

if(length(edge_nodes) ~= edge)
    disp('Warning: edge_nodes does not equal the number of edges');
end

if(length(point_coords) ~= point)
    disp('Warning: point_coords does not equal the number of points');
end

if(length(point_thickness) ~= point)
    disp('Warning: point_thickness does not equal the number of points');
end

if(length(vertex_coords) ~= vertex)
    disp('Warning: vertex_coords does not equal the number of vertex');
end

end



    





