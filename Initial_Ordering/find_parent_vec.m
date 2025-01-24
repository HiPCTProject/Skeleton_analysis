function [parent_parent]=find_parent_vec(node,edge_nodes)
    ind=find(edge_nodes(:,1)==node);
    
    parent_parent=edge_nodes(ind,2);
    %parent_vec=vertex_coords(node+1,:)-vertex_coords(parent+1,:)
   
end