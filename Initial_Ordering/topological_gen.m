function [node_gen,edge_nodes_orig]=topological_gen(subgraph,root_nodeID)

    edge_nodes_orig=subgraph.edge_nodes;
    nodes = unique(edge_nodes_orig); % Starting edges
    counts_orig = histc(edge_nodes_orig(:),nodes);
     s=edge_nodes_orig(:,1);
     t=edge_nodes_orig(:,2);
     G=digraph(s+1,t+1);
     G.Nodes.Isterminal = G.outdegree == 0;
     plot(G, 'NodeCdata', G.Nodes.Isterminal+1)
     all_gens=toposort(G);

     
     edge_nodes_temp=edge_nodes_orig;
     % first generation set from root
     idx=find(all_gens==root_nodeID+1);
     source=find(edge_nodes_temp(:,2)==all_gens(idx)-1);
     target=find(edge_nodes_temp(:,1)==all_gens(idx-1)-1) ;
     edge_row_idx=intersect(source,target); % find the correct row
     edge_nodes_temp(edge_row_idx,:)=[];  % set row to zero in temp
     edge_nodes_orig(edge_row_idx,3)=1; % add generation 1 to original data
     edge_nodes_temp = edge_nodes_temp(~all(edge_nodes_temp == 0, 2),:);   %remove clear rows to make a new reduced graph
     gen=1;
     node_gen=zeros(length(nodes),2);
     node_gen(:,1)=nodes;
     node_gen(find(nodes==root_nodeID),2)=1;
     node_gen(find(nodes==edge_nodes_orig(edge_row_idx,1)),2)=[gen+1];
     i=idx-1;
     gen=gen+1;

% go along each branch till the end adding genration at each branch point
       while i>(idx-length(nodes)+1)
             source=find(edge_nodes_orig(:,2)==all_gens(i)-1); 
             target=find(edge_nodes_orig(:,1)==all_gens(i-1)-1); 
             edge_row_idx=intersect(source,target);
            % fprintf('toposort i and i-1 are nodes %d %d \n', all_gens(i)-1,all_gens(i-1)-1)
             
             
             
             if isempty(edge_row_idx)
              % fprintf('this is a new branch starting with node id %d \n', all_gens(i-1)-1)
                  
                %find the second one in the node_edge_list as a source
                ind=find(edge_nodes_temp(:,1)==all_gens(i-1)-1); 
                source=find(edge_nodes_orig(:,2)==edge_nodes_temp(ind,2));
                target=find(edge_nodes_orig(:,1)==edge_nodes_temp(ind,1));
                edge_row_idx=intersect(source,target);
                %fprintf('prior branch ending was the second entry of the row %d of the original nodes \n', target)
                gen=node_gen(find(node_gen(:,1)==edge_nodes_temp(ind,2)),2);
                %fprintf('generation of prior branch was %d \n', gen)
                edge_nodes_temp(ind,:)=[];
                %fprintf('edge row %d is being assigned generation %d \n',target,gen)
                edge_nodes_orig(edge_row_idx,3)=gen;
                %fprintf('node %d is being asigned generation %d \n',nodes(find(nodes==edge_nodes_orig(edge_row_idx,1))),gen+1)
                node_gen(find(nodes==edge_nodes_orig(edge_row_idx,1)),:)=[nodes(find(nodes==edge_nodes_orig(edge_row_idx,1))),gen+1];
                edge_nodes_temp = edge_nodes_temp(~all(edge_nodes_temp == 0, 2),:);
                i=i-1;
               


             else
              %   fprintf('continuing along branch from id %d \n',all_gens(i-1)-1)
             edge_nodes_orig(edge_row_idx,3)=gen;
            % fprintf('edge row %d is being assigned generation %d \n',target,gen)
             %fprintf('node %d is being asigned generation %d \n',nodes(find(nodes==edge_nodes_orig(edge_row_idx,1))),gen+1)
             node_gen(find(nodes==edge_nodes_orig(edge_row_idx,1)),:)=[nodes(find(nodes==edge_nodes_orig(edge_row_idx,1))),gen+1];
             source=find(edge_nodes_temp(:,2)==all_gens(i)-1) ;
             target=find(edge_nodes_temp(:,1)==all_gens(i-1)-1) ;
             edge_row_idx=intersect(source,target);
             edge_nodes_temp(edge_row_idx,:)=[];
             edge_nodes_temp = edge_nodes_temp(~all(edge_nodes_temp == 0, 2),:);   %remove clear rows to make a new reduced graph
             i=i-1;
             end


             gen=gen+1;
             clear source target edge_row_idx

       end
end