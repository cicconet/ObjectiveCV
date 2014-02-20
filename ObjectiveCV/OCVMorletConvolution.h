//
//  OCVMorletConvolution.h
//  ObjectiveCV
//
//  Created by Marcelo Cicconet on 6/7/13.
//  Copyright (c) 2013 Marcelo Cicconet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "OCVMorletWavelet.h"
#import "OCVFloatImage.h"
#import "OCVImageProcessing.h"

@interface OCVMorletConvolution : NSObject {
    int width;
    int height;
    OCVFloatImage * bufferR;
    OCVFloatImage * bufferI;
    vImage_Buffer vImageBufferR;
    vImage_Buffer vImageBufferI;
}

- (id)initForImageWidth:(int)theWidth height:(int)theHeight;
- (void)convolveInput:(OCVFloatImage *)theInput
           withKernel:(OCVMorletWavelet *)theKernel
               output:(OCVFloatImage *)theOutput;

@end
