function [child1,child2,child3]=find_children(node,edge_nodes)
    ind=find(edge_nodes(:,2)==node);
    disp(node)   
    disp (ind)
   % if length(ind)==1
    %    fprintf('%d edge seem to have connections the wrong way around, finding the other ways and select the correct one',node)
     %   ind=vertcat(ind,find(edge_nodes(:,1)==node));
    %end
    
    [children]=edge_nodes(ind,1);
    child1=children(1);
    child2=children(2);
    if length(children)==3
     child3=children(3);
    else 
        child3=NaN;
    end
   
end