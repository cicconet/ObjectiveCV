//
//  OCVMorletConvolution.m
//  ObjectiveCV
//
//  Created by Marcelo Cicconet on 6/7/13.
//  Copyright (c) 2013 Marcelo Cicconet. All rights reserved.
//

#import "OCVMorletConvolution.h"

@implementation OCVMorletConvolution

- (id)initForImageWidth:(int)theWidth height:(int)theHeight
{
    if (self = [super init]) {
        width = theWidth;
        height = theHeight;
        bufferR = [[OCVFloatImage alloc] initWithData:NULL width:width height:height];
        bufferI = [[OCVFloatImage alloc] initWithData:NULL width:width height:height];
        vImageBufferR = [bufferR vImageBufferStructure];
        vImageBufferI = [bufferI vImageBufferStructure];
    }
    return self;
}

- (void)dealloc
{
    [bufferR release];
    [bufferI release];
    [super dealloc];
}

- (void)convolveInput:(OCVFloatImage *)theInput
           withKernel:(OCVMorletWavelet *)theKernel
               output:(OCVFloatImage *)theOutput
{
    vImage_Buffer vImageBufferInput = [theInput vImageBufferStructure];
    
    vImageConvolve_PlanarF(&vImageBufferInput, &vImageBufferR, NULL, 0, 0, theKernel.kernelR, theKernel.kernelWidth, theKernel.kernelHeight, 0.0, kvImageBackgroundColorFill);
    vImageConvolve_PlanarF(&vImageBufferInput, &vImageBufferI, NULL, 0, 0, theKernel.kernelI, theKernel.kernelWidth, theKernel.kernelHeight, 0.0, kvImageBackgroundColorFill);
    
    [OCVImageProcessing complexNormWithRealPart:bufferR imaginaryPart:bufferI output:theOutput];
    [theOutput normalize];
}

@end
