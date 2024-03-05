function [Strahler edge_nodes] = strahler_graph(subgraph,root_node_ID)
 %root_node=17;    % set the root node ID
% This block of code just takes the temp edge node, finds all the end
% points, for each endpoint it checks if it is  (a root node-in which case
% skip it, or if it has children it calls the find children function and
% checks their Strahler order, it then either adds one for this node (if children are equal, or takes the max if children are unequal)
%it puts these into the Strahler table and then removes the edges from the
%temp edge table that have just been given an order. (leaves the root node
%alone each time (uses a NaN in the remove edges)


%% test set should return the Straher Order vector: 

edge_nodes=subgraph.edge_nodes;


edges = unique(edge_nodes); % Starting edges
Strahler=zeros(length(edges),2); %initialises strahler table
Strahler(:,1)=edges; %Add node ids to strahler table not necessarily needed but helps to debug
counts_orig = histc(edge_nodes(:),edges); %this is the co-ordination number for each node
%assert(max(counts_orig)==3); % if there are nodes with co-ordination 4 this won't work.
idx = find(counts_orig == 1); %Get nodes those with co-ordination number 1 i.e end nodes.

%figure
 %    s=edge_nodes(:,1)+1;
  %   t=edge_nodes(:,2)+1;
   %  G=digraph(s,t);
    %  plot(G)

children=zeros(length(counts_orig),4);   %create a children look-up table simplifies later ordering.
for n=1:length(counts_orig)
    if counts_orig(n)==1
        children(n,:)=[edges(n),NaN,NaN,NaN];
    elseif counts_orig(n)==3
        [c1 c2 c3]=find_children(edges(n),edge_nodes);  %function to find the children of a node given the parent
        children(n,:)=[edges(n),c1 c2, c3];
    elseif counts_orig(n)==4
     [c1 c2 c3]=find_children(edges(n),edge_nodes);  %function to find the children of a node given the parent
        children(n,:)=[edges(n),c1 c2 c3];
    end
    %clear n
end




edge_nodes_temp=edge_nodes;  % duplicate the edges (this will reduce in number beach iteration)


while(sum(Strahler(:,2)==0)>1)
    edges = unique(edge_nodes_temp);  
    counts = histc(edge_nodes_temp(:),edges); %this is the co-ordination number
    idx = find(counts == 1); %Get those with only 1 end.
    edges(idx);  %% node IDs for the nodes with counts asked for. 
    %fprintf('node IDs left are \n ')
    %disp( edges(idx));
    
    %check if any of these are found in column 1, if they are reverse the
    %edge
    for i=1:length(idx)
        
        if (root_node_ID==edges(idx(i)))
            removed(i)=NaN;   % these are storing the node indexes to remove at the end we put in NaN for root to leave it alone..
           % fprintf('\n %d is a root node, skipping', edges(idx(i)))
             continue
             %% if no children 
            % ind_bad=find(edge_nodes_temp(:,2)==edges(idx(i)));
       % elseif length(ind_bad)~=0   % check of some of the edges are the wrong way around. (this happens in amira sometime not sure why)
            

        else  
            
             StrahlerOrder=return_Strahler(edges(idx(i)),children,Strahler); % function to find the Strahler order if the children and return.
             removed(i)=find(edge_nodes_temp(:,1)==edges(idx(i)));  % find the correct edge index (i.e. the one with the node we have just asigned in the second column of the edges vector), to remove at the end of this iteration
        %fprintf('adding %d to Strahler', StrahlerOrder)
        node_idx=find(Strahler(:,1)==edges(idx(i)));
        edges_indx=find(edge_nodes(:,1)==edges(idx(i)));
        if edges_indx==[]
            edges_indx=find(edge_nodes(:,1)==root_node_ID);
        end
        Strahler(node_idx,2)=StrahlerOrder;   % put into the Strahler table
        edge_nodes(edges_indx,3)=StrahlerOrder;
        
        end   
    end
   % fprintf('\n edge ID inc. root removed are '); disp(removed)  % helps to check
    edges_to_clear=removed(~isnan(removed));  % ignore the root node
    % fprintf('\n edges removed are '); disp(edges_to_clear)  % helps to che
    edge_nodes_temp(edges_to_clear,:)=[];   % clear the esges we have just assigned from the temp table
    clear removed
    edge_nodes_temp = edge_nodes_temp(~all(edge_nodes_temp == 0, 2),:);   %remove clear rows to make a new reduced graph
    
    
end
 
 end