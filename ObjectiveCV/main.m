//
//  main.m
//  ObjectiveCV
//
//  This code is distributed under the MIT Licence.
//  See notice at the end of this file.
//


#import <Foundation/Foundation.h>
#import "OCVFloatImage.h"
#import "OCVImageProcessing.h"
#import "OCVMorletWavelet.h"
#import "OCVMorletConvolution.h"
#import "OCVMorletCoefficients.h"

void gradient(void);
void histeq(void);
void adapthisteq(void);
void morphoper(void);
void gaussconv(void);
void morletconv(void);
void morletcoef(void);

int main(int argc, const char * argv[])
{

    @autoreleasepool {
//        gradient();
//        histeq();
//        adapthisteq();
//        morphoper();
//        gaussconv();
//        morletconv();
        morletcoef();
    }
    return 0;
}

void gradient(void)
{
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Image.png"]];
    OCVFloatImage * output = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
    [OCVImageProcessing gradient:output input:input];
    [output normalize];
    [output savePNGToFilePath:@"/Users/Cicconet/Desktop/Output.png"];
    [output release];
    [input release];
}

void histeq(void)
{
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Image.png"]];
    OCVFloatImage * output = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
    [OCVImageProcessing histogramEqualization:output input:input];
    [output normalize];
    [output savePNGToFilePath:@"/Users/Cicconet/Desktop/Output.png"];
    [output release];
    [input release];
}

void adapthisteq(void)
{
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Image.png"]];
    OCVFloatImage * output = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
    [OCVImageProcessing adaptiveHistogramEqualization:output input:input nBlockRows:2 nBlockCols:2];
    [output normalize];
    [output savePNGToFilePath:@"/Users/Cicconet/Desktop/Output.png"];
    [output release];
    [input release];
}

void morphoper(void)
{
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Image.png"]];
    OCVFloatImage * output = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
    int size = 5; // should be odd
    OCVKernel * kernel = [OCVImageProcessing allocMorphologicalKernelWithSize:size];
    [OCVImageProcessing erosion:output input:input kernel:kernel];
    [OCVImageProcessing dilatation:output input:input kernel:kernel];
    [output normalize];
    [output savePNGToFilePath:@"/Users/Cicconet/Desktop/Output.png"];
    [OCVImageProcessing releaseKernel:kernel];
    [output release];
    [input release];
}

void gaussconv(void)
{
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Image.png"]];
    OCVFloatImage * output = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
    int size = 21; // should be odd
    OCVKernel * kernel = [OCVImageProcessing allocGaussianKernelWithSize:size standardDeviation:5.0];
    [OCVImageProcessing convolveInput:input withKernel:kernel output:output];
    [OCVImageProcessing releaseKernel:kernel];
    [output normalize];
    [output savePNGToFilePath:@"/Users/Cicconet/Desktop/Output.png"];
    [output release];
    [input release];
}

void morletconv(void)
{
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Image.png"]];
    OCVFloatImage * output = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
    OCVMorletWavelet * kernel = [[OCVMorletWavelet alloc] initWithStretch:1 scale:3 orientation:45 nPeaks:1];
    [kernel prepareToVisualizeKernel:@"imaginary"];
    OCVFloatImage * image = [[OCVFloatImage alloc] initWithData:kernel.kernelV width:kernel.kernelWidth height:kernel.kernelHeight];
    [image savePNGToFilePath:@"/Users/Cicconet/Desktop/KernelI.png"];
    [image release];
    [kernel prepareToVisualizeKernel:@"real"];
    image = [[OCVFloatImage alloc] initWithData:kernel.kernelV width:kernel.kernelWidth height:kernel.kernelHeight];
    [image savePNGToFilePath:@"/Users/Cicconet/Desktop/KernelR.png"];
    [image release];
    OCVMorletConvolution * convolution = [[OCVMorletConvolution alloc] initForImageWidth:input.width height:input.height];
    [convolution convolveInput:input withKernel:kernel output:output];
    [output normalize];
    [output savePNGToFilePath:@"/Users/Cicconet/Desktop/Output.png"];
    [convolution release];
    [kernel release];
    [output release];
    [input release];
}

void morletcoef(void)
{
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Image.png"]];
    OCVMorletCoefficients * mc = [[OCVMorletCoefficients alloc] initForImageWidth:input.width
                                                                           height:input.height
                                                                            scale:1.0
                                                                    nOrientations:16
                                                                          hopSize:11
                                                                   halfWindowSize:5
                                                               magnitudeThreshold:0.01
                                                              dataStructureIsList:YES
                                                              thresholdingIsLocal:NO];
    [mc setInput:input];
    [mc performConvolutions];
    [mc findCoefficients];
    [mc saveOutputsToFilePath:@"/Users/Cicconet/Desktop/Output.png"];
    [mc release];
    [input release];
}

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