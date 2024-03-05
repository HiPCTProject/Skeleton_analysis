function vizualisation(subvol,xtest,ytest,ztest,k,point1,point2)



 labeltest=zeros(size(subvol));
    ind1 = sub2ind(size(labeltest), point1(2),point1(1),point1(3));
    ind2 = sub2ind(size(labeltest),point2(2),point2(1),point2(3));
           labeltest(ind1) = true;
           labeltest(ind2) = true;


plane_test=zeros(size(subvol));
for row=1:size(xtest,1)
    for col=1:size(xtest,2)
        if round(ytest(row,col))>1 & round(ytest(row,col))<size(subvol,1)&...
                round(xtest(row,col))>1 & round(xtest(row,col))<size(subvol,2)& ...
                round(ztest(row,col))>1 & round(ztest(row,col))<size(subvol,3) 
            
            plane_test(round(ytest(row,col)),round(xtest(row,col)),round(ztest(row,col)))=true;
        else
            continue
        end
    end
end



doublelabeltest=(labeltest+plane_test);

fig = uifigure(Name=sprintf('plane %d',k));
g = uigridlayout(fig,[1 1],Padding=[0 0 0 0]);
viewer = viewer3d(g);
hVolume = volshow(subvol,OverlayData=doublelabeltest,Parent=viewer);
             hVolume.RenderingStyle = "GradientOpacity";
             hVolume.Alphamap = linspace(0,0.4,256);
             hVolume.OverlayAlphamap = 0.8;
end