# Introduction #
EDGE has two parts, the Importer and the Browser. This page discusses using the Browser. You will need to use the Importer before you can use the Browser.

To run the Browser, type `EDGE` in your MATLAB console. Unlike the importing stage where the steps must be followed in sequence, the Browser offers a collection of features that can be used in any order or not at all.

# Selecting cells #
To select a cell, simply click on it as you would in the importer. By default, only one cell can be selected at a time. To select more than one cell, press the “select manually” button on the right panel. To switch back to the original mode, press this button again. You can also select all cells with the “select all” button. In this case the “select manually” mode is automatically turned on. Note that it may take a few minutes to draw the plots if all cells are selected.

Another way of selecting cells is to select a single cell and its neighbors. To do this, change the “neighbors order” in the “Select cells” panel. An order of 1 means first-order neighbors, or those cells directly touching the selected cell. Second-order neighbors are those neighboring the first-order neighbors, and so on. Each order is plotted in a separate color.

When not in the “select manually” mode, the index of the current cell is shown under “current cell #”. The user can also enter a number in this box to find a cell of interest. Note, however, that cell numbers may not be preserved if the data set is re-processed and re-exported by the Importer.

# Measurement plots #
When one or more cells are selected, the selected measurement is displayed on the plot at the lower left of the screen. The plot shows different things, depending on the type of data set, number of cells selected, etc. The axis of the plot can be fixed using the “y-axis scale” panel. The “Plot...” panel allows you to view the average of the selected cells, or in the case of a single cell in a live data set, the average over all depths. In the neighbors mode, the average is taken over each neighbors-order.

# 3D reconstructions #
When one or more cells are selected, a 3D reconstruction of the selected portion is shown at the lower right of the screen. Different parts of the drawing can be selected or unselected in the “Show...” panel. You can also to switch between a spatial and temporal stack. A spatial stack is an intuitive 3D reconstruction with the z-axis representing the z-dimension. The temporal stack uses the z-axis to represent time and can be used to check the temporal tracking. The user can make movies or take pictures with these 3D images using the button provided. Movies are created in the “DATA\_OUTPUT” folder in the main EDGE directory.