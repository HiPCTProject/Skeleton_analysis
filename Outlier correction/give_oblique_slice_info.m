%function [pt1,pt2, normal,len] =give_oblique_slice_info(ccpoints,segment,res) 
function [pt1] =give_oblique_slice_info(ccpoints,segment,res) 

for j=1:length(segment)%-1
    pt1_idx=find(ccpoints.PointID==segment(j));
  %  pt2_idx=find(ccpoints.PointID==segment(j+1));
    pt1{j}=table2array(ccpoints(pt1_idx,3:5))/res;
   % pt2{j}=table2array(ccpoints(pt2_idx,3:5))/res;
   % len{j}=norm(pt1{j}-pt2{j});
    %normal{j}=(pt1{j}-pt2{j});
end
end