function edge_ind=return_edge_ind(node_source,node_target,edge_nodes)
options1=find(edge_nodes(:,1)==node_source);
options2=find(edge_nodes(:,2)==node_target);
edge_ind=options1(ismember(options1, options2));
end