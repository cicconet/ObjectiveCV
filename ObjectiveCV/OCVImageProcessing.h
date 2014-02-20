//
//  OCVImageProcessing.h
//  ObjectiveCV
//
//  Created by Marcelo Cicconet on 10/5/12.
//  Copyright (c) 2012 Marcelo Cicconet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "OCVFloatImage.h"

struct OCVKernel {
	int size;
    float * data;
};
typedef struct OCVKernel OCVKernel;

@interface OCVImageProcessing : NSObject

+ (void)thresholdInput:(OCVFloatImage *)theInput lowerBound:(float)theLowerBound upperBound:(float)theUpperBound;

+ (void)gradient:(OCVFloatImage *)output input:(OCVFloatImage *)input;
+ (void)complexNormWithRealPart:(OCVFloatImage *)realImage imaginaryPart:(OCVFloatImage *)imaginaryImage output:(OCVFloatImage *)outputImage;

+ (void)histogram:(int *)histogram input:(OCVFloatImage *)image nBins:(int)nBins;
+ (void)histogramEqualization:(OCVFloatImage *)output input:(OCVFloatImage *)input;
+ (void)adaptiveHistogramEqualization:(OCVFloatImage *)output
                                input:(OCVFloatImage *)input
                           nBlockRows:(int)nBlockRows
                           nBlockCols:(int)nBlockCols;

+ (OCVKernel *)allocMorphologicalKernelWithSize:(int)theSize;
+ (void)releaseKernel:(OCVKernel *)kernel;
+ (void)erosion:(OCVFloatImage *)output input:(OCVFloatImage *)input kernel:(OCVKernel *)kernel;
+ (void)dilatation:(OCVFloatImage *)output input:(OCVFloatImage *)input kernel:(OCVKernel *)kernel;

+ (OCVKernel *)allocGaussianKernelWithSize:(int)theSize standardDeviation:(float)theStandardDeviation;
+ (void)convolveInput:(OCVFloatImage *)theInput withKernel:(OCVKernel *)theKernel output:(OCVFloatImage *)theOutput;

@end
