
path = File.openDialog("Select a File");
//open(path); // open the file
dir = File.getParent(path);
name = File.getName(path);
print("Path:", path);
print("Name:", name);
print("Directory:", dir);
list = getFileList(dir);
print(dir+"/"+name)
  
  

open(dir+"/"+name)
nameend=indexOf(getTitle(), ".")
output_name=substring(getTitle(),0,indexOf(getTitle(),"."))
print(output_name)
//run("Size...", "width=501 height=501 depth=318 constrain average interpolation=Bilinear");
setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(1, 255);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
//saveAs("Tiff",dir+"/"+output_name+"_resized.tif");
run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
run("Analyze Regions 3D", "voxel_count euler_number surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
saveAs("Results",dir+"/"+output_name+"_morpho.csv");
run("Close All");


