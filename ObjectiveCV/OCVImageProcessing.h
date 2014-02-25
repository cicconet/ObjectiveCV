//
//  OCVImageProcessing.h
//  ObjectiveCV
//
//  This code is distributed under the MIT Licence.
//  See notice at the end of this file.
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
