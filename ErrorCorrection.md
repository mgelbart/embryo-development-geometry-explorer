# Introduction #
The EDGE error correction tools allow the user to fix errors that were made by the EDGE automatic image segmentation algorithm. There are two types, manual and automatic error correction. In manual correction, the user clicks on cells and vertices and makes changes by hand. In automatic correction, EDGE tries to make these changes automatically by changing cells until they can be tracked to a cell in the reference image. One common strategy is to use these features together by first manually correcting the reference image and then using automatic error correction to propagate this information to the other images. These error correction tools are only available in the Edge Importer.


# Manual error correction #

In all manual error correction, the user must intact with the image by clicking on cells or vertices. It is important to indicate to the program if you are attempting to select a cell or a vertex. To do this, use the “Adjusting...” panel to switch between Cells (shortcut: c) and Vertices (shortcut: v). Note also that the zoom tools (accessed by the magnifying glass icons above the image) are very helpful for manual error correction. When you are finished zooming and ready to start correcting errors, you must deselect the zoom option by clicking again on the same icon (do not click on the arrow icon to deselect).

There different types of manual error correction are listed below:

  * **Splitting edges**. When EDGE processes the raw images, it finds the membranes and then approximates the cells as polygons. In some cases, the cells are not polygons and extra vertices are needed to capture the curvature of the membrane. In this case, the split edge command is useful. First select two connected vertices, and then press “Split edge”. Then, click on the place where you want the new vertex to appear. The edge you selected will then be split into two edges separated by the new vertex.
  * **Adding edges**. To add an edge, select two unconnected vertices and press “Add edge”.
  * **Removing edges**. To remove an edge, either select two connected vertices or two neighboring cells, and then press “Remove edge”.
  * **Moving vertices**. To move a vertex, select one vertex, press “Move vertex”, and then click on the image to indicate the new location.
  * **Removing vertices**. To remove vertices, select one or more vertices and then press “Remove vertex”.
  * **Removing cells**. EDGE may identify junk or noise in the image as cells, and these should be removed manually by the user. To do so, just click on them and press “Remove cell”. Note: EDGE assumes there is no empty space between cells, so if empty space exists, these artifact “cells” must be removed manually at this time. To check which regions have been identified as cells, try pressing the Select all (shortcut: s) button to see the centroid of each cell.
  * **Adding cells**. To use this feature, select all the vertices that will be a part of this new cell, and press the “Add cell” button.This feature is rarely useful. It is generally used if the segmentation results in some empty space that should actually be a cell. The easier way of adding new cells is with the "add edge" feature.

# Automatic error correction #
To use automatic error correction, select it in the "Correction type" panel (inside the "Vectorized cell adjustments" panel). There are four automatic error correction methods:

  1. **Add edge**. This algorithm looks for untracked cells that could become tracked if an edge were added. The best edge is then chosen based on an overlap score with the cells in the previous image.
  1. **Remove edge**. This algorithm looks for untracked cells that could become tracked if an edge were removed.  The best edge is then chosen based on an overlap score with the cells in the previous image.
  1. **Split edge**. This algorithm is the only portion of EDGE that uses the raw membranes information (as opposed to the polygon approximations). The algorithm tries to add additional vertices in the middle of edges such that the resulting edge more closely conforms to the raw membrane. The "minimum angle" and "maximum angle" settings in the "Image processing panel" are used for automatic edge splitting. See the ImporterSettings Wiki page for more information.
  1. **R+S+A edge**. This button applies automatic edge removal, automatic edge splitting, and add automatic edge addition in sequence.

More details on how automatic error correction works can be found in the [Supporting Information](http://people.seas.harvard.edu/~mgelbart/publications/Gelbart2012_SI.pdf) section of our [publication on EDGE](http://people.seas.harvard.edu/~mgelbart/publications/Gelbart2012.pdf).