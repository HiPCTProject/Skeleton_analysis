%function add_spatial_graphs(filepath_ascii_1,filepath_ascii_2) %% ascii 2
%should be the smaller of the two graphs. This will read graphs in that
%have a strahler and a topological generation defined.
%% Use this for reading identified graph networks
disp('Reading in data1');
%open file

[fileID msg] = fopen(filepath_ascii_1, 'r');

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

vertex_coords1 = (fscanf(fileID, '%f %f %f\n', [3 vertex]))';

fgets(fileID)%skips @2 line
identified_graph_verts1 = (fscanf(fileID, '%u \n', [1 vertex]))';

fgets(fileID)%skips @3 line
edge_nodes1 = (fscanf(fileID, '%u %u\n', [2 edge]))';

fgets(fileID)%skips @4 line
edge_numPoints1 = (fscanf(fileID, '%u\n', [1 edge]))';

fgets(fileID)%skips @5 line
identified_graph_edges1 = (fscanf(fileID, '%u\n', [1 edge]))';

fgets(fileID)%skips @6 line

strahler1 = (fscanf(fileID, '%f\n', [1 edge]))'; %radius?
fgets(fileID)%skips @7 line

topo1 = (fscanf(fileID, '%f\n', [1 edge]))'; %radius?

fgets(fileID)%skips @8 line

point_coords1 = (fscanf(fileID, '%f %f %f\n', [3 point]))';

fgets(fileID)%skips @9 line
point_thickness1 = (fscanf(fileID, '%f\n', [1 point]))'; %radius?




fclose(fileID);

network1= table(edge_nodes1,identified_graph_edges1);

% Check
if(sum(edge_numPoints1) ~= point)
    disp('Warning: edge_numPoints does not equal the number of points');
end

if(length(edge_numPoints1) ~= edge)
    disp('Warning: edge_numPoints does not equal the number of edges');
end

if(length(edge_nodes1) ~= edge)
    disp('Warning: edge_nodes does not equal the number of edges');
end

if(length(point_coords1) ~= point)
    disp('Warning: point_coords does not equal the number of points');
end

if(length(point_thickness1) ~= point)
    disp('Warning: point_thickness does not equal the number of points');
end

if(length(vertex_coords1) ~= vertex)
    disp('Warning: vertex_coords does not equal the number of vertex');
end

clear point vertex edge

disp('Reading in data2');
%open file

[fileID msg] = fopen(filepath_ascii_2, 'r');

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

vertex_coords2 = (fscanf(fileID, '%f %f %f\n', [3 vertex]))';

fgets(fileID)%skips @2 line
identified_graph_verts2 = (fscanf(fileID, '%u \n', [1 vertex]))';

fgets(fileID)%skips @3 line
edge_nodes2 = (fscanf(fileID, '%u %u\n', [2 edge]))';

fgets(fileID)%skips @4 line
edge_numPoints2 = (fscanf(fileID, '%u\n', [1 edge]))';

fgets(fileID)%skips @5 line
identified_graph_edges2 = (fscanf(fileID, '%u\n', [1 edge]))';

fgets(fileID)%skips @6 line

strahler2 = (fscanf(fileID, '%f\n', [1 edge]))'; %radius?

fgets(fileID)%skips @7 line

topo2 = (fscanf(fileID, '%f\n', [1 edge]))'; %radius?

fgets(fileID)%skips @8 line

point_coords2 = (fscanf(fileID, '%f %f %f\n', [3 point]))';

fgets(fileID)%skips @9 line


point_thickness2 = (fscanf(fileID, '%f\n', [1 point]))'; %radius?

fclose(fileID);

network2= table(edge_nodes2,identified_graph_edges2);

% Check
if(sum(edge_numPoints2) ~= point)
    disp('Warning: edge_numPoints does not equal the number of points');
end

if(length(edge_numPoints2) ~= edge)
    disp('Warning: edge_numPoints does not equal the number of edges');
end

if(length(edge_nodes2) ~= edge)
    disp('Warning: edge_nodes does not equal the number of edges');
end

if(length(point_coords2) ~= point)
    disp('Warning: point_coords does not equal the number of points');
end

if(length(point_thickness2) ~= point)
    disp('Warning: point_thickness does not equal the number of points');
end

if(length(vertex_coords2) ~= vertex)
    disp('Warning: vertex_coords does not equal the number of vertex');
end



%%
s1=network1.edge_nodes1(:,1);
t1=network1.edge_nodes1(:,2);

 G1=digraph(s1+1,t1+1);
 G1.Nodes.Isterminal = G1.outdegree == 0;
 plot(G1, 'NodeCdata', G1.Nodes.Isterminal+1)
 rootIDs1= find(G1.outdegree==0)-1;

s2=network2.edge_nodes2(:,1);
t2=network2.edge_nodes2(:,2);

 G2=digraph(s2+1,t2+1);
 G2.Nodes.Isterminal = G2.outdegree == 0;
 plot(G2, 'NodeCdata', G2.Nodes.Isterminal+1)
 rootIDs2= (find(G2.indegree==0));


[matching,loc]=ismember(vertex_coords2,vertex_coords1,'rows');

replacement_IDs=(loc(loc>0))-1;
IDs_for_replacement=find(matching)-1;
edgeNode2IDs=unique(edge_nodes2);
non_replaced=edgeNode2IDs(~ismember(edgeNode2IDs,IDs_for_replacement));
add_value=length(vertex_coords1)-1;
replacement_IDs_all=vertcat([non_replaced,transpose([length(vertex_coords1):length(vertex_coords1)+length(non_replaced)-1])],[IDs_for_replacement,replacement_IDs]);


vertex_coords=vertex_coords1;
for i=1:length(edge_nodes2)*2
    if ismember(edge_nodes2(i),IDs_for_replacement)
            [x loc]=ismember(edge_nodes2(i),IDs_for_replacement);
            edge_nodes2Copy(i)=replacement_IDs(loc);
            fprintf('node %d in graph 2 is the same as node %d in graph 1\n',edge_nodes2(i),replacement_IDs(loc))
    
    else 
        row=find(replacement_IDs_all(:,1)==edge_nodes2(i));
        edge_nodes2Copy(i)=replacement_IDs_all(row,2);
    fprintf('node %d in graph 2 a new node assigning it ID as %d\n',edge_nodes2(i),replacement_IDs_all(row,2))
    fprintf('coordinates of this node are [%f %f %f]\n', vertex_coords2(edge_nodes2(i)+1,:))
    end

end

vertex_coords=vertcat(vertex_coords,vertex_coords2(non_replaced+1,:));

edge_nodes2Copy=reshape(edge_nodes2Copy,size(edge_nodes2));

% vertex_coords=vertex_coords1;
% for i=1:length(non_replaced)
%     added_coord=vertex_coords2(non_replaced(i)+1,:);
%     vertex_coords=vertcat(vertex_coords,added_coord);
% end
   
edge_nodes=vertcat(edge_nodes1,edge_nodes2Copy);   


s_merge=edge_nodes(:,1);
t_merge=edge_nodes(:,2);
G=digraph(t_merge+1,s_merge+1);
G.Nodes.Isterminal = G.outdegree == 0;
plot(G, 'NodeCdata', G.Nodes.Isterminal+1)

vertex=length(vertex_coords);
edge=length(edge_nodes);

point_coords=point_coords1;

% 
% [B,~,Y] = unique(vertex_coords,'rows','stable');
% [C,X] = hist(Y,unique(Y));
%  Z = ismember(Y,X(C>1)); % indices of repeated rows of A



identified_graph_verts=ones(vertex,1)
edge_numPoints=vertcat(edge_numPoints1,edge_numPoints2);
identified_graph_edges=vertcat(identified_graph_edges1,identified_graph_edges2);
point_coords=vertcat(point_coords1,point_coords2);
point_thickness=vertcat(point_thickness1,point_thickness2);
strahler=vertcat(strahler1,strahler2);
topo=vertcat(topo1,topo2);
point=length(point_thickness);







filename_write="F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\metrics_for_graphs\After_Corrections\Manual_correction_and_smoothing\cc1_multiscale_smoothed.am"
%filename_write=filepath_ascii_write;
fid = fopen(filename_write,'wt');

fprintf(fid, '# AmiraMesh 3D ASCII 2.0\n\n') ;
fprintf(fid, 'define VERTEX %d\n',vertex);
fprintf(fid, 'define EDGE %d\n',edge);
fprintf(fid, 'define POINT %d\n',point);
fprintf(fid, 'Parameters {\n');
fprintf(fid, '    ContentType "HxSpatialGraph"\n}\n\n');



fprintf(fid, 'VERTEX { float[3] VertexCoordinates } @1\n');
fprintf(fid, 'VERTEX { int Identified_Graphs } @2\n');
fprintf(fid, 'EDGE { int[2] EdgeConnectivity } @3\n');
fprintf(fid, 'EDGE { int NumEdgePoints } @4\n');
fprintf(fid, 'EDGE { int Identified_Graphs } @5\n');
fprintf(fid, 'POINT { float[3] EdgePointCoordinates } @6\n');
fprintf(fid, 'POINT { float thickness } @7\n');
fprintf(fid, 'EDGE { int strahler } @8\n');
fprintf(fid, 'EDGE { int topo } @9\n\n');

fprintf(fid, '# Data section follows\n');


fprintf(fid,'\n@1\n')
for i =1:size(vertex_coords,1)
     fprintf(fid, '%f %f %f\n',vertex_coords(i,1),vertex_coords(i,2),vertex_coords(i,3));
end


fprintf(fid,'\n@2\n')
for i=1:size(identified_graph_verts)
    fprintf(fid, '%u\n', identified_graph_verts(i));
end

fprintf(fid,'\n@3\n')
for i=1:size(edge_nodes,1)
    fprintf(fid, '%u %u\n', edge_nodes(i,1),edge_nodes(i,2));
end

fprintf(fid,'\n@4\n')
for i=1:size(edge_numPoints)
    fprintf(fid, '%u\n', edge_numPoints (i));
end

fprintf(fid,'\n@5\n')
for i=1:size(identified_graph_edges,1)
    fprintf(fid, '%u\n', identified_graph_edges(i));
end

fprintf(fid,'\n@6\n')
for i=1:size(point_coords,1)
    fprintf(fid, '%f %f %f\n', point_coords(i,1),point_coords(i,2),point_coords(i,3));
end

fprintf(fid,'\n@7\n')
for i=1:height(point_thickness)
    fprintf(fid, '%f\n', point_thickness(i));
end


fprintf(fid,'\n@8\n')
for i=1:size(strahler)
    fprintf(fid, '%f\n', strahler(i));
end

fprintf(fid,'\n@9\n')
for i=1:size(topo)
    fprintf(fid, '%f\n', topo(i));
end


fclose(fid);






%end


