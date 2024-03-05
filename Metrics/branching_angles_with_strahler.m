function [BA_edge,BA_vertex]=branching_angles_with_strahler(filepath_ascii)

[edge_network,vert_network,point_network,edge, point,vertex]=ultimate_amira_read(filepath_ascii)

%% should run find_bad_edges here and update edge_nodes

     s=edge_network.EdgeConnectivity_EDGE{1}(:,1);
     t=edge_network.EdgeConnectivity_EDGE{1}(:,2);
     G=digraph(s+1,t+1);
     G.Nodes.Isterminal = G.outdegree == 0;
     figure
     plot(G, 'NodeCdata', G.Nodes.Isterminal+1,'Layout','layered');
     rootIDs= find(G.outdegree==0)-1;
     
     corrected=0;

     if size(rootIDs,1)>1 % check if there is more than one root node.
         corrected=1;
         prompt='input the correct Root_node ID'

         answer = (inputdlg(prompt))
         answer=str2num(cell2mat(answer))
         if ismember(answer,rootIDs)
             rootIDs=answer;
         end
         [new_edge_nodes,bad_edge_indices] =Find_bad_edges(network.EdgeConnectivity_EDGE,rootIDs);
         %clear network
        network=table(new_edge_nodes);   %% put the new nodes into the table network to be used for the rest of the Strahler stuff
        network.Properties.VariableNames= [{'edge_nodes'} ];
     else
         original_edges=cell2mat(edge_network.EdgeConnectivity_EDGE);
         network=table([original_edges]);
         network.Properties.VariableNames= [{'edge_nodes'} ];
     end

 

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

