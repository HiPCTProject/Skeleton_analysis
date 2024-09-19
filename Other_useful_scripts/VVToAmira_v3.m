clear
clc 

%% Read VesselVio Output
%Coordinates and Radii
resolution_image=[50,50]; %% resolution in x and z fill in here. (I assume x and y have the same dimensions)
data = readcell('F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\Skeleton_optimisation\vertices.csv');
sizdata = size(data,1);
vcoor1 = data(2:sizdata,1);
rad1 = data(2:sizdata,2);
for i=1:sizdata-1
vcoor(i,1:3) = str2num(vcoor1{i});
rad(i) = rad1{i,1};
end
rad = rad';

%%swap z and x for visualisation in amira
vcoor(:,4)=vcoor(:,1);
vcoor(:,1)=vcoor(:,3);
vcoor(:,3)=vcoor(:,4);
vcoor(:,4)=[];


vcoor(:,1:2)=vcoor(:,1:2).*resolution_image(1);
vcoor(:,3)=vcoor(:,3).*resolution_image(2);
%%
%Connectivity
data = readcell('F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\Skeleton_optimisation\edges.csv');
sizdata = size(data,1);
conn1 = data(2:sizdata,1:2); 
for i=1:sizdata-1
    for j = 1:2
        conn(i,j) = conn1{i,j}+1 ;
    end
end


%% Export as .am file

fid = fopen('F:\Dropbox (UCL)\Dropbox (UCL)\HiP-CT_Claire_analysis\LADAF-2021-17\Topology_paper\Skeleton_optimisation\VesselVio_default_.am','wt');
fprintf(fid, '# AmiraMesh 3D ASCII 2.0\n\n') ;
fprintf(fid, 'define VERTEX %d\n',size(vcoor,1));
fprintf(fid, 'define EDGE %d\n',size(conn,1));
fprintf(fid, 'define POINT %d\n',size(conn,1)*2);
fprintf(fid, 'Parameters {\n');
fprintf(fid, '    ContentType "HxSpatialGraph"\n}\n\n');

fprintf(fid, 'VERTEX { float[3] VertexCoordinates } @1\n');
fprintf(fid, 'EDGE { int[2] EdgeConnectivity } @2\n');
fprintf(fid, 'EDGE { int NumEdgePoints } @3\n');
fprintf(fid, 'POINT { float[3] EdgePointCoordinates } @4\n');
fprintf(fid, 'POINT { float thickness } @5\n\n');

fprintf(fid,'\n@1\n')
for i =1:size(vcoor,1)
     fprintf(fid, '%.2f %.2f %.2f\n',vcoor(i,1),vcoor(i,2),vcoor(i,3));
end

fprintf(fid,'\n@2\n')
for i =1:size(conn,1)
     fprintf(fid, '%d %d\n',conn(i,1)-1,conn(i,2)-1);
end

fprintf(fid,'\n@3\n')
for i =1:size(conn,1)
     fprintf(fid, '%d\n',2);
end

fprintf(fid,'@4\n')
for i =1:size(conn,1)
    fprintf(fid, '%.2f %.2f %.2f\n%.2f %.2f %.2f\n',vcoor(conn(i,1),1),vcoor(conn(i,1),2),vcoor(conn(i,1),3),vcoor(conn(i,2),1),vcoor(conn(i,2),2),vcoor(conn(i,2),3));
end


%radius
fprintf(fid,'@5\n')
for i =1:size(conn,1)
    fprintf(fid,'%.4f\n%.4f\n',rad(conn(i,1)),rad(conn(i,2)));
end

fclose(fid);



