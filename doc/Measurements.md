# Introduction #
A key feature in EDGE is the ability to create your own measurements functions. A measurement can be any property of the cell that is calculated using the available data, which is the polygon membranes, the connectivity between cells, the tracking information, etc. Examples of user-defined measurements could be the tilt of a cell with respect to the z-axis, the curvature, the amount of myosin inside the cell at each layer, the number of neighbors, number of vertices, etc. New measurements must be written in MATLAB and saved as a .m file in the measurements folder, located in the EDGE home directory. For example, a measurement of the myosin intensity would be placed in the `<EDGE_install_directory>/Measurements/Myosin` folder. By placing the file in the Myosin folder, the program knows that it will be passed the Myosin images as the input argument. However, access to all other channels is provided for special cases.

To see some examples measurements, see the files in `<EDGE_install_directory>/Measurements`, for example `<EDGE_install_directory>/Measurements/Membranes/basic_2d.m`.

All user-defined measurement files must conform to the basic interface defined here. First, the function must take nine input arguments. They are as follows:

  1. The embryo, a Java object of type Embryo4D which contains all the information about the polygon membranes.
  1. The function handle to get the channel image, with two arguments (t, z).
  1. The current time, an integer.
  1. The current depth, an integer.
  1. The cell index, an integer.
  1. The spatial xy-resolution, a double.
  1. The spatial z-resolution, a double.
  1. The temporal t-resolution, a double.
  1. A structure containing function handles to the images, in the same format as (2).

The output of the function must be three cell arrays. They are as follows:

  1. The data itself, either as a scalar value or a larger set of numbers.
  1. The names of the measurements defined by this file, as strings (in the same order as the data).
  1. The units of the measurements defined by this file, as strings (in the same order as the data).

It may be useful to examine the example Measurement files to gain a better understanding of this interface.

# Accessing stored Measurement data #
When a data set is exported to EDGE, the data is stored in the `Measurements` subfolder in the `DATA_GUI` folder. For example, for a data set called “embryo1” the measurements would be in `<EDGE_install_directory>/DATA_GUI/embryo1/Measurements`”. Each measurement is stored as a separate .mat file in this folder.