
function [ivd]=intervessel_distance(filepath_ascii)

%[network,vertex_coords,vertex,edge,edge_numPoints,point_coords]=read_data2(filepath_ascii);
[edge_network,vert_network,point_network,edge, point,vertex]=ultimate_amira_read(filepath_ascii);
%% Branches
disp('Gathering branch data');
branches = zeros(edge, max(edge_network.NumEdgePoints_EDGE{1}));
point_no = 1;
for i =1:edge
    for j = 1:edge_network.NumEdgePoints_EDGE{1}(i)
        branches(i,j) = point_no;     
        point_no = point_no + 1;
    end
end

%% Midpoints
disp('Calculating midpoints');

centre_point = zeros(edge,3);%centre point of each vessel

for i = 1:edge
    branch = branches(i, :);
    branch = branch(find(branch));

    total_length = 0;
    
    cumulative_length = zeros(length(branch)-1, 1);
    
    for j = 1:(length(branch)-1)
        point_no_1 = branch(j);
        point_no_2 = branch(j+1);
        
        coord1 = point_network.EdgePointCoordinates_POINT{1}(point_no_1, :);
        coord2 = point_network.EdgePointCoordinates_POINT{1}(point_no_2, :);
        
        segment_length = norm(coord2 - coord1);
        
        
        total_length = total_length + segment_length;
        cumulative_length(j) = total_length;

    end
    
    centre_length = total_length/2;
    
    closest_node = 1;
    diff_main = 100000;
    for j = 1:(length(branch)-1)
        diff = abs(centre_length-cumulative_length(j));
        if diff < diff_main
            diff_main = diff;
            closest_node = j;
        end
    end
    
    centre_point(i, :) = point_network.EdgePointCoordinates_POINT{1}(branches(i,closest_node), :);
end

%% Distances
disp('Finding distances')

ivd = zeros(edge,1);

for i =1:edge
    inter_dist_min = 100000;
    for j = 1:edge
        if i ~=j
            %check for negatives
            inter_dist = abs(norm(centre_point(i,:) - centre_point(j,:)));
            if inter_dist < inter_dist_min
                inter_dist_min = inter_dist;
            end
            
        end
    end
    
    ivd(i,1) = inter_dist_min;
end

%% Analyse data
% disp('Saving data');
% 
% writematrix(ivd,output1);

end


function [network,vertex_coords,vertex,edge,edge_numPoints,point_coords]=read_data2(filepath_ascii) %% reads data when Strahler has already been calculated previously

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
