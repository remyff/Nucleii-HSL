//Intensity measurmeent on nucleii and cytoplasm regions
//Rémy Flores-Flores - I2MC Inserm UMR1297 Toulouse
//Version 1.0 - 28/04/2025
//Need MorpholibJ

#@ File (style="open") inputFile
#@String(label="Nucleii Channel", choices={"1","2","3","4","5","6","7","8","9"}) ch_NUC
#@String(label="LHS Channel", choices={"1","2","3","4","5","6","7","8","9"}) ch_LHS

//open image with overlay
open(inputFile);
name = getTitle();

//Nuclei segmentation
selectImage(name);
run("Duplicate...", "duplicate channels="+ch_NUC);
run("Enhance Contrast", "saturated=0.35");
setOption("ScaleConversions", true);
run("8-bit");
run("Auto Threshold", "method=Li white");
setBackgroundColor(0, 0, 0);
run("Clear Outside");
run("Convert to Mask");
run("Fill Holes");
run("Options...", "iterations=10 count=1 black do=Nothing");
run("Erode");
run("Remove Overlay");
rename("nucMask");

//Cytoplasm segmentation
selectImage(name);
run("Duplicate...", "duplicate channels="+ch_LHS);
run("Enhance Contrast", "saturated=0.35");
setOption("ScaleConversions", true);
run("8-bit");
//setThreshold(10, 70000, "raw");
run("Auto Threshold", "method=Huang white");
setBackgroundColor(0, 0, 0);
run("Clear Outside");
run("Convert to Mask");
rename("cellMask");
imageCalculator("Subtract", "cellMask","nucMask");

//Semantic image
selectImage("nucMask");
run("Divide...", "value=255");
selectImage("cellMask");
run("Divide...", "value=125");
imageCalculator("Add create", "cellMask","nucMask");
rename("mask");

//HSL intensities measurement
selectImage(name);
run("Duplicate...", "duplicate channels="+ch_LHS);
rename("LHS");
run("Intensity Measurements 2D/3D", "input=LHS labels=mask mean");
means = Table.getColumn("Mean");

//save semanctic segmentation image
selectImage("mask");
setMinAndMax(0, 109);
run("glasbey");
run("RGB Color");
rename(name+" res");
saveAs("Tiff", File.getDirectory(inputFile)+name+" res.tif");

//create result table if needed
rt = "image results";
if(isOpen(rt)){
	selectWindow(rt);
	i = Table.size;
}else{
	Table.create(rt);
	i=0;
}

//add results for this image
Table.set("image",i,name);
Table.set("Mean cyto",i, means[1]);
Table.set("Mean nuclei",i, means[0]);

//close all opened images
run("Close All");