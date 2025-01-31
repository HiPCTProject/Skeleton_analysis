rootIDs=201;
edge_nodes_temp=edge_network.EdgeConnectivity_EDGE{:};  % duplicate the edges (this will reduce in number beach iteration)
root_node_ind=find(edge_nodes_temp(:,1)==rootIDs);  % this is the row index in edge-nodes where the root node ID is placed.

%okay first correct the root node segment
new_row=[edge_nodes_temp(root_node_ind,2),edge_nodes_temp(root_node_ind,1)]
edge_nodes_temp(root_node_ind,:)=new_row;

[edge_nodes_new,bad_edge_indices] =Find_bad_edges(edge_nodes_temp,rootIDs);
 s=edge_nodes_new(:,1);
 t=edge_nodes_new(:,2);
 G=digraph(s+1,t+1);
 G.Nodes.Isterminal = G.outdegree == 0;
 figure
 plot(G, 'NodeCdata', G.Nodes.Isterminal+1,'Layout','layered');
 rootIDs_new= find(G.outdegree==0)-1;

%%
%Strahler=1;
bad_edge_indices=[NaN];
%StrahlerOrder=zeros(length(edge_nodes_temp),1);

%the only node that should appear once only in column 2 is the root node,
%everything else is a bad edge. 

while(size(edge_nodes_temp,1)>1)
    vert_ids = unique(edge_nodes_temp);  
    counts = histc(edge_nodes_temp(:),vert_ids); %this is the co-ordination number
    idx = find(counts == 1); %Get those with only 1 end.
    [~,loc]=ismember(edge_nodes_temp(:,2),vert_ids(idx)); %these are the rows that are identified as being the wrong way around
    loc=nonzeros(loc)
    for i=1:length(loc)
        if edge_nodes_temp(loc(i),2)==rootIDs
            fprintf('this is the root node skipping \n')
        else
            new_row=[edge_nodes_temp(loc(i),2),edge_nodes_temp(loc(i),1)];
            fprintf("changing row ")
            disp(edge_nodes_temp(loc(i),:))
            fprintf("to read ")
            disp(new_row)
            edge_nodes_temp(loc(i),:)=new_row;
        end
    end



     s=edge_nodes_temp(:,1);
     t=edge_nodes_temp(:,2);
     G=digraph(s+1,t+1);
     G.Nodes.Isterminal = G.outdegree == 0;
     figure
     plot(G, 'NodeCdata', G.Nodes.Isterminal+1,'Layout','layered');
     rootIDs= find(G.outdegree==0)-1;