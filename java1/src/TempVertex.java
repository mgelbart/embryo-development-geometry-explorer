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


import java.util.Set;
import java.util.HashSet;
import java.util.Vector;

/**
 * A wrapper of the Vertex class that knows which cells it is part of.
 * Used in the CellGraph constructor only. 
 * 
 * @author Michael Gelbart
 */
public class TempVertex {
	private Vertex vertex;
	private Set<Integer> cellNeighbors;
	
	public TempVertex(Vertex input) {
		vertex = input;
		cellNeighbors = new HashSet<Integer>();
	}
	
	public double[] vertexCoords() {
		return vertex.coords();
	}
	
	public Vertex vertex() {
		return vertex;
	}
	
	public Set<Integer> neighbors() {
		return cellNeighbors;
	}
	
	public void addNeighbor(int i) {
		cellNeighbors.add(i);
	}
	
	public void removeNeighbor(int i) {
		cellNeighbors.remove(i);
	}
	
	public int numNeighbors() {
		return cellNeighbors.size();
	}
	
	public boolean containsNeighor(int i) {
		return cellNeighbors.contains(i);
	}
	
	public void addNeighbors(int[] input) {
		for (int i : input) cellNeighbors.add(i);
	}
	
	/** 
	 * does cellNeighbors contain exactly those elements in input and no more?
	 * assumes input has no duplicates!
	 * @param input	array of input integers 
	 * @return success or failure
	 */
	public boolean sameNeighbors(int[] input) {
		if (input.length != cellNeighbors.size()) return false;
		for (int i : input) 
			if (!cellNeighbors.contains(i)) return false;
		return true;
	}
	
	/** Turn an array of TempVertex into an array of Vertex. */
	public static Vertex[] toVertexArray(TempVertex[] input) {
		Vertex[] vertices = new Vertex[input.length];
		for (int i = 0; i < input.length; i++) {
			if (input[i] == null) vertices[i] = null;
			else vertices[i] = input[i].vertex;
		}
		return vertices;
	}
	
	/** Merge two vertices. */
	public static TempVertex merge(Vector<TempVertex> verts) {
				
		// combine the set of neighbors			
		Set<Integer> cellNeighborsSet = new HashSet<Integer>();
		int y = 0; int x = 0;
		for (TempVertex v : verts) {
			y += v.vertexCoords()[0];
			x += v.vertexCoords()[1];
			for (int fc : v.cellNeighbors)
				cellNeighborsSet.add(fc);
		}
		y = (int)Math.round((double)y/(double)verts.size());
		x = (int)Math.round((double)x/(double)verts.size());
		
		// make array from TreeSet
		TempVertex merged = new TempVertex(new Vertex(y, x));
		merged.cellNeighbors = cellNeighborsSet;
		return merged;
	}
	
	/** A recursive function used in merging the vertices up to some distance threshold.
	// 
	 * In other words, finds all the vertices that are close to the vertex with index i.
	 * 
	 * @param i the vertex we are considering now, to merge with others
	 * @param distMatrix a boolean matrix which states if two vertices are close enough to be merged
	 * @param interVerts initially empty, keeps track of vertices that will be merged
	 * @param tempVerts the initial big set of input vertices
	 */
	public static void vertexMergeRecursive(int i, boolean[][] distMatrix, 
			Vector<TempVertex> interVerts, Vector<TempVertex> tempVerts) {
		
		interVerts.add(tempVerts.elementAt(i));
		
		// mark this vertex as already checked
		// the diagonal column is used to see if the vertex is "available" for merging
		distMatrix[i][i] = false;
		
		for (int j = 0; j < distMatrix.length; j++)
			if (distMatrix[i][j] && distMatrix[j][j]) 
				vertexMergeRecursive(j, distMatrix, interVerts, tempVerts);
	}
	
	public String toString() {
		String s = "TempVertex:: " + vertex.toString() + " with neighbors " ;
		for (int i : cellNeighbors) s += (i + ", ");
		return s;
	}
}