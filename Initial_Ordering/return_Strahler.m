function Order=return_Strahler(node,children,Strahler)
    ind=find(children(:,1)==node);
    Strahler_ind1=find(Strahler(:,1)==children(ind,2));
    Strahler_ind2=find(Strahler(:,1)==children(ind,3));
    Strahler_ind3=find(Strahler(:,1)==children(ind,4));
    fprintf('\n node is %d children are %d %d',node, children(ind,2),children(ind,3))
    if(isnan(children(ind,2))&& isnan(children(ind,3))&& isnan(children(ind,4)))
   % fprintf('\n node is %d end of tree order is 1' , node)
        Order=1;
   
    elseif(Strahler(Strahler_ind1,2)==Strahler(Strahler_ind2,2))&& isnan(children(ind,4))
   % fprintf('\n node is %d,equal strahler taking sum of children',node)
        Order=max(Strahler(Strahler_ind1,2),Strahler(Strahler_ind2,2))+1;
    
    elseif(Strahler(Strahler_ind1,2)~=Strahler(Strahler_ind2,2))&& isnan(children(ind,4))
    %    fprintf('\n node is %d unequal strahler taking max of children', node)
        Order=max(Strahler(Strahler_ind1,2),Strahler(Strahler_ind2,2));

    elseif ((Strahler(Strahler_ind1,2)==Strahler(Strahler_ind2,2))&& (Strahler(Strahler_ind2,2)==Strahler(Strahler_ind3,2)))
             fprintf('\n node is %d  this is an equal trification node strahler taking max of children plus one', node)  
        Order=max([Strahler(Strahler_ind1,2),Strahler(Strahler_ind2,2),Strahler(Strahler_ind3,2)])+1;

    elseif (numel(unique([Strahler(Strahler_ind1,2),Strahler(Strahler_ind2,2),Strahler(Strahler_ind3,2)])) ~= 1)
            fprintf('\n node is %d  this is an unequal trification node strahler taking max of children', node)          
        Order=max([Strahler(Strahler_ind1,2),Strahler(Strahler_ind2,2),Strahler(Strahler_ind3,2)]);
    else
        sprintf('\n there is a case you have not caught for node %d',node)
    end

end
