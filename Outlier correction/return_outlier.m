function [outlierID,replace_value]=return_outlier(segment,ccpoints)


           %thickness(j)=ccpoints.thickness(find(ccpoints.PointID==segment));
           %ID(j)=cc1points.PointID(find(ccpoints.PointID==segment(j)));
             [~,idx1] = intersect(ccpoints.PointID,segment);
             [~,idx2] = sort(segment);
             idx=idx1(idx2);
             thickness=ccpoints.thickness(idx);
             ID=ccpoints.PointID(idx);

           outliers=thickness(isoutlier(thickness,"percentiles",[5 100]));
           outlierID=ID(isoutlier(thickness,"percentiles",[5 100]));
           filled_thickness=filloutliers(thickness,"nearest","percentiles",[5 100]);

           replace_value=filled_thickness(thickness~=filled_thickness);
  end