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


import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.Queue;
import java.awt.Polygon;

/**
 * A graph representation of one slice of a single cell. This objects contains references to its
 * {@link Vertex} objects.
 * 
 * @author Michael Gelbart
 *
 */
public class Cell implements java.io.Serializable {
	
	final static long serialVersionUID = (long) "Cell".hashCode();

	/** the CellGraph that contains this Cell */
	public final CellGraph parent;
	
	// Vertices of the Cell (stores all the connectivity information)
	private Vertex[] vertices;
	
	// the index of the cell for tracking
	private int index = -1;
	
	/** Create a copy of the Cell and thus all of its Vertices. 
	 * This is not especially useful, because we probably don't want to 
	 * copy all the Vertices given that they are shared by other cells. */
	public Cell(Cell toCopy) {
		index = toCopy.index;
		parent = toCopy.parent;
		vertices = new Vertex[toCopy.numV()];
		for (int i = 0; i < numV(); i++)
			vertices[i] = new Vertex(toCopy.vertices()[i]);
	}
	
	/**
	* Create a new Cell with coordinates (y,x) and vertices inputVerts.
	* The constructor automatically sorts the Vertices into clockwise order.
	*/
	public Cell(int[] centroid, Vertex[] inputVertices, CellGraph parent) {
		
		vertices = inputVertices;
		this.parent = parent;
		
		// sorts the vertices in order of standard angle
        Comparator<Vertex> byAngle = new ByAngle(centroid);
        //  sort starting from index 1 so that vertices[0] is first
		Arrays.sort(vertices, 0, vertices.length, byAngle);
	}
	/** Alternate constructor that assumes the vertices are already sorted. */
	public Cell(Vertex[] vertices, CellGraph parent) {
		this.vertices = vertices;
		this.parent = parent;
	}
	
	/** Get the first order neighbors of this Cell. */
	public Cell[] neighbors() {
		return neighbors(1);
	}
	/** Get the Nth order neighbors of this Cell. */
	public Cell[] neighbors(int n) {
		return parent.cellNeighbors(this, n);
	}
	
	/** Add the vertex newVert into the list of vertices in between v and w.
	 * Assumes v and w are connected. */
	public void splitEdge(Vertex v, Vertex w, Vertex newVert) {
		if (!connected(v, w)) return;
		Vertex[] newVertArray = new Vertex[numV() + 1];
		
		// special corner case - one is vertices[0] and one is vertices[numV-1]
		if ((vertices[0] == w && vertices[numV()-1] == v) ||
			 vertices[0] == v && vertices[numV()-1] == w) {
			newVertArray[0] = newVert;
			for (int i = 0; i < numV(); i++)
				newVertArray[i+1] = vertices[i];
		}
		else {	
			int offset = 0;
			for (int i = 0; i < numV(); i++) {
				// loop through each vertex
				newVertArray[i + offset] = vertices[i];
				if ((vertices[i] == v || vertices[i] == w) && offset == 0) {
					// when you hit the *first* (offset == 0) one of these, 
					// throw in the new vertex, and then add an offset from now on
					newVertArray[i + 1] = newVert;
					offset = 1;
				}
			}
		}
		
		vertices = newVertArray;
		if (Embryo4D.DEBUG_MODE && !isValid()) System.err.println("Error in Cell:splitEdge!");
		assert(isValid());
	}
	
	/** remove the vertex v while preserving the sorted vertex order. */
	public void removeVertex(Vertex v) {
		if (!containsVertex(v)) return;
		Vertex[] newVertArray = new Vertex[numV() - 1];
		int j = 0;
		for (int i = 0; i < numV(); ) {
			if (vertices[i] == v)
				i++;
			else
				newVertArray[j++] = vertices[i++];
		}
		vertices = newVertArray;
		if (Embryo4D.DEBUG_MODE && !isValid()) System.err.println("Error in Cell:removeVertex!");
		assert(isValid());
	}
	
	/** Are vertices a and b connected in this cell? */
	public boolean connected(Vertex a, Vertex b) {
		Vertex last = null;
		for (Vertex v : vertices) {
			if (a == v && b == last) return true;
			if (b == v && a == last) return true;
			last = v;
		}
		Vertex first = vertices[0];
		if (a == first && b == last) return true;
		if (b == first && a == last) return true;
		return false;
	}
	
	public boolean equals(Cell that) {
		if (this.numV() != that.numV()) return false;
		for (int i = 0; i < numV(); i++)
			if (this.vertices()[i] != that.vertices()[i]) return false;
		return true;
	}
	
	public boolean isActive() {
		return CellGraph.isActive(this);
	}
	public int index() {
		return index;
	}
	/** Get the indices of an array of cells (returned in an array). */
	public static int[] index(Cell[] c) {
		if (c == null) return null;
		int[] out = new int[c.length];
		for (int i = 0; i < c.length; i++)
			out[i] = c[i].index;
		return out;
	}
	/** Change the index of this cell. */
	public void changeIndex(int to) {
		parent.changeIndex(this, to);
	}
	
	/** Directly set the Cell's index. Only called by the parent CellGraph. */
	public void setIndex(int i) {
		index = i;
	}
	
	public int T() { return parent.t; }
	public int Z() { return parent.z; }
	public int t() { return parent.parent().translateT(parent.t); }
	public int z() { return parent.parent().translateZ(parent.z); }
	
	/*	
	// cyclically shift the order of the Vertices to match other cells
	// would be useful for tracking vertices
	public void shiftUp() {
		Vertex temp = vertices[vertices.length-1];
		for (int i = vertices.length - 1; i > 0; i--)
			vertices[i] = vertices[i-1];
		vertices[0] = temp;		
	}
	public void shiftDown() {
		Vertex temp = vertices[0];
		for (int i = 0; i < vertices.length - 1; i++)
			vertices[i] = vertices[i+1];
		vertices[vertices.length-1] = temp;
	}
*/
	
	/** Returns the centroid of the Cell in an array.
	// Uses the formula from Wikipedia:Polygon. */
	public double[] centroid() {
		// create an array of the vertex coordinates for easy accessing
		double[] vY = new double[vertices.length + 1];
		double[] vX = new double[vertices.length + 1];
		for (int i = 0; i < vertices.length; i++) {
			vY[i] = vertices[i].coords()[0];
			vX[i] = vertices[i].coords()[1];
		}
		// make these arrays cyclic so that vY[0] = vY[vertices.length]
		vY[vertices.length] = vY[0];
		vX[vertices.length] = vX[0];
		
		double y = 0, x = 0;
		for (int i = 0; i < vertices.length; i++) {
			y += (vY[i] + vY[i+1]) * (vX[i]*vY[i+1] - vX[i+1]*vY[i]);
			x += (vX[i] + vX[i+1]) * (vX[i]*vY[i+1] - vX[i+1]*vY[i]);
		}
		
		double area = area();
		y /= (6.0 * area);
		x /= (6.0 * area);
		
		double[] centroid = new double[2];
		centroid[0] = Math.abs(y); 
		centroid[1] = Math.abs(x);  
		return centroid;
	}
	/** Returns the centroid as a pair of integers. */
	public int[] centroidInt() {
		int[] centroidInteger = new int[2];
		double[] centroidDouble = centroid();
		centroidInteger[0] = (int) Math.round(centroidDouble[0]);
		centroidInteger[1] = (int) Math.round(centroidDouble[1]);
		return centroidInteger;
	}
	/** Returns the centroids for an array of cells. */
	public static double[][] centroidStack(Cell[] cells) {
		if (cells == null) return null;
		double[][] centStack = new double[cells.length][2];
		for (int i = 0; i < cells.length; i++) {
			if (cells[i] == null) {
				centStack[i][0] = Double.NaN;
				centStack[i][1] = Double.NaN;
			}
			else
				centStack[i] = cells[i].centroid();
		}
		return centStack;
	}
	
	/** Returns all of the vertices in a cells.length x nverts_max x 2 array,
	 where nverts_max is the maximum number of vertices of all the Cells in cells. */
	public static double[][][] allVertexStack(Cell[] cells) {
		if (cells == null) return null;
		int maxVerts = 0;
		for (Cell c : cells) {
			if (c == null) continue;
			maxVerts = Math.max(maxVerts, c.vertices().length);
		}
		
		double[][][] result = new double[cells.length][maxVerts][2];
		
		for (int i = 0; i < cells.length; i++) { // for each Cell
			if (cells[i] == null) {
				for (int j = 0; j < maxVerts; j++) {
					result[i][j][0] = Double.NaN;
					result[i][j][1] = Double.NaN;
				}
				continue;
			}
			Vertex[] verts = cells[i].vertices();
			for (int j = 0; j < maxVerts; j++) { // for each Vertex
				if (j < verts.length) {
					result[i][j][0] = (double) verts[j].coords()[0];
					result[i][j][1] = (double) verts[j].coords()[1];
				}
				else {
					result[i][j][0] = Double.NaN;
					result[i][j][1] = Double.NaN;
				}
			}
		}
		return result;
	}

	/** Computes and returns the area of the Cell.
	 * 
	 * Uses the formula from Wikipedia:Polygon
	 * This formula assumes the Vertices are sorted counterclockwise.
	 * If they are sorted clockwise we get the right answer but with a negative sign,
	 * so I try to keep them sorted CCW but just in case I use an absolute value at the end.
	 */
	public double area() {
		// create two arrays of the vertex coordinates for easy accessing
		double[] vY = new double[vertices.length + 1];
		double[] vX = new double[vertices.length + 1];
		for (int i = 0; i < numV(); i++) {
			vY[i] = vertices[i].coords()[0];
			vX[i] = vertices[i].coords()[1];
		}
		// make these arrays cyclic so that vY[0] = vY[numV()]
		vY[numV()] = vY[0];
		vX[numV()] = vX[0];
		
		double area = 0;
		for (int i = 0; i < numV(); i++)
			area += (vX[i] * vY[i+1]) - (vX[i+1] * vY[i]);    
		
		area /= 2;
		return Math.abs(area);
	}
	
	/** Returns the perimeter of the Cell. */
	public double perimeter() {
		double perim = 0;	
		for (int i = 0; i < numV() - 1; i++)
			perim += Misc.distance(vertices[i].coords(), vertices[i+1].coords());
		perim += Misc.distance(vertices[numV() - 1].coords(), vertices[0].coords());
		return perim;
	}
	
	/** Returns the number of vertices of the cell. */
	public int numV() {
		return vertices.length;
	}
	/** Returns the vertices in an array. */
	public Vertex[] vertices() { 
		return vertices;
	}
	/** Returns the vertex coordinates in an array. */
	public double[][] vertexCoords() {
		return Vertex.coords(vertices);
	}
	/** Returns the vertex coordinates for an array of cells. */
	public static double[][] vertexCoords(Cell[] cells) {
		Queue<Vertex> allVerts = new LinkedList<Vertex>();
		for (Cell c : cells)
			for (Vertex v : c.vertices)
				allVerts.add(v);
		Vertex[] allVertsArray = new Vertex[allVerts.size()];
		allVerts.toArray(allVertsArray);
		return Vertex.coords(allVertsArray);
	}
	
	/** Return the list of vertices sorted in a special order.
	 * 
	 * The list (stored in an array) starts with v and ends with w.
	 * We assume v and w are connected and both part of this cell.	 */
	public Vertex[] vertices(Vertex v, Vertex w) {
		if (!containsVertex(v)) return null;
		if (!containsVertex(w)) return null;
		if (!connected(v, w)) return null;
		
		Vertex[] out = new Vertex[numV()];
		int i = indexOf(v);
		int j = indexOf(w);

		int newInd = 0;
		
		// corner cases where it wraps around
		if (i == 0 && j == numV() - 1)
			return vertices;
		else if (i == numV() - 1 && j == 0) {
			for (int k = numV() - 1; k >= 0; k--)
				out[newInd++] = vertices[k];
			return out;
		}
			
		// normal cases where they are not at the ends
		if (i > j) {
			for (int k = i; k < numV(); k++)
				out[newInd++] = vertices[k];
			for (int k = 0; k < i;      k++)
				out[newInd++] = vertices[k];
		}
		else {
			for (int k = i; k >= 0; k--)
				out[newInd++] = vertices[k];
			for (int k = numV() - 1; k > i; k--)
				out[newInd++] = vertices[k];
		}
		return out;
	}
	
	/** Returns the index of the vertex v as it is stored in the cell.
	 * 
	 *  Result is between 0 and numV()-1, inclusive. */
	public int indexOf(Vertex v) {
		if (!containsVertex(v)) return -1;
		for (int i = 0; i < numV(); i++)
			if (vertices[i] == v)
				return i;
		return -1;
	}
	
	/** Translate the cell by delta. 
	 * 
	 * i.e., translate the location of all vertices by delta
	 * NOTE: other cells may own these same vertices!! 
	 * So, this operation should only be done for a cell that has all its own vertices! */
	public void translate(double[] delta) {
		for (Vertex v : vertices)
			v.translate(delta);
	}

//	// Is the point input inside the Cell? This algorithm approximates the Cell 
//	// as convex to save time. This will be a workable approximation.
//	// Algorithm from http://local.wasp.uwa.edu.au/~pbourke/geometry/insidepoly/
//	// If the point lies "exactly" on the boundary the behavior is undefined.
//	public boolean containsPoint(int[] input) {
//		int y = input[0];
//		int x = input[1];
//		
//		// create an array of the vertex coordinates for easy accessing
//		double[] vY = new double[numV() + 1];
//		double[] vX = new double[numV() + 1];
//		for (int i = 0; i < numV(); i++) {
//			vY[i] = vertices[i].coords()[0];
//			vX[i] = vertices[i].coords()[1];
//		}
//		// make these arrays cyclic so that vY[0] = vY[numV()]
//		vY[numV()] = vY[0];
//		vX[numV()] = vX[0];
//		
//		// formula:	(y - y0) (x1 - x0) - (x - x0) (y1 - y0) > 0?
//		boolean side = (y - vY[0]) * (vX[1] - vX[0])  >  (x - vX[0]) * (vY[1] - vY[0]);
//		for (int i = 1; i < numV(); i++)
//			if (((y - vY[i]) * (vX[i+1] - vX[i])  >  (x - vX[i]) * (vY[i+1] - vY[i])) != side)
//				return false;	
//		
//		return true;
//	}
	
	/** Returns the bounding box around this cell in the format [minY maxY minX maxX]. */
	public double[] boundingBox() {  
		double[] out = new double[4];
		out[0] = Double.MAX_VALUE;
		out[1] = Double.MIN_VALUE;
		out[2] = Double.MAX_VALUE;
		out[3] = Double.MIN_VALUE;
		for (Vertex v : vertices) {
			out[0] = Math.min(out[0], v.coords()[0]);
			out[1] = Math.max(out[1], v.coords()[0]);
			out[2] = Math.min(out[2], v.coords()[1]);
			out[3] = Math.max(out[3], v.coords()[1]);
		}
		return out;
	}
	
	/** Computes the overlapping area between this and that Cell. */
	public double overlapArea(Cell that) {
//		Polygon p1 = this.getPolygon();
//		Polygon p2 = that.getPolygon();
//		Area a1 = new Area(p1);
//		Area a2 = new Area(p2);
//		Area dif = new Area(p1);
//		dif.subtract(a2);   // dif = a1 - a2
//		a1.subtract(dif);   // a1 = a1 - dif = a1 - (a1 - a2)
		if (that == null) return Double.NaN;
		return PolygonIntersect.intersectionArea(this.vertexCoords(), that.vertexCoords());
	}
	
	/** Is the point input inside of this cell? */
	public boolean containsPoint(double y, double x) {
		// upgrade for speed: if outside bounding box, then false
		double[] bbox = boundingBox();
		if (y < bbox[0] || y > bbox[1] || x < bbox[2] || x > bbox[3]) return false;
		// end upgrade for speed
		
		double[] point = new double[2];
		point[0] = y;
		point[1] = x;
		return containsPoint(point);
	}
	/** Is the point input inside of this cell?
	 * 
	 * Uses the java.awt.Polygon to determine if the point is inside.
	 * @param input double array of size 2 with y and x coordinates
	 */
	public boolean containsPoint(double[] input) {
		Polygon p = getPolygon();
		return p.contains(input[1], input[0]);
	}
	// Turn the cell into a java.awt.Polygon object.
	private Polygon getPolygon() {
		int[] x = new int[numV()];
		int[] y = new int[numV()];
		for (int i = 0; i < numV(); i++) {
			x[i] = (int)vertices[i].coords()[1];
			y[i] = (int)vertices[i].coords()[0];
		}
		Polygon p = new Polygon(x, y, numV());
		return p;
	}
	
	/** Is this cell on the boundary of the image? */
	// If it has a vertex that no other cell shares, it is on the boundary
	public boolean isBoundary() {
		// if it has any vertices that are not shared
		for (Vertex v : vertices)
			if (parent.cellsNeighboringVertex(v).length <= 1) return true;
		
		// if it has any edges that are not shared
		Vertex[] verts = new Vertex[numV() + 1];
		for (int i = 0; i < numV(); i++)
			verts[i] = vertices[i];
		verts[numV()] = vertices[0];
		for (int i = 0; i < numV(); i++)
			if (edgeNeighbor(verts[i], verts[i+1]) == null) return true;
		return false;
	}
	
	// the cell that shares this edge
	private Cell edgeNeighbor(Vertex v, Vertex w) {
		if (!containsVertex(v) || !containsVertex(w)) return null;
		Cell[] c = parent.cellsNeighboringEdge(v, w);
		if (c[0] == this) return c[1];
		else if (c[1] == this) return c[0];
		else return null;
	}
	
	/** Does this (presumably active) cell touch an inactive cell? */
	public boolean touchesInactive() {
		for (Cell c : neighbors())
			if (!c.isActive()) return true;
		return false;
	}
	
	/** Does this Cell contain the Vertex input? */
	public boolean containsVertex(Vertex input) {
		for (Vertex v : vertices)
			if (v == input) return true;
		return false;
	}
	
	/** Does this cell contain both of these vertices in a connected manner? */
	public boolean containsEdge(Vertex v, Vertex w) {
		if (!containsVertex(v) || !containsVertex(w)) return false;
		return connected(v, w);
	}
	
//	// check the angles formed by consecutive groups of 3 vertices. if any is too small
//	// remove that vertex...
//	public Vertex[] checkAngle(double minAngle) {
//		// an array that has the first 2 elements at the end so it is cyclic for groups of 3
//		Vector<Vertex> badVertices = new Vector<Vertex>();  // in case there are more than one (totally unlikely)
//		Vertex[] verts = new Vertex[numV() + 2];
//		for (int i = 0; i < numV(); i++)
//			verts[i] = vertices[i];
//		verts[numV()] = vertices[0];
//		verts[numV()+1] = vertices[1];
//		for (int i = 0; i < numV(); i++) {
//			double angle = Misc.angle(verts[i+1].coords(), verts[i].coords(), verts[i+2].coords());
//			if (angle < minAngle) {
////				System.out.println(angle + " < " + minAngle);
//				badVertices.add(verts[i+1]); 
//			}
//		}
//		if (badVertices.isEmpty()) return null;
//		Vertex[] out = new Vertex[badVertices.size()];
//		badVertices.toArray(out);
//		return out;
//	}
	
	/** The minimum angle of the cell. Not necessarily interior angles... uses the smaller of the two. */
	public double minimumAngle() {
		double minAngle = Double.MAX_VALUE;
		Vertex[] verts = new Vertex[numV() + 2];
		for (int i = 0; i < numV(); i++)
			verts[i] = vertices[i];
		verts[numV()] = vertices[0];
		verts[numV()+1] = vertices[1];
		for (int i = 0; i < numV(); i++) {
			double angle = Misc.angle(verts[i+1].coords(), verts[i].coords(), verts[i+2].coords());
			minAngle = Math.min(minAngle, angle);
		}
		return minAngle;
	}
	
	/** Draw the Cell in the input array image.
	 * 
	 * The image is also returned for Matlab callers, although there is no need for this in Java. */
	public double[][] draw(double[][] image) {	
		// draw the cell edges
		for (int i = 0; i < numV() - 1; i++)
			Vertex.drawConnection(image, vertices[i], vertices[i+1]);
		Vertex.drawConnection(image, vertices[numV() - 1], vertices[0]);
		return image;
	}
	public double[][] draw() {
		double[][] image = new double[parent.Ys][parent.Xs];
		return draw(image);
	}
	
//	// draw the Cell in the smallest possible image that fits it
//	public double[][] drawBounded() {
//		double[][] vertCoords = vertexCoords();
//		double maxY = Double.NEGATIVE_INFINITY;
//		double minY = Double.POSITIVE_INFINITY;
//		double maxX = Double.NEGATIVE_INFINITY;
//		double minX = Double.POSITIVE_INFINITY;
//		for (int i = 0; i < numV(); i++) {
//			maxY = Math.max(maxY, vertCoords[i][0]);
//			minY = Math.min(minY, vertCoords[i][0]);
//			maxX = Math.max(maxX, vertCoords[i][1]);
//			minX = Math.min(minX, vertCoords[i][1]);
//		}
//		int maxYint = (int) Math.ceil(maxY);
//		int minYint = (int) Math.floor(minY);
//		int maxXint = (int) Math.ceil(maxX);
//		int minXint = (int) Math.floor(minX);
//		int Ylen = maxYint - minYint + 1;
//		int Xlen = maxXint - minXint + 1;
//		double[][] image = new double[Ylen][Xlen];
//		// draw the lines
//		for (int i = 0; i < numV()-1; i++) {
//			double[] vCoords1 = vertices()[i].coords();
//			double[] vCoords2 = vertices()[i+1].coords();
//			vCoords1[0] = vCoords1[0] - minYint;
//			vCoords1[1] = vCoords1[1] - minXint;
//			vCoords2[0] = vCoords2[0] - minYint;
//			vCoords2[1] = vCoords2[1] - minXint;
//			Misc.drawLine(image, vCoords1, vCoords2);
//		}
//		double[] vCoords1 = vertices()[numV()-1].coords();
//		double[] vCoords2 = vertices()[0].coords();
//		vCoords1[0] = vCoords1[0] - minYint;
//		vCoords1[1] = vCoords1[1] - minXint;
//		vCoords2[0] = vCoords2[0] - minYint;
//		vCoords2[1] = vCoords2[1] - minXint;
//		Misc.drawLine(image, vCoords1, vCoords2);
//		return image;
//	}
	
//	public double[][] drawFilled(double[][] image) {
//		int[] point = new int[2];
//		for (int i = 0; i < parent.Ys; i++) {
//			for (int j = 0; j < parent.Xs; j++) {
//				point[0] = i;
//				point[1] = j;
//				if (containsPoint(point))
//					image[i][j] = 1;
//			}
//		}
//		return image;
//	}
//	public double[][] drawFilled() {
//		double[][] image = draw(); // draws the borders first
//		return drawFilled(image);
//	}
	
	public String toString() {
		return "Cell with index " + index + " centered at (" + centroid()[0] + ", " + centroid()[1] + ") with area " +
			area() + " and " + numV() + " Vertices.";		
	}
	
	public boolean isValid() {
		// make sure there are at least 3 Vertices
		if (numV() < 3) {
			System.err.println(this + " has fewer than 3 Vertices");
			return false;
		}
		
		// check that none of the Vertices are null
		for (int i = 0; i < numV(); i++) {
			if (vertices[i] == null) {
				System.err.println(this + " has a null vertex.");
				return false;
			}
		}
		
//		// check that the Vertices are ordered counterclockwise
//		// although not necessarily starting with the smallest angle first (hence the mod 2pi)
//		// again, as with the original ordering, those testing assumes
//		// that the cells are reasonably convex. 
//		double deltaTheta;
//		for (int i = 0; i < numV() - 1; i++) {
//			deltaTheta = vertexAngle(vertices[i+1]) - vertexAngle(vertices[i]);
//			if (deltaTheta % (2*Math.PI) < 0) {
//				System.err.println("Vertices in " + this + " not ordered clockwise.");
//				return false;
//			}
//		}
//		deltaTheta = vertexAngle(vertices[numV() - 1]) - vertexAngle(vertices[0]);
//		if (deltaTheta % (2*Math.PI) < 0) {
//			System.err.println("Vertices in " + this + " not ordered clockwise.");
//			return false;
//		}
		
		return true;
	}
	
	/** Return a sorted array of all the angles that this cell contains (in radians). */
	public double[] vertexAngles() {
		double[] angles = new double[numV()];
		Vertex[] wrapVerts = new Vertex[numV() + 2];
		for (int i = 0; i < numV(); i++)
			wrapVerts[i] = vertices[i];
		wrapVerts[numV()] = vertices[0];
		wrapVerts[numV()+1] = vertices[1];
		
		for (int i = 0; i < numV(); i++)
			angles[i] = Misc.angle(wrapVerts[i+1].coords(), wrapVerts[i].coords(), wrapVerts[i+2].coords());  // angle of vertex i+1
		Arrays.sort(angles);
		return angles;
	}
	
	/** Returns an array with all the angles made to the cells from the centroid of this cell. */
	public double[] angle(Cell[] cells) {
		double[] angles = new double[cells.length];
		for (int i = 0; i < cells.length; i++)
			angles[i] = angle(cells[i]);
		return angles;
	}
	
	/** The angle from the centroid of this cell to the centroid of cell Point. */
	public double angle(Cell point) {
		return Misc.angle(centroid(), point.centroid());
	}
	
	/*************************************************************************/
	
	// for sorting by angle for the Vertices connected to a Cell
	private static class ByAngle implements Comparator<Vertex> {
		private double[] origin;
        
        public ByAngle(int[] o) {
            origin = new double[2];
            origin[0] = (double) o[0];
            origin[1] = (double) o[1];
        }
        
        // backwards so that a more negative angle is "greater"
        // this way the Vertices will be sorted clockwise
        public int compare(Vertex a, Vertex b) {
            double angleA = angle(origin, a);
            double angleB = angle(origin, b);
            if (angleA < angleB) return +1;
            if (angleA > angleB) return -1;
            else                 return  0;
        }
        
        // computes the angle that v makes with the point origin
        // returns the angle in the range [0, 2pi)
        // if v is at the origin 0.0 is returned
        private static double angle(double[] origin, Vertex v) {
        	return Misc.angle(origin, v.coords());
        } 
    }

}
