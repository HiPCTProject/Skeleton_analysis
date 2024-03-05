function [parent_rad,sumchild] =murrays_law(filepath_ascii)

[edge_network,vert_network,point_network,edge, point,vertex]=ultimate_amira_read(filepath_ascii);

%% Check and fix edges
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
         [new_edge_nodes,bad_edge_indices] =Find_bad_edges(cell2mat(edge_network.EdgeConnectivity_EDGE),rootIDs);
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


% source/child 1 target/parent 2
branching_nodes=edges(idx);
for i=1:length(branching_nodes)
node=branching_nodes(i);
ind=find(network.edge_nodes(:,2)==node);
ind2=find(network.edge_nodes(:,1)==node);

parent_rad(i)=edge_network.MeanRadius_EDGE{1}(ind2)^3;
%children rads

children=edge_network.MeanRadius_EDGE{1}(ind);
sumchild(i)=sum(children.^3);
clear children ind ind2
end
[parent_rad,sumchild];
end