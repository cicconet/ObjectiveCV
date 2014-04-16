//
//  OCVMorletConvolution.m
//  ObjectiveCV
//
//  This code is distributed under the MIT Licence.
//  See notice at the end of this file.
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
      ignoreDirection:(BOOL)ignoreDirection
{
    vImage_Buffer vImageBufferInput = [theInput vImageBufferStructure];
    
    if (ignoreDirection) {
        vImageConvolve_PlanarF(&vImageBufferInput, &vImageBufferR, NULL, 0, 0, theKernel.kernelR, theKernel.kernelWidth, theKernel.kernelHeight, 0.0, kvImageBackgroundColorFill);
        vImageConvolve_PlanarF(&vImageBufferInput, &vImageBufferI, NULL, 0, 0, theKernel.kernelI, theKernel.kernelWidth, theKernel.kernelHeight, 0.0, kvImageBackgroundColorFill);
        [OCVImageProcessing complexNormWithRealPart:bufferR imaginaryPart:bufferI output:theOutput];
    } else {
        vImage_Buffer vImageBufferO = [theOutput vImageBufferStructure];
        vImageConvolve_PlanarF(&vImageBufferInput, &vImageBufferO, NULL, 0, 0, theKernel.kernelI, theKernel.kernelWidth, theKernel.kernelHeight, 0.0, kvImageBackgroundColorFill);
    }
    
}

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