//
//  OCVMorletCoefficients.h
//  ObjectiveCV
//
//  Created by Marcelo Cicconet on 7/23/13.
//  Copyright (c) 2013 Marcelo Cicconet. All rights reserved.
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
