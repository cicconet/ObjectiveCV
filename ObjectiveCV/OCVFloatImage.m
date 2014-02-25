//
//  OCVFloatImage.m
//  ObjectiveCV
//
//  This code is distributed under the MIT Licence.
//  See notice at the end of this file.
//

#import "OCVFloatImage.h"

@implementation OCVFloatImage

@synthesize width, height, data, cgImageRef;

// ----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Initialization
// ----------------------------------------------------------------------------------------------------

- (id)initWithImageInFilePath:(NSString *)theFilePath
{
    if (self = [super init]) {
        NSURL * url = [NSURL fileURLWithPath:theFilePath];

        CGImageSourceRef image_source = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
        CGImageRef image = CGImageSourceCreateImageAtIndex(image_source, 0, NULL);
        CFRelease(image_source);
        
        width = (int)CGImageGetWidth(image);
        height = (int)CGImageGetHeight(image);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        unsigned char * rawData = (unsigned char *)malloc(width*height*sizeof(unsigned char));
        NSUInteger bytesPerPixel = 1;
        NSUInteger bytesPerRow = bytesPerPixel*width;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                     bitsPerComponent, bytesPerRow, colorSpace,
                                                     kCGBitmapByteOrderDefault);
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
        
        data = (float *)calloc(width*height, sizeof(float));
        
        for (int i = 0; i < width*height; i++) {
            data[i] = (float)rawData[i]/255.0;
        }
        
        CGContextRelease(context);
        free(rawData);
    }
    return self;
}

- (id)initWithData:(float *)theData width:(int)theWidth height:(int)theHeight
{
    if (self = [super init]) {
        width = theWidth;
        height = theHeight;
        data = (float *)calloc(width*height, sizeof(float));
        if (theData) {
            memcpy(data, theData, width*height*sizeof(float));
        }
    }
    return self;
}

- (void)copyDataFromImage:(OCVFloatImage *)floatImage
{
    // images should be of same size
    memcpy(data, floatImage.data, width*height*sizeof(float));
}

// ----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Info
// ----------------------------------------------------------------------------------------------------

- (void)printRange
{
    float min = INFINITY;
    float max = -INFINITY;
    for (int i = 0; i < width*height; i++) {
        float v = data[i];
        if (v < min) {
            min = v;
        }
        if (v > max) {
            max = v;
        }
    }
    printf("min: %f, max: %f\n", min, max);
}

- (void)getRangeOutMin:(float *)theMin outMax:(float *)theMax
{
    float min = INFINITY;
    float max = -INFINITY;
    for (int i = 0; i < width*height; i++) {
        float v = data[i];
        if (v < min) min = v;
        if (v > max) max = v;
    }
    *theMin = min;
    *theMax = max;
}

- (void)getArgMaxOutRow:(int *)theRow outCol:(int *)theCol
{
    int row = 0;
    int col = 0;
    float max = -INFINITY;
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            float v = data[i*width+j];
            if (v > max) {
                max = v;
                row = i;
                col = j;
            }
        }
    }
    *theRow = row;
    *theCol = col;
}

// ----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Operations
// ----------------------------------------------------------------------------------------------------

- (void)normalize
{
    float min, max;
    [self getRangeOutMin:&min outMax:&max];
    float range = max-min;
    if (range > 0) {
        for (int i = 0; i < width*height; i++) {
            data[i] = (data[i]-min)/range;
        }
    } else {
        for (int i = 0; i < width*height; i++) {
            data[i] -= min;
        }
    }
}

- (void)square
{
    for (int i = 0; i < width*height; i++) {
        data[i] = data[i]*data[i];
    }
}

- (void)setZero
{
    for (int i = 0; i < width*height; i++) {
        data[i] = 0.0;
    }
}

// ----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IO
// ----------------------------------------------------------------------------------------------------

- (vImage_Buffer)vImageBufferStructure
{
    vImage_Buffer bf;
    bf.data = self.data;
    bf.height = self.height;
    bf.width = self.width;
    bf.rowBytes = self.width*sizeof(float);
    return bf;
}

- (void)prepareImageRef
{
    if (cgImageRef) {
        CGImageRelease(cgImageRef);
        CGDataProviderRelease(provider);
        CFRelease(data8);
        free(ucImage);
    }
    ucImage = (unsigned char *)malloc(width*height*sizeof(unsigned char));
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            ucImage[i*width+j] = 255*data[i*width+j];
        }
    }
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    data8 = CFDataCreate(NULL, ucImage, width*height);
    provider = CGDataProviderCreateWithCFData(data8);
    cgImageRef = CGImageCreate(width, height, 8, 8, width, colorspace, kCGBitmapByteOrderDefault, provider, NULL, true, kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorspace);
}

- (void)savePNGToFilePath:(NSString *)theFilePath
{
    [self prepareImageRef];
    
    NSURL * urlOut = [NSURL fileURLWithPath:theFilePath];
    CGImageDestinationRef myImageDest = CGImageDestinationCreateWithURL((CFURLRef)urlOut, (CFStringRef)@"public.png", 1, NULL);
    CGImageDestinationAddImage(myImageDest, cgImageRef, NULL);
    CGImageDestinationFinalize(myImageDest);
    CFRelease(myImageDest);
}

// ----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Drawing
// ----------------------------------------------------------------------------------------------------

- (void)paintDotOfHalfSize:(int)theHalfSize
                     atRow:(int)theRow
                       col:(int)theCol
                 grayLevel:(float)theGrayLevel
{
    int row = theRow;
    int col = theCol;
    if (row < theHalfSize) row = theHalfSize;
    if (row > height-(theHalfSize+1)) row = height-(theHalfSize+1);
    if (col < theHalfSize) col = theHalfSize;
    if (col > width-(theHalfSize+1)) col = width-(theHalfSize+1);
    for (int i = -theHalfSize; i < theHalfSize; i++) {
        for (int j = -theHalfSize; j < theHalfSize; j++) {
            int r = row+i;
            int c = col+j;
            data[r*width+c] = theGrayLevel;
        }
    }
}

- (void)paintHollowDotOfHalfSize:(int)theHalfSize
                           atRow:(int)theRow
                             col:(int)theCol
                     highlighted:(BOOL)isHighlighted
                       grayLevel:(float)theGrayLevel
{
    int row = theRow;
    int col = theCol;
    if (row < theHalfSize) row = theHalfSize;
    if (row > height-(theHalfSize+1)) row = height-(theHalfSize+1);
    if (col < theHalfSize) col = theHalfSize;
    if (col > width-(theHalfSize+1)) col = width-(theHalfSize+1);
    for (int i = -theHalfSize; i < theHalfSize; i++) {
        int j = -theHalfSize;
        int r = row+i;
        int c = col+j;
        data[r*width+c] = theGrayLevel;
        j = theHalfSize-1;
        r = row+i;
        c = col+j;
        data[r*width+c] = theGrayLevel;
    }
    for (int j = -theHalfSize; j < theHalfSize; j++) {
        int i = -theHalfSize;
        int r = row+i;
        int c = col+j;
        data[r*width+c] = theGrayLevel;
        i = theHalfSize-1;
        r = row+i;
        c = col+j;
        data[r*width+c] = theGrayLevel;
    }
    if (isHighlighted && theHalfSize > 3) {
        [self paintDotOfHalfSize:2 atRow:theRow col:theCol grayLevel:theGrayLevel];
    }
}

// ----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Clean Up
// ----------------------------------------------------------------------------------------------------

-(void)dealloc
{
    if (cgImageRef) {
        CGImageRelease(cgImageRef);
        CGDataProviderRelease(provider);
        CFRelease(data8);
        free(ucImage);
    }
    free(data);
    [super dealloc];
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