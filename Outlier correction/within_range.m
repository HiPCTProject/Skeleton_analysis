function final_rad_segments= within_range(final_rad_segments)

data_path='/Users/clairewalsh/Dropbox (UCL)/HiP-CT_Claire_analysis/LADAF-2021-17/Topology_paper'
plane_dat=readtable(fullfile(datapath,"metrics_for_graphs/Copy of Skeleton_manual_correction_from_genx_outliers.csv"));
%import the table of manually checked         
%plane_dat.genx_segment_no=real(plane_dat.genx_segment_no); 


for i=1:height(plane_dat)
    planes{i}=table2array(plane_dat(i,2:width(plane_dat)));
   
end

for i=1:length(planes)    
    if isnan(max(planes{i}(1)))
        final_rad_segments(plane_dat.genx_segment_no(i))= {NaN};
        fprintf('setting segments %d to NaN\n',plane_dat.genx_segment_no(i))
    end
end

for i=1:length(planes) 
    if ~isnan(max(planes{i}(1)))
         planes{i}=planes{i}(~isnan(planes{i}));
         final_rad_sec=final_rad_segments{plane_dat.genx_segment_no(i)};
      for j=1:length(planes{i})
         if mod(planes{i}(j)*100,10)==0
           vals{i}(j)=(final_rad_sec(planes{i}(j)));
         else
            vals{i}(j)=planes{i}(j);
         end
      end
        if length(vals{i})==1
                 vals{i}=[vals{i}, vals{i}+0.05*vals{i},vals{i}-0.05*vals{i}];
        end
    end
end


for i=1:length(planes) 
    if isnan(max(planes{i}(1)))
        fprintf('the segment %d is already set to NaN\n',plane_dat.genx_segment_no(i))
        continue
    end
    final_rad_sec=final_rad_segments{plane_dat.genx_segment_no(i)};
    for k=1:length(final_rad_sec)
        [m mn]=min(abs(vals{i}-final_rad_sec(k)));
        out{i}(k)=vals{i}(mn);
   
    end
    final_rad_segments(plane_dat.genx_segment_no(i))= out(i);
    clear final_rad_sec m mn 
end
end
    
    


%out = interp1(vals,final_rad_sec,'nearest','extrap');
         
        
