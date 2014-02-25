//
//  OCVMorletCoefficients.h
//  ObjectiveCV
//
//  This code is distributed under the MIT Licence.
//  See notice at the end of this file.
//

#import <Foundation/Foundation.h>
#import "OCVFloatImage.h"
#import "OCVMorletWavelet.h"
#import "OCVMorletConvolution.h"

@interface OCVMorletCoefficients : NSObject {
    float magnitudeThreshold;
    
    int nOrientations;
    OCVMorletWavelet ** kernels;
    OCVMorletConvolution * convolution;
    OCVFloatImage * input;
    OCVFloatImage ** outputs;
    
    int halfWindowSize;
    int nSelectedRows;
    int nSelectedCols;
    int * selectedRows;
    int * selectedCols;
    
    BOOL dataStructureIsList;
    BOOL thresholdingIsLocal;
    
    int nCoefficients;
    int * indices;
    float * m;
    float * a;
    float * x;
    float * y;
    
    OCVFloatImage * M;
    OCVFloatImage * N; // for local thresholding
    OCVFloatImage * A;
    OCVFloatImage * X;
    OCVFloatImage * Y;
    OCVFloatImage * IX;
    OCVFloatImage * IY;
    int * rowsL;
    int * rowsR;
    int * colsU;
    int * colsB;
}

@property(readonly, assign) OCVFloatImage * M;
@property(readonly, assign) OCVFloatImage * A;
@property(readonly, assign) OCVFloatImage * IX0;
@property(readonly, assign) OCVFloatImage * IY0;

- (id)initForImageWidth:(int)theWidth
                 height:(int)theHeight
                  scale:(float)theScale
          nOrientations:(int)theNOrientations
                hopSize:(int)theHopSize
         halfWindowSize:(int)theHalfWindowSize
     magnitudeThreshold:(float)theMagnitudeThreshold
    dataStructureIsList:(BOOL)theDataStructureIsList
    thresholdingIsLocal:(BOOL)theThresholdingIsLocal;
- (void)setInput:(OCVFloatImage *)theInput;
- (void)performConvolutions;
- (void)findCoefficients;
- (void)saveOutputsToFilePath:(NSString *)theFilePath;

@end

//
// Copyright (c) 2014 Marcelo Cicconet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
