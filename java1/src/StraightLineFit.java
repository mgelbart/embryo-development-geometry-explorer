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


/**
 * Fit a straight line to the data, of the form z = mX(x - bX), z = mY(y - bY).
 * These form the equation to a line, z = mX(x - bX), z = mY(y - bY),
 * where m is the slope and b is the x-intercept
 * This is a helper class that holds four public final fields: mX, bX, mY, and bY.
 * Note: this routine ignores NaN rows.
 */
public class StraightLineFit {
	public final double mX;
	public final double bX;
	public final double mY;
	public final double bY;
	
	public StraightLineFit(double[][] yx, double[] z) {
		if (yx.length != z.length) {
			System.err.println("Error in StraightLineFit constructor: xy and z arrays must be the same length.");
			mX = Double.NaN;
			bX = Double.NaN;
			mY = Double.NaN;
			bY = Double.NaN;
			return;
		}
		if (yx[0].length != 2) {
			System.err.println("Cannot create StraightLineFit - input must have dimensions n x 2");
			mX = Double.NaN;
			bX = Double.NaN;
			mY = Double.NaN;
			bY = Double.NaN;
			return;
		}
		int n = z.length;

		double[] x = new double[n];
		double[] y = new double[n];
		for (int i = 0; i < n; i++) {
			y[i] = yx[i][0];
			x[i] = yx[i][1];
		}
		
		// remove NaN rows
		int notNaN = 0;
		for (int i = 0; i < n; i++) 
			if (!Double.isNaN(x[i])) notNaN++;
			
		double[] x2 = new double[notNaN];
		double[] y2 = new double[notNaN];
		double[] z2 = new double[notNaN];
		
		notNaN = 0;
		for (int i = 0; i < n; i++) { 
			if (!Double.isNaN(x[i])) {
				x2[notNaN] = x[i];
				y2[notNaN] = y[i];
				z2[notNaN] = z[i];
				notNaN++;
			}
		}
		
		// finished removing NaN rows

		double[] results;
		results = lineFit(x2, z2);
		mX = results[0];
		bX = results[1];
		results = lineFit(y2, z2);
		mY = results[0];
		bY = results[1];
	}

	// formula from Wikipedia: Linear Regression (subsection 2.1.1: univariate linear case)
	// performs the fitting with switching x and z, to avoid near infinite slopes
	private double[] lineFit(double[] x, double[] z) {
		int n = x.length;
		double[] temp = x;
		x = z;
		z = temp;
		
		double sumX = 0;
		double sumZ = 0;
		double sumSqX = 0;
		double sumXZ = 0;
		for (int i = 0; i < n; i++) {
			sumX += x[i];
			sumZ += z[i];
			sumSqX += x[i] * x[i];
			sumXZ += x[i] * z[i];
		}

		double mResult; 
		double bResult;

		mResult = (n * sumXZ - sumX * sumZ) / (n * sumSqX - sumX * sumX);
		bResult = (sumZ - mResult * sumX) / n;
		
		if (mResult == 0.0) {
			mResult = Double.MAX_VALUE;
			bResult = z[0];
		}
		else {
			mResult = 1.0 / mResult;
		}
		
		double[] results = new double[2];
		results[0] = mResult;
		results[1] = bResult;
		return results;
	}

	public String toString() {
		return "StraightLineFit, mX = " + mX + ", bX = " + bX + ", mY = " + mY + ", bY = " + bY + ".";
	}
	
}

