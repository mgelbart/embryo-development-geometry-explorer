# Introduction #
There are many settings in the EDGE importer than are important when processing the data. The following is a comprehensive list of all the settings and their meaning.

# Image Processing parameters #

### Bandpass filter thresholds ###

The first step in the image processing is a bandpass filter. The `low` and `high` parameters are the wavelength cutoffs for this filter. Intuitively, try adjusting these thresholds so that the length scales of interest (e.g., the diameter of a typical cell) falls within the low-high range. Default: `low`=1 micron, `high`=10 micron.

### Number of erosions ###

In some cases it is helpful to remove junk near the boundaries of the images. Each erosion removes one layer of pixels from the outside of the image and then cleans up dangling edges. Default: 0.

### Minimum cell size ###

Cells below the minimum cell size are removed during the processing. The removal process involves, approximately, merging them with nearby cells. For this reason, it is possible that cells nearby a removed small cell will have its shape affected slightly. It is recommended not to set this quantity to zero because if a large number of tiny artifact cells are created the program may slow down significantly. Default: 5 microns squared.

### Preprocessing threshold ###

The image processing works by filtering and then thresholding the raw image. The proprocessing threshold allows the user to adjust the value of this threshold from the default value we have chosen. The units are in standard deviations of the pixel intensities. Default: 0.

### Minimum edge length ###

During the conversion of the processed image to polygons, vertices closer together than the minimum edge length are merged to become one vertex. The results is that the edges of cells are all larger than this minimum. This value is also affects automatic error correction (split edge): if a split will result in edges smaller than this minimum, then it is not performed. Default: 1 micron.

### Minimum angle ###
This quantity is used only during automatic edge splitting. If the splitting of an edge causes the two original vertices plus the new vertex to form an angle below this minimum, then the splitting is not performed. The rationale is that very sharp angles are not biologically realistic and that such a case is probably due to an error. Default: 90 degrees.

### Maximum angle ###
This quantity is used only during automatic edge splitting. If the splitting of an edge causes the two original vertices plus the new vertex to form an angle above this maximum, then the splitting is not performed. The rationale is that if adding the extra vertex will make almost no difference to the shape of the cell, then it need not be added. Default: 170 degrees.

# Tracking parameters #

For all three tracking parameters, the spatial and temporal parameters can be adjusted separately.

### Min fractional overlap ###
The tracking algorithm works by matching cells that have significant overlap between two images. This parameter specifies the minimum amount cells needs to overlap to be considered a match. The overlap is computed by the area of intersection divided by the larger of the two cell areas. Default: 0.4

### Layers to look back ###
When the tracking algorithm fails to find a match for a cell, it can optionally "look back" to the previous image to find a match. The idea is that if a particular image is corrupted, the tracking may want to skip this image and make a match with cells in the image before it. Setting this number to 1 means that no images will be skipped. Default: 4

### Max centroid distance ###
The tracking algorithm requires the centroids of two cells to be within some cutoff distance in order for the cells to be matched. This parameter specifies this distance and is measured in microns. Default: 10 microns.

# Further information #
For more details on how these parameters are used, see the [Supporting Information](http://people.seas.harvard.edu/~mgelbart/publications/Gelbart2012_SI.pdf) section of our [publication on EDGE](http://people.seas.harvard.edu/~mgelbart/publications/Gelbart2012.pdf).