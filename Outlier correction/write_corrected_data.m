%%
function write_corrected_data(filepath_ascii_read,filepath_ascii_write,ccpoints)
% Read in data
%Input:fielpath_ascii Vessel network as an Amira spatial graph exported in ascii file format
       %filepath_csv   Result of Amira Spatial graph statistics as csv

 
%% Use this for reading identified graph networks
disp('Reading in data');
%open file

[fileID msg] = fopen(filepath_ascii_read, 'r');

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

strahler = (fscanf(fileID, '%f\n', [1 vertex]))'; %radius?

fgets(fileID)%skips @9 line

topo = (fscanf(fileID, '%f\n', [1 vertex]))'; %radius?


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




filename_write=filepath_ascii_write;
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
     fprintf(fid, '%.2f %.2f %.2f\n',vertex_coords(i,1),vertex_coords(i,2),vertex_coords(i,3));
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
for i=1:height(ccpoints)
    fprintf(fid, '%f\n', ccpoints.thickness(i));
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








