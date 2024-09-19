function []=write_to_spatial_graph(filepath_ascii,gens_seg_strahler,gens_seg_topo,point_thickness)
%% Read in data
%Input:fielpath_ascii Vessel network as an Amira spatial graph exported in ascii file format
       %filepath_csv   Result of Amira Spatial graph statistics as csv
       %for some super wierd reason you need to add to the header i.e. the
       %POINT {int strahler} @6 lines before you append to the file or it
       %doesnt read into amira

disp('Reading in data');
%open file

[fileID msg] = fopen(filepath_ascii, 'a+');

fprintf(fileID,'\n');
fprintf(fileID,'\n');
fprintf(fileID,'@5');
fprintf(fileID,'\n');
fprintf(fileID,'%f\n',point_thickness);
fclose(fileID)


[fileID msg] = fopen(filepath_ascii, 'a+');
%fprintf(fileID,'\n');
fprintf(fileID,'\n');
fprintf(fileID,'@6');
fprintf(fileID,'\n');
fprintf(fileID,'%d\n', gens_seg_strahler);
fclose(fileID)


[fileID msg] = fopen(filepath_ascii, 'a+');
%fprintf(fileID,'\n');
fprintf(fileID,'\n');
fprintf(fileID,'@7');
fprintf(fileID,'\n');
fprintf(fileID,'%d\n', gens_seg_topo);
fclose(fileID)
end



