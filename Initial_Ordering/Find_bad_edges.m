function [edge_nodes,bad_edge_indices] =Find_bad_edges(edge_nodes,rootIDs,update_root)
 % duplicate the edges (this will reduce in number beach iteration)

if update_root==1
    root_node_ind=find(edge_nodes(:,1)==rootIDs);  % this is the row index in edge-nodes where the root node ID is placed.
    new_row=[edge_nodes(root_node_ind,2),edge_nodes(root_node_ind,1)];
    edge_nodes(root_node_ind,:)=new_row;
    edge_nodes_temp=edge_nodes; 
else
    edge_nodes_temp=edge_nodes; 
end

root_node_ind=find(edge_nodes(:,2)==rootIDs);  % this is the row index in edge-nodes where the root node ID is placed.
Strahler=1;
bad_edge_indices=[NaN];
StrahlerOrder=zeros(length(edge_nodes),1);

while(size(edge_nodes_temp,1)>1)
    edges = unique(edge_nodes_temp);  
    counts = histc(edge_nodes_temp(:),edges); %this is the co-ordination number
    idx = find(counts == 1); %Get those with only 1 end.
    
    bad_edges=ismember(edge_nodes_temp(:,2),edges(idx));
    temp_row=edge_nodes_temp(find(bad_edges),:);
   
    if size(temp_row,1)>1
        for i=1:length(temp_row)
        new_bad_edge(i)=find(edge_nodes(:,1)==temp_row(i,1)& edge_nodes(:,2)==temp_row(i,2));
        end
        bad_edge_indices=vertcat(bad_edge_indices, transpose(new_bad_edge));  %% find indices in original data.
    else
        new_bad_edge=find(edge_nodes(:,1)==temp_row(1)& edge_nodes(:,2)==temp_row(2));
        bad_edge_indices=vertcat(bad_edge_indices, new_bad_edge);  %
    end

    good_edges=ismember(edge_nodes_temp(:,1),edges(idx));
    to_remove=vertcat(find(bad_edges),find(good_edges));
    StrahlerOrder(idx)=Strahler;
    edge_nodes_temp(to_remove,:)=[];
   
    edge_nodes_temp(end+1,:)=edge_nodes(root_node_ind,:);
    clear edges counts idx bad_edges good_edges temp_row new_bad_edge ;
    Strahler = Strahler +1;
end
   
bad_edge_indices=bad_edge_indices(bad_edge_indices~=root_node_ind);
bad_edge_indices=bad_edge_indices(~isnan(bad_edge_indices));


for i=1:length(bad_edge_indices)
   original=edge_nodes(bad_edge_indices(i),:);
   edge_nodes(bad_edge_indices(i),:)=[original(2),original(1)];
end

s=edge_nodes(:,1);
t=edge_nodes(:,2);
G=digraph(s+1,t+1);
G.Nodes.Isterminal = G.outdegree == 0;
plot(G, 'NodeCdata', G.Nodes.Isterminal+1,'Layout','layered');
rootIDs= find(G.outdegree==0)-1;
end