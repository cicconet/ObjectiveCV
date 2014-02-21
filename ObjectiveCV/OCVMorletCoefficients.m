//
//  OCVMorletCoefficients.m
//  ObjectiveCV
//
//  Created by Marcelo Cicconet on 7/23/13.
//  Copyright (c) 2013 Marcelo Cicconet. All rights reserved.
//

#import "OCVMorletCoefficients.h"

float collinearity(NSPoint p, NSPoint tauP, NSPoint q, NSPoint tauQ);

@implementation OCVMorletCoefficients

@synthesize M, A, IX0, IY0;

- (id)initForImageWidth:(int)theWidth
                 height:(int)theHeight
                  scale:(float)theScale
          nOrientations:(int)theNOrientations
                hopSize:(int)theHopSize
         halfWindowSize:(int)theHalfWindowSize
     magnitudeThreshold:(float)theMagnitudeThreshold
    dataStructureIsList:(BOOL)theDataStructureIsList
    thresholdingIsLocal:(BOOL)theThresholdingIsLocal
{
    if (self = [super init]) {
        magnitudeThreshold = theMagnitudeThreshold;
        nOrientations = theNOrientations;
        kernels = (OCVMorletWavelet **)malloc(nOrientations*sizeof(OCVMorletWavelet *));
        for (int i = 0; i < nOrientations; i++) {
            float orientation = (float)i*180.0/(float)nOrientations;
            kernels[i] = [[OCVMorletWavelet alloc] initWithStretch:1 scale:theScale orientation:orientation nPeaks:1];
//            if (i == 0) {
//                [kernels[i] prepareToVisualizeKernel:@"real"];
//                OCVFloatImage * image = [[OCVFloatImage alloc] initWithData:kernels[i].kernelV
//                                                                      width:kernels[i].kernelWidth
//                                                                     height:kernels[i].kernelHeight];
//                [image savePNGToFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Kernel%d.png",i]];
//                [image release];
//            }
        }
        convolution = [[OCVMorletConvolution alloc] initForImageWidth:theWidth height:theHeight];
        input = [[OCVFloatImage alloc] initWithData:NULL width:theWidth height:theHeight];
        outputs = (OCVFloatImage **)malloc(nOrientations*sizeof(OCVFloatImage *));
        for (int i = 0; i < nOrientations; i++) {
            outputs[i] = [[OCVFloatImage alloc] initWithData:NULL width:theWidth height:theHeight];
        }
        
        halfWindowSize = theHalfWindowSize;
        nSelectedRows = floorf((input.height-2*halfWindowSize)/(float)theHopSize)+1;
        nSelectedCols = floorf((input.width-2*halfWindowSize)/(float)theHopSize)+1;
        selectedRows = (int *)malloc(nSelectedRows*sizeof(int));
        selectedCols = (int *)malloc(nSelectedCols*sizeof(int));
        
        float firstRow = halfWindowSize;
        float lastRow = input.height-1-halfWindowSize;
        float firstCol = firstRow;
        float lastCol = input.width-1-halfWindowSize;
        float rowStep = (lastRow-firstRow)/(float)(nSelectedRows-1);
        float colStep = (lastCol-firstCol)/(float)(nSelectedCols-1);
        for (int i = 0; i < nSelectedRows; i++) {
            selectedRows[i] = roundf(firstRow+i*rowStep);
        }
        for (int j = 0; j < nSelectedCols; j++) {
            selectedCols[j] = roundf(firstCol+j*colStep);
        }
        
        dataStructureIsList = theDataStructureIsList;
        thresholdingIsLocal = theThresholdingIsLocal;
        
        // matrix data structure
        M = [[OCVFloatImage alloc] initWithData:NULL width:nSelectedCols height:nSelectedRows];
        N = [[OCVFloatImage alloc] initWithData:NULL width:nSelectedCols height:nSelectedRows];
        A = [[OCVFloatImage alloc] initWithData:NULL width:nSelectedCols height:nSelectedRows];
        X = [[OCVFloatImage alloc] initWithData:NULL width:nSelectedCols height:nSelectedRows];
        Y = [[OCVFloatImage alloc] initWithData:NULL width:nSelectedCols height:nSelectedRows];
        IX = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
        IY = [[OCVFloatImage alloc] initWithData:NULL width:input.width height:input.height];
        rowsL = (int *)malloc(nSelectedRows*sizeof(int));
        rowsR = (int *)malloc(nSelectedRows*sizeof(int));
        colsU = (int *)malloc(nSelectedCols*sizeof(int));
        colsB = (int *)malloc(nSelectedCols*sizeof(int));
        for (int i = 1; i < nSelectedRows-1; i++) {
            rowsL[i] = ceilf(0.5*((float)selectedRows[i-1]+(float)selectedRows[i]));
            rowsR[i] = ceilf(0.5*((float)selectedRows[i]+(float)selectedRows[i+1]))-1;
        }
        rowsL[0] = 0;
        rowsR[0] = ceilf(0.5*((float)selectedRows[0]+(float)selectedRows[1]))-1;
        rowsL[nSelectedRows-1] = ceilf(0.5*((float)selectedRows[nSelectedRows-2]+(float)selectedRows[nSelectedRows-1]));
        rowsR[nSelectedRows-1] = input.height-1;
        for (int i = 1; i < nSelectedCols-1; i++) {
            colsU[i] = ceilf(0.5*((float)selectedCols[i-1]+(float)selectedCols[i]));
            colsB[i] = ceilf(0.5*((float)selectedCols[i]+(float)selectedCols[i+1]))-1;
        }
        colsU[0] = 0;
        colsB[0] = ceilf(0.5*((float)selectedCols[0]+(float)selectedCols[1]))-1;
        colsU[nSelectedCols-1] = ceilf(0.5*((float)selectedCols[nSelectedCols-2]+(float)selectedCols[nSelectedCols-1]));
        colsB[nSelectedCols-1] = input.width-1;
        
        if (dataStructureIsList) {
            int maxNCoefficients = nSelectedRows*nSelectedCols;
            m = (float *)malloc(maxNCoefficients*sizeof(float));
            a = (float *)malloc(maxNCoefficients*sizeof(float));
            x = (float *)malloc(maxNCoefficients*sizeof(float));
            y = (float *)malloc(maxNCoefficients*sizeof(float));
            indices = (int *)malloc(maxNCoefficients*sizeof(int));
        }
    }
    return self;
}

- (void)dealloc
{
    if (dataStructureIsList) {
        free(indices);
        free(m);
        free(a);
        free(x);
        free(y);
    }
    
    [M release];
    [N release];
    [A release];
    [X release];
    [Y release];
    [IX release];
    [IY release];
    free(rowsL);
    free(rowsR);
    free(colsU);
    free(colsB);
    
    free(selectedRows);
    free(selectedCols);
    [input release];
    for (int i = 0; i < nOrientations; i++) {
        [outputs[i] release];
    }
    free(outputs);
    for (int i = 0; i < nOrientations; i++) {
        [kernels[i] release];
    }
    free(kernels);
    [super dealloc];
}

- (void)setInput:(OCVFloatImage *)theInput
{
    [input copyDataFromImage:theInput];
}

- (void)performConvolutions
{
    for (int i = 0; i < nOrientations; i++) {
        [convolution convolveInput:input withKernel:kernels[i] output:outputs[i]];
//        for (int j = 0; j < 10; j++) {
//            float factor = (float)j/10.0;
//            int row = j;
//            for (int col = 0; col < input.width; col++) {
//                outputs[i].data[row*input.width+col] *= factor;
//            }
//            row = input.height-1-j;
//            for (int col = 0; col < input.width; col++) {
//                outputs[i].data[row*input.width+col] *= factor;
//            }
//            int col = j;
//            for (int row = 0; row < input.height; row++) {
//                outputs[i].data[row*input.width+col] *= factor;
//            }
//            col = input.width-1-j;
//            for (int row = 0; row < input.height; row++) {
//                outputs[i].data[row*input.width+col] *= factor;
//            }
//        }
//        [outputs[i] normalize];
//        [outputs[i] savePNGToFilePath:[NSString stringWithFormat:@"/Users/Cicconet/Desktop/Output%d.png",i]];
//        NSLog(@"Performed convolution %d", i);
    }
}

- (void)findCoefficients
{
    int index;
    float magnitude;
    int nCols = input.width;
    float globalMaxMag = -INFINITY;
    for (int i = 0; i < nSelectedRows; i++) {
        for (int j = 0; j < nSelectedCols; j++) {
            int row1 = selectedRows[i]-halfWindowSize;
            int row2 = selectedRows[i]+halfWindowSize;
            int col1 = selectedCols[j]-halfWindowSize;
            int col2 = selectedCols[j]+halfWindowSize;
            float blockMaxMag = -INFINITY;
            int maxK, maxRow, maxCol;
            for (int row = row1; row <= row2; row++) {
                for (int col = col1; col <= col2; col++) {
                    for (int k = 0; k < nOrientations; k++) {
                        magnitude = outputs[k].data[row*nCols+col];
                        if (magnitude > blockMaxMag) {
                            blockMaxMag = magnitude;
                            maxK = k;
                            maxRow = row;
                            maxCol = col;
                        }
                    }
                }
            }
            index = i*nSelectedCols+j;
            M.data[index] = blockMaxMag;
            A.data[index] = maxK*M_PI/(float)nOrientations+M_PI_2;
            X.data[index] = maxRow; // X0: selectedRows[i];
            Y.data[index] = maxCol; // Y0: selectedCols[j];
            if (blockMaxMag > globalMaxMag) globalMaxMag = blockMaxMag;
            for (int row = rowsL[i]; row <= rowsR[i]; row++) {
                for (int col = colsU[j]; col <= colsB[j]; col++) {
                    IX.data[row*nCols+col] = i;
                    IY.data[row*nCols+col] = j;
                }
            }
        }
    }
    if (thresholdingIsLocal) {
        [N setZero];
        float value;
        float threshold = magnitudeThreshold*globalMaxMag;
        for (int i = 1; i < nSelectedRows-1; i++) {
            for (int j = 1; j < nSelectedCols-1; j++) {
                float locMax = -INFINITY;
                float locMin = INFINITY;
                for (int ii = -1; ii < 2; ii++) {
                    for (int jj = -1; jj < 2; jj++) {
                        value = M.data[(i+ii)*nSelectedCols+(j+jj)];
                        if (value > locMax) locMax = value;
                        if (value < locMin) locMin = value;
                    }
                }
                int entryIndex = i*nSelectedCols+j;
                value = M.data[entryIndex];
                if (value > 0.75*locMax && locMin > threshold) {
                    N.data[entryIndex] = value;
                }
            }
        }
        [M copyDataFromImage:N];
        for (int i = 1; i < nSelectedRows-1; i++) {
            for (int j = 1; j < nSelectedCols-1; j++) {
                int entryIndex = i*nSelectedCols+j;
                float mP = M.data[entryIndex];
                if (mP > 0) {
                    NSPoint p = NSMakePoint(X.data[entryIndex], Y.data[entryIndex]);
                    NSPoint tauP = NSMakePoint(cosf(A.data[entryIndex]), sinf(A.data[entryIndex]));
                    for (int ii = -1; ii < 2; ii++) {
                        for (int jj = -1; jj < 2; jj++) {
                            entryIndex = (i+ii)*nSelectedCols+(j+jj);
                            float mQ = M.data[entryIndex];
                            if (ii != 0 && jj != 0 && mQ > 0) {
                                NSPoint q = NSMakePoint(X.data[entryIndex], Y.data[entryIndex]);
                                NSPoint tauQ = NSMakePoint(cosf(A.data[entryIndex]), sinf(A.data[entryIndex]));
                                if (collinearity(p, tauP, q, tauQ) < 0.9 && mQ < mP) { // not collinear
                                    M.data[entryIndex] = 0;
                                }
                            }
                        }
                    }
                }
            }
        }
        for (int i = 1; i < nSelectedRows-1; i++) {
            for (int j = 1; j < nSelectedCols-1; j++) {
                M.data[i*nSelectedCols+j] = (M.data[i*nSelectedCols+j] > 0 ? 1.0 : 0.0);
            }
        }
     }
    if (dataStructureIsList) {
        int memsize = (index+1)*sizeof(float);
        memcpy(m, M.data, memsize);
        memcpy(a, A.data, memsize);
        memcpy(x, X.data, memsize);
        memcpy(y, Y.data, memsize);
        
        nCoefficients = 0;
        float threshold = magnitudeThreshold*globalMaxMag;
        for (int i = 0; i < index; i++) {
            if (m[i] > threshold) {
                indices[nCoefficients] = i;
                nCoefficients += 1;
            }
        }
        
        // permutate coefficient indices
        srand((unsigned)time(NULL));
        for (int i = nCoefficients; i > 0; i--) {
            int randIndex = rand() % i; // rand number in {0,...,i-1}
            int memIndex = indices[i-1];
            indices[i-1] = indices[randIndex];
            indices[randIndex] = memIndex;
        }
    }
}

- (void)saveOutputsToFilePath:(NSString *)theFilePath
{
    if (dataStructureIsList) {
        int factor = 2;
        OCVFloatImage * image = [[OCVFloatImage alloc] initWithData:NULL width:factor*input.width height:factor*input.height];
        for (int i = 0; i < nCoefficients; i++) {
            int row0 = factor*x[indices[i]];
            int col0 = factor*y[indices[i]];
            for (int j = -factor; j < factor; j++) {
                int row = row0+roundf(j*cosf(a[indices[i]]));
                int col = col0+roundf(j*sinf(a[indices[i]]));
                image.data[row*image.width+col] = m[indices[i]];
            }
        }
        [image savePNGToFilePath:theFilePath];
        [image release];
    } else {
        int factor = 2;
        OCVFloatImage * image = [[OCVFloatImage alloc] initWithData:NULL width:factor*input.width height:factor*input.height];
        for (int i = 0; i < nSelectedRows; i++) {
            for (int j = 0; j < nSelectedCols; j++) {
                int index = i*X.width+j;
                int row0 = factor*X.data[index];
                int col0 = factor*Y.data[index];
                for (int k = -factor; k < factor; k++) {
                    int row = row0+roundf(k*cosf(A.data[index]));
                    int col = col0+roundf(k*sinf(A.data[index]));
                    image.data[row*image.width+col] = M.data[index];
                }
            }
        }
        [image savePNGToFilePath:theFilePath];
        [image release];
    }
}

@end

float collinearity(NSPoint p, NSPoint tauP, NSPoint q, NSPoint tauQ)
{
    NSPoint pq = NSMakePoint(q.x-p.x, q.y-p.y);
    float npq = sqrtf(pq.x*pq.x+pq.y*pq.y);
    pq.x /= npq;
    pq.y /= npq;
    
    float factorP = fabsf(tauP.x*pq.x+tauP.y*pq.y);
    float factorQ = fabsf(tauQ.x*pq.x+tauQ.y*pq.y);
    
//    if (tauP.x == tauQ.x && tauP.y == tauQ.y) {
//        printf("(%f, %f), (%f, %f): %f\n", tauP.x, tauQ.y, tauP.x, tauQ.y, 0.5*(factorP+factorQ));
//    }
    
    //printf("%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n", p.x, p.y, tauP.x, tauP.y, q.x, q.y, tauQ.x, tauQ.y, factorP, factorQ);
    
    return 0.5*(factorP+factorQ); // in [0,1]; 0: parallel, 1: collinear
}
