//
//  main.m
//  ObjectiveCV
//
//  Created by Marcelo Cicconet on 10/5/12.
//  Copyright (c) 2012 Marcelo Cicconet. All rights reserved.
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
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Input.jpg"]];
    OCVFloatImage * output = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
    [OCVImageProcessing gradient:output input:input];
    [output normalize];
    [output savePNGToFilePath:@"/Users/Cicconet/Desktop/Output.png"];
    [output release];
    [input release];
}

void histeq(void)
{
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Input.jpg"]];
    OCVFloatImage * output = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
    [OCVImageProcessing histogramEqualization:output input:input];
    [output normalize];
    [output savePNGToFilePath:@"/Users/Cicconet/Desktop/Output.png"];
    [output release];
    [input release];
}

void adapthisteq(void)
{
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Input.jpg"]];
    OCVFloatImage * output = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
    [OCVImageProcessing adaptiveHistogramEqualization:output input:input nBlockRows:2 nBlockCols:2];
    [output normalize];
    [output savePNGToFilePath:@"/Users/Cicconet/Desktop/Output.png"];
    [output release];
    [input release];
}

void morphoper(void)
{
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Input.jpg"]];
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
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Input.jpg"]];
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
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Input.jpg"]];
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
    OCVFloatImage * input = [[OCVFloatImage alloc] initWithImageInFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Input.jpg"]];
    OCVMorletCoefficients * mc = [[OCVMorletCoefficients alloc] initForImageWidth:input.width
                                                                           height:input.height
                                                                            scale:1.0
                                                                    nOrientations:16
                                                                          hopSize:5
                                                                   halfWindowSize:1
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