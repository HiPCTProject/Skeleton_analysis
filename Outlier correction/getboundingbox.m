%% function that pulls the bounding box co-ords for a single vessel segment in the raw image data (i.e. in voxel space)
function [answer min_x,max_x,min_y,max_y,min_z,max_z,subvol]=getboundingbox(pt1,rad,rad_mult,raw_dat) % pt1 and 2 are the co-ordinates for all the subsegments (the have repeats of each other, rad is the radius in voxels and rad mult is a user parameter that is an int to say how many time the radius the bounding box...
%function [answer,min_x,max_x,min_y,max_y,min_z,max_z,subvol,label]=getboundingbox(pt1,pt2,rad,rad_mult,max_lims,raw_dat)
% the default is 5 but this can be changed with user input. NOTE X and Y
% are inverted due to move between matrix and image co-ords this is
% correct!
    %rad_mult=7;
    %rad=2;
    max_lims=size(raw_dat);

%     Y = [cellfun(@(x) x(1), pt1),cellfun(@(x) x(1), pt2)];
%   
%     X = [cellfun(@(x) x(2), pt1),cellfun(@(x) x(2), pt2)];
%   
%     Z = [cellfun(@(x) x(3), pt1),cellfun(@(x) x(3), pt1)];
      Y = [cellfun(@(x) x(1), pt1)];
%   
      X = [cellfun(@(x) x(2), pt1)];
%   
      Z = [cellfun(@(x) x(3), pt1)];
               
            min_x=min(X)-(rad_mult*rad);
            max_x=max(X)+(rad_mult*rad);

            min_y=min(Y)-(rad_mult*rad);
            max_y=max(Y)+(rad_mult*rad);

            min_z=min(Z)-(rad_mult*rad);
            max_z=max(Z)+(rad_mult*rad);

           if max_x>max_lims(1)
               max_x=max_lims(1);
           end
           if max_y>max_lims(2)
              max_y=max_lims(2);
           end
           if max_z>max_lims(3)
              max_z=max_lims(3);
           end
                 
                 if min_z<0
                     min_z=0
                 end
                  if min_x<0
                     min_x=0
                  end
                   if min_x<0
                     min_x=0
                 end
             
           subvol=raw_dat(min_x:max_x,min_y:max_y,min_z:max_z);      
          % volshow(subvol)
           label=zeros(size(subvol));
           ind = sub2ind(size(label), X-min_x, Y-min_y, Z-min_z);
           label(ind) = true;
           %volshow(label)
           
            
             hVolume = volshow(subvol,OverlayData=label);
             viewer = hVolume.Parent;
             viewer.CameraZoom = 1;
             hVolume.RenderingStyle = "GradientOpacity";
             hVolume.Alphamap = linspace(0,0.4,256);
             hVolume.OverlayAlphamap = 0.8;
           % 
            f = msgbox("Rotate and check the volume click okay once you have checked the size, then enter positive number for larger, negative for smaller, for no change and NaN for does not need correction");
            prompt = 'does the subvol size need to be larger or smaller than currecnt value, enter a multiplier greater than 1 for larger and less than 1 for smaller, if it should not be changed enter 0, write NaN if this does not need to be corrected';
            answer = input(prompt);
end