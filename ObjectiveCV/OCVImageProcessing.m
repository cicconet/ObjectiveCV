//
//  OCVImageProcessing.m
//  ObjectiveCV
//
//  Created by Marcelo Cicconet on 10/5/12.
//  Copyright (c) 2012 Marcelo Cicconet. All rights reserved.
//

#import "OCVImageProcessing.h"

@implementation OCVImageProcessing

+ (void)thresholdInput:(OCVFloatImage *)theInput lowerBound:(float)theLowerBound upperBound:(float)theUpperBound
{
    int nRows = theInput.height;
    int nCols = theInput.width;
    int index;
    for (int i = 0; i < nRows; i++) {
        for (int j = 0; j < nCols; j++) {
            index = i*nCols+j;
            theInput.data[index] = (theInput.data[index] > theUpperBound ? theUpperBound : theInput.data[index]);
            theInput.data[index] = (theInput.data[index] < theLowerBound ? theLowerBound : theInput.data[index]);
        }
    }
}

+ (void)gradient:(OCVFloatImage *)output input:(OCVFloatImage *)input
{
    int nRows = input.height;
    int nCols = input.width;
    for (int i = 1; i < nRows; i++) {
        for (int j = 1; j < nCols; j++) {
            float dx = input.data[i*nCols+j]-input.data[(i-1)*nCols+j];
            float dy = input.data[i*nCols+j]-input.data[i*nCols+(j-1)];
            output.data[i*nCols+j] = sqrtf(dx*dx+dy*dy);
        }
    }
    for (int i = 1; i < nRows; i++) {
        output.data[i*nCols] = output.data[i*nCols+1];
    }
    for (int j = 0; j < nCols; j++) {
        output.data[j] = output.data[nCols+j];
    }
}

+ (void)complexNormWithRealPart:(OCVFloatImage *)realImage imaginaryPart:(OCVFloatImage *)imaginaryImage output:(OCVFloatImage *)outputImage
{
    vDSP_vdist(realImage.data, 1, imaginaryImage.data, 1, outputImage.data, 1, outputImage.width*outputImage.height);
}

// ----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Histogram Operations
// ----------------------------------------------------------------------------------------------------

+ (void)histogram:(int *)histogram input:(OCVFloatImage *)image nBins:(int)nBins
{
    vImage_Buffer imIn = [image vImageBufferStructure];
    vImagePixelCount * pixelCount = (vImagePixelCount *)malloc(nBins*sizeof(vImagePixelCount));
    float min, max;
    [image getRangeOutMin:&min outMax:&max];
    vImageHistogramCalculation_PlanarF(&imIn, pixelCount, nBins, min, max, kvImageNoFlags);
    for (int i = 0; i < nBins; i++) {
        histogram[i] = (int)pixelCount[i];
    }
    free(pixelCount);
}

+ (void)histogramEqualization:(OCVFloatImage *)output input:(OCVFloatImage *)input;
{
    vImage_Buffer imIn = [input vImageBufferStructure];
    vImage_Buffer imOut = [output vImageBufferStructure];
    float min, max;
    [input getRangeOutMin:&min outMax:&max];
    vImageEqualization_PlanarF(&imIn, &imOut, NULL, 256, min, max, kvImageNoFlags);
}

+ (void)adaptiveHistogramEqualization:(OCVFloatImage *)output
                                input:(OCVFloatImage *)input
                           nBlockRows:(int)nBlockRows
                           nBlockCols:(int)nBlockCols
{
    int nbRows = nBlockRows;
    int nbCols = nBlockCols;
    
    int rowStep = input.height/nbRows;
    int colStep = input.width/nbCols;
    
    int * histogram = (int *)malloc(256*sizeof(int));
    int * chistogram = (int *)malloc(256*sizeof(int));
    int * blockRowCenters = (int *)malloc(nbRows*sizeof(int));
    int * blockColCenters = (int *)malloc(nbCols*sizeof(int));
    float ** mappings = (float **)malloc(nbRows*nbCols*sizeof(float *));
    for (int i = 0; i < nbRows*nbCols; i++) {
        mappings[i] = (float *)malloc(256*sizeof(float));
    }
    
    for (int i = 0; i < nbRows; i++) {
        for (int j = 0; j < nbCols; j++) {
            OCVFloatImage * subImage = [[OCVFloatImage alloc] initWithData:NULL width:colStep height:rowStep];
            
            int ii0 = i*rowStep;
            int jj0 = j*colStep;
            
            for (int ii = 0; ii < rowStep; ii++) {
                for (int jj = 0; jj < colStep; jj++) {
                    subImage.data[ii*colStep+jj] = input.data[(ii0+ii)*input.width+(jj0+jj)];
                }
            }
            
            [OCVImageProcessing histogram:histogram input:subImage nBins:256];

            chistogram[0] = histogram[0];
            for (int k = 1; k < 256; k++) {
                chistogram[k] = chistogram[k-1]+histogram[k];
            }

            int n = chistogram[255];
            int p0 = n/200; // 0.5%
            int p1 = chistogram[255]-p0;
            int k0 = 0, k1 = 255;
            for (int k = 0; k < 255; k++) {
                if (chistogram[k] > p0) {
                    k0 = k;
                    break;
                }
            }
            for (int k = 255; k >= 0; k--) {
                if (chistogram[k] < p1) {
                    k1 = k;
                    break;
                }
            }

            int index = i*nbCols+j;
            for (int k = 0; k < 256; k++) {
                if (k < k0) {
                    mappings[index][k] = 0.0;
                } else if (k > k1) {
                    mappings[index][k] = 1.0;
                } else {
                    mappings[index][k] = (float)(k-k0)/(float)(k1-k0);
                }
            }
            blockRowCenters[i] = ii0+rowStep/2;
            blockColCenters[j] = jj0+colStep/2;
            
            [subImage release];
        }
    }
    
    float * weights = (float *)malloc(nbRows*nbCols*sizeof(float));
    float f = 1.0;
    float stdev = f*(float)rowStep;
    if (colStep > rowStep) {
        stdev = f*(float)colStep;
    }
    for (int i = 0; i < input.height; i++) {
        for (int j = 0; j < input.width; j++) {
            float s = 0.0;
            for (int ii = 0; ii < nbRows; ii++) {
                for (int jj = 0; jj < nbCols; jj++) {
                    float d2 = powf(i-blockRowCenters[ii], 2.0)+powf(j-blockColCenters[jj], 2.0);
                    weights[ii*nbCols+jj] = expf(-0.5*d2/(stdev*stdev));
                    s += weights[ii*nbCols+jj];
                }
            }
            for (int k = 0; k < nbRows*nbCols; k++) {
                weights[k] = weights[k]/s;
            }
            float m = 0.0;
            for (int k = 0; k < nbRows*nbCols; k++) {
                m += weights[k]*mappings[k][(int)(input.data[i*input.width+j]*255.0)];
            }
            output.data[i*output.width+j] = m;
        }
    }
    free(weights);
    
    free(blockRowCenters);
    free(blockColCenters);
    for (int i = 0; i < nbRows*nbCols; i++) {
        free(mappings[i]);
    }
    free(histogram);
    free(chistogram);
    free(mappings);
}

// ----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Morphological Operations
// ----------------------------------------------------------------------------------------------------

+ (OCVKernel *)allocMorphologicalKernelWithSize:(int)theSize
{
    // WARNING: theSize should be odd
    OCVKernel * kernel = (OCVKernel *)malloc(sizeof(OCVKernel));
    kernel->size = theSize;
    kernel->data = (float *)malloc(theSize*theSize*sizeof(float));
    for (int i = 0; i < theSize*theSize; i++) {
        kernel->data[i] = 1.0;
    }
    return kernel;
}

+ (void)releaseKernel:(OCVKernel *)kernel
{
    free(kernel->data);
    free(kernel);
}

+ (void)erosion:(OCVFloatImage *)output input:(OCVFloatImage *)input kernel:(OCVKernel *)kernel
{
    vImage_Buffer imIn = [input vImageBufferStructure];
    vImage_Buffer imOut = [output vImageBufferStructure];
    vImageErode_PlanarF(&imIn, &imOut, 0, 0, kernel->data, kernel->size, kernel->size, kvImageNoFlags);
}

+ (void)dilatation:(OCVFloatImage *)output input:(OCVFloatImage *)input kernel:(OCVKernel *)kernel
{
    vImage_Buffer imIn = [input vImageBufferStructure];
    vImage_Buffer imOut = [output vImageBufferStructure];
    vImageDilate_PlanarF(&imIn, &imOut, 0, 0, kernel->data, kernel->size, kernel->size, kvImageNoFlags);
}

// ----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Gaussian Convolution
// ----------------------------------------------------------------------------------------------------

+ (OCVKernel *)allocGaussianKernelWithSize:(int)theSize standardDeviation:(float)theStandardDeviation
{
    // WARNING: theSize should be odd
    OCVKernel * kernel = (OCVKernel *)malloc(sizeof(OCVKernel));
    kernel->size = theSize;
    kernel->data = (float *)malloc(theSize*theSize*sizeof(float));
    
    int i0 = theSize/2;
    int j0 = i0;
    float variance = theStandardDeviation*theStandardDeviation;
    float sum = 0.0;
    for (int i = 0; i < theSize; i++) {
        for (int j = 0; j < theSize; j++) {
            float xdist = i-i0;
            float ydist = j-j0;
            float value = expf(-0.5*(xdist*xdist+ydist*ydist)/variance);
            kernel->data[i*theSize+j] = value;
            sum += value;
        }
    }
    for (int i = 0; i < theSize; i++) {
        for (int j = 0; j < theSize; j++) {
            kernel->data[i*theSize+j] /= sum;
        }
    }
    
    OCVFloatImage * image = [[OCVFloatImage alloc] initWithData:kernel->data width:theSize height:theSize];
    [image normalize];
    [image savePNGToFilePath:@"/Users/Cicconet/Desktop/Kernel.png"];
    
    return kernel;
}

+ (void)convolveInput:(OCVFloatImage *)theInput withKernel:(OCVKernel *)theKernel output:(OCVFloatImage *)theOutput
{
    vImage_Buffer vImageBufferInput = [theInput vImageBufferStructure];
    vImage_Buffer vImageBufferOutput = [theOutput vImageBufferStructure];
    
    vImageConvolve_PlanarF(&vImageBufferInput, &vImageBufferOutput, NULL, 0, 0, theKernel->data, theKernel->size, theKernel->size, 0.0, kvImageBackgroundColorFill);
    
    [theOutput normalize];
}

@end
