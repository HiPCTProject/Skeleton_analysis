function [BA_edge,BA_vertex]=branching_angles_with_strahler(filepath_ascii)

[edge_network,vert_network,point_network,edge, point,vertex]=ultimate_amira_read(filepath_ascii)

%% should run find_bad_edges here and update edge_nodes

%% Check and fix edges
s=edge_network.EdgeConnectivity_EDGE{1}(:,1);
     t=edge_network.EdgeConnectivity_EDGE{1}(:,2);
     G=digraph(s+1,t+1);
     G.Nodes.Isterminal = G.outdegree == 0;
     figure
     plot(G, 'NodeCdata', G.Nodes.Isterminal+1,'Layout','layered');
     rootIDs= find(G.outdegree==0)-1;

  %% check and correct the root node if more that one is found - note you need to know all the IDs for all the root nodes for each graph.  
     if exist('edge_network.SubgraphID_EDGE') ~= 1; 
        disp('adding subgraph ID')
        %SubgraphID = num2cell((zeros(1,size(edge_network.EdgeConnectivity_EDGE{:})));
        A=ones(size(edge_network.NumEdgePoints_EDGE{:}));
        B{1}=num2cell(A);
        edge_network.("SubgraphID_EDGE")= B; %zeros(size(edge_network.NumEdgePoints_EDGE{:}))
        % edge_network = addvars(edge_network,transpose(SubgraphID_EDGE));
     end

     corrected=0;
     update_root=0;
     if size(rootIDs,1)>1
         corrected=1;
         prompt='input the correct Root_node ID'

         answer1 = (inputdlg(prompt))
         answer1=str2num(cell2mat(answer1))
         if ismember(answer1,rootIDs)
             rootIDs=answer1;
         else
             question=menu('are you really sure that is the root nodeID, double check it in amira if you say yes now I will re-do the newtork with this root node so if you are wrong it will be sad','Yes','No');             
             if question==1;
               rootIDs=answer1;
               update_root=1;

             end

         end
     
         [new_edge_nodes,bad_edge_indices] =Find_bad_edges(edge_network.EdgeConnectivity_EDGE{:},rootIDs,update_root);
         identified_graph_edges=edge_network.SubgraphID_EDGE{:};
         original_edges=edge_network.EdgeConnectivity_EDGE{:};
         clear network
         network=table(new_edge_nodes,identified_graph_edges);   %% put the new nodes into the table network to be used for the rest of the Strahler stuff
         network.Properties.VariableNames= [{'edge_nodes'}    {'identified_graph_edges'}];
     else
         network=table(edge_network.EdgeConnectivity_EDGE{:},edge_network.SubgraphID_EDGE{:});   %% put the new nodes into the table network to be used for the rest of the Strahler stuff
         network.Properties.VariableNames= [{'edge_nodes'}    {'identified_graph_edges'}];
     end


 %% now the branching angle can be done 

edges = unique(network.edge_nodes);
counts = histc(network.edge_nodes(:), edges); %this is the co-ordination number
idx = find(counts >= 3);  % find the branching point nodes

branching_nodes=edges(idx);
counter_branch=0;
BA_vertex=NaN*zeros(vertex,3);
BA_edge=NaN*zeros(edge,1);

for i=1:length(branching_nodes)
   [child1,child2,child3]=find_children(branching_nodes(i),network.edge_nodes);
   parent_parent=find_parent_vec(branching_nodes(i),network.edge_nodes);
   parent_coords=vert_network.VertexCoordinates_VERTEX{1}(branching_nodes(i)+1,:); %% find the parent node (add 1 to go from ID to index)
   parent_parent_coords=vert_network.VertexCoordinates_VERTEX{1}(parent_parent+1,:);

if isnan(child3)
    child_nodes=[child1, child2];
    child_coords=vert_network.VertexCoordinates_VERTEX{1}(child_nodes+1,:);
    vec1 = parent_coords  - child_coords(1,:);
    vec2 = parent_coords - child_coords(2,:);
    vecparent= parent_coords-parent_parent_coords; 
    BA_vertex(branching_nodes(i)+1,:)=branching_ang(vec1,vec2);
   

    child1_edge_ind=return_edge_ind(child1,branching_nodes(i),network.edge_nodes);
    child2_edge_ind=return_edge_ind(child2,branching_nodes(i),network.edge_nodes);


    BA_edge(child1_edge_ind)=branching_ang(vecparent,vec1);
    BA_edge(child2_edge_ind)=branching_ang(vecparent,vec2);
    

    disp(branching_ang(vecparent,vec1)+branching_ang(vecparent,vec2)+branching_ang(vec1,vec2));

elseif ~isnan(child3)
    child_nodes=[child1, child2, child3];
    child_coords=vert_network.VertexCoordinates_VERTEX{1}(child_nodes+1,:);
 %find vector between parents and children
    vec1 = parent_coords  - child_coords(1,:);
    vec2 = parent_coords - child_coords(2,:);
    vec3 = parent_coords - child_coords(3,:);
    vecparent= parent_coords-parent_parent_coords; 
   
    BA_vertex(branching_nodes(i)+1,:)=[branching_ang(vec1,vec2),branching_ang(vec2,vec3),branching_ang(vec1,vec3)];
    
    child1_edge_ind=return_edge_ind(child1,branching_nodes(i),network.edge_nodes);
    child2_edge_ind=return_edge_ind(child2,branching_nodes(i),network.edge_nodes);
    child3_edge_ind=return_edge_ind(child3,branching_nodes(i),network.edge_nodes);

    BA_edge(child1_edge_ind)=branching_ang(vecparent,vec1);
    BA_edge(child2_edge_ind)=branching_ang(vecparent,vec2);
    BA_edge(child3_edge_ind)=branching_ang(vecparent,vec3);
    
    disp(branching_ang(vecparent,vec1)+branching_ang(vecparent,vec2)+branching_ang(vec1,vec2)+branching_ang(vecparent,vec3))

else
    BA_vertex(counter_branch,:)=[NaN,NaN,NaN];
end

end
end

