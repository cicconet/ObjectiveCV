//
//  OCVMorletWavelet.h
//  ObjectiveCV
//
//  Created by Marcelo Cicconet on 5/28/13.
//  Copyright (c) 2013 Marcelo Cicconet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCVMorletWavelet : NSObject {
    int kernelWidth;
    int kernelHeight;
    float * kernelR;
    float * kernelI;
    float * kernelV;
}

@property(readonly) int kernelWidth;
@property(readonly) int kernelHeight;
@property(readonly, assign) float * kernelR;
@property(readonly, assign) float * kernelI;
@property(readonly, assign) float * kernelV;

- (id)initWithStretch:(int)theStretch
                scale:(float)theScale
          orientation:(float)theOrientation
               nPeaks:(int)theNPeaks;
- (void)prepareToVisualizeKernel:(NSString *)theKernelName;

@end
