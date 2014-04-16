//
//  OCVMorletWavelet.m
//  ObjectiveCV
//
//  This code is distributed under the MIT Licence.
//  See notice at the end of this file.
//

#import "OCVMorletWavelet.h"

@implementation OCVMorletWavelet

@synthesize kernelWidth, kernelHeight, kernelR, kernelI, kernelV;

- (id)initWithStretch:(int)theStretch
                scale:(float)theScale
          orientation:(float)theOrientation
               nPeaks:(int)theNPeaks
{
    if (self = [super init]) {
        // controls width of gaussian window (default: scale)
        float sigma = theScale;
        
        // orientation (in radians)
        float theta = theOrientation/360.0*2.0*M_PI;
        
        // controls elongation in direction perpendicular to wave
        float gamma = 1.0/(1.0+(float)theStretch);
        
        // width and height of kernel
        int support = 2.5*sigma/gamma;
        kernelWidth = 2*support+1;
        kernelHeight = 2*support+1;
        
        // wavelength (default: 4*sigma)
        float lambda = 1.0/(float)theNPeaks*4.0*sigma;
        
        // phase offset (in radians)
        float psi = 0.0;
        
        kernelR = (float *)malloc(kernelWidth*kernelHeight*sizeof(float));
        kernelI = (float *)malloc(kernelWidth*kernelHeight*sizeof(float));
        
        float sumReal = 0.0;
        float sumImag = 0.0;
        for (int x = -support; x <= support; x++) {
            for (int y = -support; y <= support; y++) {
                float xprime = cosf(theta)*x+sinf(theta)*y;
                float yprime = -sinf(theta)*x+cosf(theta)*y;
                float expfactor = expf(-0.5/(sigma*sigma)*(xprime*xprime+gamma*gamma*yprime*yprime));
                float mr = expfactor*cosf(2.0*M_PI/lambda*xprime+psi);
                float mi = -expfactor*sinf(2.0*M_PI/lambda*xprime+psi);
                int row = support+x;
                int col = support+y;
                int index = row*kernelWidth+col;
                kernelR[index] = mr;
                kernelI[index] = mi;
                sumReal += mr;
                sumImag += mi;
            }
        }
        
        // make mean = 0
        float offsetReal = sumReal/(kernelWidth*kernelHeight);
        float offsetImag = sumImag/(kernelWidth*kernelHeight);
        sumReal = 0.0;
        sumReal = 0.0;
        for (int i = 0; i < kernelHeight; i++) {
            for (int j = 0; j < kernelWidth; j++) {
                int index = i*kernelWidth+j;
                kernelR[index] -= offsetReal;
                kernelI[index] -= offsetImag;
                sumReal += (kernelR[index]*kernelR[index]);
                sumImag += (kernelI[index]*kernelI[index]);
            }
        }
        
        // make norm = 1
        float denReal = sqrtf(sumReal);
        float denImag = sqrtf(sumImag);
        for (int i = 0; i < kernelHeight; i++) {
            for (int j = 0; j < kernelWidth; j++) {
                int index = i*kernelWidth+j;
                kernelR[index] /= denReal;
                kernelI[index] /= denImag;
            }
        }
    }
    return self;
}

- (void)prepareToVisualizeKernel:(NSString *)theKernelName
{
    if (!kernelV) {
        kernelV = (float *)malloc(kernelWidth*kernelHeight*sizeof(float));
    }
    
    float min = INFINITY;
    float max = -INFINITY;
    
    float * kernel;
    
    if ([theKernelName isEqualToString:@"real"]) {
        kernel = kernelR;
    } else if ([theKernelName isEqualToString:@"imaginary"]) {
        kernel = kernelI;
    }
    for (int i = 0; i < kernelWidth*kernelHeight; i++) {
        if (kernel[i] < min) min = kernel[i];
        if (kernel[i] > max) max = kernel[i];
    }
    for (int i = 0; i < kernelWidth*kernelHeight; i++) {
        kernelV[i] = (kernel[i]-min)/(max-min);
    }
}

-(void)dealloc
{
    free(kernelR);
    free(kernelI);
    if (kernelV) {
        free(kernelV);
    }
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