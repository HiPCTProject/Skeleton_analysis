function [edge_network,vert_network,point_network,edge, point,vertex]=ultimate_amira_read(filepath_ascii) %% reads data when Strahler has already been calculated previously

disp('Reading in data1');
%open file

[fileID msg] = fopen(filepath_ascii, 'r');

features=cell({NaN;NaN;NaN;NaN;NaN}); % a vector to store what all the variables are and how long they are etc.
%read in contents
while true
    thisline = fgets(fileID);
    if contains(thisline,'define VERTEX'); break; end;
        disp(thisline)
end
    

vertex= str2double(regexp(thisline,'\d*','Match'));
edge = fscanf(fileID, '%*s %*s %u\n', [1, 1]);
point = fscanf(fileID, '%*s %*s %u\n', [1, 1] );

while true
    thisline=fgets(fileID);
    if contains(thisline, 'VERTEX { float[3] VertexCoordinates } @1'); break; end;
    %disp(thisline)
end


%% return the parts of each line in a variable
variables=split(thisline, ' ');
features{1,end+1}=regexp(variables{6},'@\d','Match');
expression = {'\w*VERTEX';...
              '\w*EDGE';...
              '\w*POINT'};
type=regexp(variables{1},expression,'match');
VEP=find(~cellfun(@isempty,type));
features{5,end}=strcat(variables{4},'_',type{VEP});
clear type expression
features{2,end}=VEP;


expression={'\w*float';...
              '\w*int'};
type=regexp(variables{3},expression,'match');
float_int=find(~cellfun(@isempty,type));
features{3,end}=type{float_int};
clear type expression float_in

strng=regexp(variables{3}, '\d','Match');
if isempty(strng{1})
    features{4,end}=1;
else
   features{4,end}= str2num(strng{1});
   clear strng 
end



%% Do this for all the other variables untill you reach the data_section.

while true
    thisline = fgets(fileID);
    
     if length(thisline)==1
         thisline=fgets(fileID); % skip empty lines
     end
     
     if contains(thisline,'# Data section follows') 
         break;  
     end
      
    variables=split(thisline, ' ');

features{1,end+1}=regexp(variables{6},'@\d','Match');
expression = {'\w*VERTEX';...
              '\w*EDGE';...
              '\w*POINT'};
type=regexp(variables{1},expression,'match');
VEP=find(~cellfun(@isempty,type));
features{5,end}=strcat(variables{4},'_',type{VEP});
clear type expression
features{2,end}=VEP;


expression={'\w*float';...
              '\w*int'};

type=regexp(variables{3},expression,'match');
float_int=find(~cellfun(@isempty,type));
features{3,end}=type{float_int};
clear type expression float_in

strng=regexp(variables{3}, '\d','Match');
if isempty(strng)
    features{4,end}=1;
else
   features{4,end}= str2num(strng{1});
   clear strng 
end 
        
end

clear variables VEP
features(:,1)=[];



%read each one in as a vector, at the end make a table and rename the variables


for i=1:length(features) 
        thisline=fgets(fileID);
        disp(thisline) 
        assert(contains(thisline,features{1,i}))
        if  contains(thisline,features{1,i})
            fprintf('skipping first line '); 
            disp(thisline);
           % thisline= fgets(fileID)%skips @ line
            %disp(thisline)
        end
        
        if features{2,i}==1
             var{i}=features{5,i}{1,1};
             %[log,idx]=ismember(var,network_verts.Properties.VariableNames);
           
            dict=make_dict([features{:,i}]);
            % network_verts(idx) = 
            vert_vec{i}= [(fscanf(fileID,dict, [features{4,i} vertex]))]';
            fprintf('feature is a vertex of size %d %d \n',features{4,i},vertex)
        
        elseif features{2,i}==2
             var{i}=features{5,i}{1,1};
           
            % [log,idx]=ismember(var,network_verts.Properties.VariableNames)
           
             dict=make_dict([features{:,i}]);
             edge_vec{i} = (fscanf(fileID,dict, [features{4,i} edge]))';
             fprintf('feature is an edge of size %d %d \n',features{4,i},edge)

       elseif features{2,i}==3
             var{i}=features{5,i}{1,1};
           
            % [log,idx]=ismember(var,network_verts.Properties.VariableNames)
           
             dict=make_dict([features{:,i}]);
             point_vec{i} = (fscanf(fileID,dict, [features{4,i} point]))';
             fprintf('feature is an edge of size %d %d \n',features{4,i},point)

        else 
            disp('SOMETHING IS VERY WRONG!!!!')
        end
        clear dict
end
fclose(fileID);

 vert_vec=vert_vec(~cellfun('isempty',vert_vec));
 edge_vec=edge_vec(~cellfun('isempty',edge_vec));
 point_vec=point_vec(~cellfun('isempty',point_vec));


  edge_network = cell2table(edge_vec,...
       'VariableNames', [features{5,(contains([features{5,:}],'EDGE'))}])
 vert_network = cell2table(vert_vec,...
    'VariableNames', [features{5,(contains([features{5,:}],'VERTEX'))}])
 point_network = cell2table(point_vec,...
    'VariableNames', [features{5,(contains([features{5,:}],'POINT'))}])

end
