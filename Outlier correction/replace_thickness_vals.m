function ccpoints=replace_thickness_vals(replacements,ccpoints)
for i=1:length(replacements)            
    idx_replace=find(ccpoints.PointID==replacements(i,1));
    fprintf('replacing %f with %f\n', ccpoints.thickness(idx_replace), replacements(i,2))
    ccpoints.thickness(idx_replace)=replacements(i,2);
end


end