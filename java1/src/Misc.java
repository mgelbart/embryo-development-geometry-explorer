/****************************************************************************************
Copyright (c) 2012, Michael Gelbart (michael.gelbart@gmail.com)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
****************************************************************************************/


import java.util.Stack;

public class Misc {	
	// returns the angle (in radians) of a point given an origin on the interval [0 2pi] i think
	public static double angle(double[] origin, double[] point) {
        double dx = point[1] - origin[1];
        double dy = origin[0] - point[0];
        double angle = Math.atan2(dy, dx);
        if (angle < 0) angle = 2*Math.PI + angle;
        return angle;
	}
	// returns the (non-negative) angle between a and b using the given origin (in radians)
	public static double angle(double[] origin, double[] a, double[] b) {
		double angle = Math.abs(angle(origin, a) - angle(origin, b));
		// don't want to get the big angle between them
		if (angle > Math.PI)
			angle = 2*Math.PI - angle;
		return angle;
	}
	
	
	public static int sign(int a) {
		if (a > 0) return +1;
		if (a < 0) return -1;
		else return 0;
	}
	
	// returns the distance between the points a and b
	public static double distance(int[] a, int[] b) {
		int y0 = a[0]; 
		int x0 = a[1];
		int y1 = b[0];
		int x1 = b[1]; 
		return Math.hypot(x1 - x0, y1 - y0);
	}
	public static double distance(double[] a, double[] b) {
		double y0 = a[0]; 
		double x0 = a[1];
		double y1 = b[0];
		double x1 = b[1]; 
		return Math.hypot(x1 - x0, y1 - y0);
	}
	public static double[] midpoint(double[] a, double[] b) {
		double[] out = new double[2];
		out[0] = (a[0] + b[0])/2;
		out[1] = (a[1] + b[1])/2;
		return out;
	}
	public static int[] midpointInt(double[] a, double[] b) {
		int[] out = new int[2];
		out[0] = (int)Math.round((a[0] + b[0])/2);
		out[1] = (int)Math.round((a[1] + b[1])/2);
		return out;		
	}
	public static double slope(double[] a, double[] b) {
		return (a[0] - b[0]) / (a[1] - b[1]);
	}

	
//	// makes a distance matrix and then checks if each value is greater than DIST_THRESH
//	// returns a boolean array
//	// works fast for small DIST_THRESH (which is usually the case)
//	// takes time proportional to n*thresh^2 instead of n^2
//	public static boolean[][] distMatrixFast(int[][] coords, int[][] plot_indeces, double DIST_THRESH, int Ys, int Xs) {
//		int n = coords.length;
//		boolean[][] matrix = new boolean[n][n];
//		
//		int th = (int) Math.ceil(DIST_THRESH);
//		
//		for (int i = 0; i < n; i++) { // for each point
//			int y0 = coords[i][0]; int x0 = coords[i][1];
//			
//			for (int y = y0 - th; y <= y0 + th; y++) {
//				if (y < 1 || y > Ys) continue;
//				for (int x = x0 - th; x <= x0 + th; x++) {
//					if (x < 1 || x > Xs) continue;
//					
//					// if this point is a vertex and it is within the original DIST_THRESH
//					int ind = plot_indeces[y-1][x-1];
//					if (ind >= 0 && Misc.distance(coords[i], coords[ind]) <= DIST_THRESH) {
//						matrix[i][ind] = true;
//					}
//				}
//			}
//		}
//		
//		return matrix;
//	}
	
//	public static double[][] distMatrix(double[][] coords) {
//		int n = coords.length;
//		double[][] matrix = new double[n][n];
//		
//		for (int i = 0; i < n; i++)
//			for (int j = 0; j < n; j++)
//				matrix[i][j] = distance(coords[i], coords[j]);
//		return matrix;
//	}
	
	
	public static void drawLine(double[][] img, double[] a, double[] b) {
		int[] A = new int[2];
		int[] B = new int[2];
		A[0] = (int) Math.round(a[0]);
		A[1] = (int) Math.round(a[1]);
		B[0] = (int) Math.round(b[0]);
		B[1] = (int) Math.round(b[1]);
		drawLine(img, A, B);
	}
	// draws a line on img between the points a and b
	public static void drawLine(double[][] img, int[] a, int[] b) {
		int y0 = a[0]; 
		int x0 = a[1];
		int y1 = b[0];
		int x1 = b[1]; 
		
		// check that 0 < y <= Ys,  0 < x <= Xs
		// takes the off-by-one problem into account because Java indexing starts at 0
		if (Math.max(y0, y1) > img.length || Math.max(x0, x1) > img[0].length
				|| Math.min(y0, y1) <= 0 || Math.min(x0, x1) <= 0) {
			System.err.println("Error in Java:Misc: Points out of image!");
			return;
		}
				
		// vertical line (infinite slope)
		if (x0 == x1) {
			for (int y = Math.min(y0, y1); y <= Math.max(y0, y1); y++)
				img[y - 1][x0 - 1] = 1;
		}
		else {  // non-vertical line
			double slope = (double)(y1-y0)/(x1-x0);
			double xIncrement = Math.min(Math.abs(1.0/slope), 1.0);
			xIncrement *= Math.signum(x1 - x0); // set the sign of xIncrement
			double y = y0;
					
			for (double x = x0; Math.abs(x - x1) > 0.001; x += xIncrement) {
				img[(int)Math.round(y) - 1][(int)Math.round(x) - 1] = 1;
				y += slope * xIncrement;
			}
		}
	}
	
	@SuppressWarnings("unchecked")
	public static double[][][] drawCellStack(Cell[] cells) {
		Stack<Double>[] yPoints = (Stack<Double>[]) new Stack[cells.length];
		Stack<Double>[] xPoints = (Stack<Double>[]) new Stack[cells.length];
		for (int i = 0; i < cells.length; i++) {
			yPoints[i] = new Stack<Double>();
			xPoints[i] = new Stack<Double>();
		}
		
		for (int z = 0; z < cells.length; z++) {
			Cell c = cells[z];
			
			// if the Cell is null then skip this layer.
			if (c == null) continue;

			Vertex[] vertices = c.vertices();
			// draw the cell edges
			for (int i = 0; i < vertices.length - 1; i++)
				drawLine(yPoints[z], xPoints[z], vertices[i].coords(), vertices[i+1].coords());	
			drawLine(yPoints[z], xPoints[z], vertices[vertices.length - 1].coords(), vertices[0].coords());
		}
		
		// make the array big enough for the biggest Cell
		int maxSize = Integer.MIN_VALUE;
		for (int i = 0; i < cells.length; i++) {
//			System.out.println(yPoints[i].size());
			maxSize = Math.max(maxSize, yPoints[i].size());
		}
		maxSize++; // to avoid holes in the images
		
		double[][][] image = new double[3][cells.length][maxSize];
//		CellStackImage image = new CellStackImage(cells.length, maxSize);
		
		for (int z = 0; z < cells.length; z++) {
			int count = 0;
			
			// if the Cell was null fill them with NaN 
			if (yPoints[z].isEmpty()) {
				for (int i = 0; i < maxSize; i++) {
					image[0][z][i] = Double.NaN;
					image[1][z][i] = Double.NaN;
					image[2][z][i] = Double.NaN;
				}
				continue;
			}
			
			while (! yPoints[z].isEmpty()) {
				image[0][z][count] = xPoints[z].pop();// * micronPixel;
				image[1][z][count] = yPoints[z].pop();// * micronPixel;
				image[2][z][count] = z;// * dZ;
				count++;
			}
			
			// then fill in the remaining with the first point to complete the connection
			// need maxSize points to draw the Cell stack
			for (; count < maxSize; count++) {
				image[0][z][count] = image[0][z][0];
				image[1][z][count] = image[1][z][0];
				image[2][z][count] = image[2][z][0];
			}
			
		}
		return image;
	}
	// draws a line between the points a and b and stores the coordinates of the points
	// in the Stacks yPoints and xPoints
	private static void drawLine(Stack<Double> yPoints, Stack<Double> xPoints, double[] a, double[] b) {
		
		final double stepsize = 1.0;  // number of pixels per data point
		
		double y0 = a[0]; 
		double x0 = a[1];
		double y1 = b[0];
		double x1 = b[1]; 
				
		// vertical line (infinite slope)
		if (x0 == x1) {
			for (double y = Math.min(y0, y1); y <= Math.max(y0, y1); y+=stepsize) {
				yPoints.push(y);
				xPoints.push(x0);
			}
		}
		else {  // non-vertical line
			double sign = Math.signum(x1 - x0);
			
			double slope = (y1-y0)/(x1-x0);
			double xIncrement = Math.min(Math.abs(1.0/slope), 1.0);
			xIncrement *= Math.signum(x1 - x0); // set the sign of xIncrement
			double y = y0;
					
			for (double x = x0; x*sign < x1*sign; x += xIncrement) {
				yPoints.push(y);
				xPoints.push(x);
				y += slope * xIncrement * stepsize;
			}
		}
	}	
		
}
