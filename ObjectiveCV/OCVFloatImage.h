//
//  OCVImageF.h
//  ObjectiveCV
//
//  Created by Marcelo Cicconet on 10/5/2012.
//  Copyright (c) 2012 Marcelo Cicconet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface OCVFloatImage : NSObject {
    int width;
    int height;
    float * data;
    unsigned char * ucImage;
    CGImageRef cgImageRef;
    CFDataRef data8;
    CGDataProviderRef provider;
}

@property(readonly) int width;
@property(readonly) int height;
@property(readonly, assign) float * data;
@property(readonly) CGImageRef cgImageRef;

- (id)initWithImageInFilePath:(NSString *)theFilePath;
- (id)initWithData:(float *)theData width:(int)theWidth height:(int)theHeight;
- (void)copyDataFromImage:(OCVFloatImage *)floatImage;

- (void)savePNGToFilePath:(NSString *)theFilePath;
- (vImage_Buffer)vImageBufferStructure;
- (void)prepareImageRef;

- (void)printRange;
- (void)getRangeOutMin:(float *)theMin outMax:(float *)theMax;
- (void)getArgMaxOutRow:(int *)theRow outCol:(int *)theCol;

- (void)normalize;
- (void)square;
- (void)setZero;

- (void)paintDotOfHalfSize:(int)theHalfSize
                     atRow:(int)theRow
                       col:(int)theCol
                 grayLevel:(float)theGrayLevel;
- (void)paintHollowDotOfHalfSize:(int)theHalfSize
                           atRow:(int)theRow
                             col:(int)theCol
                     highlighted:(BOOL)isHighlighted
                       grayLevel:(float)theGrayLevel;

@end
