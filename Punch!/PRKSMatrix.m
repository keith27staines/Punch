//
//  PRKSMatrix.m
//  Punch!
//
//  Created by Keith Staines on 25/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "PRKSMatrix.h"

@implementation PRKSMatrix

+(CMRotationMatrix)transpose:(CMRotationMatrix)matrix
{
    CMRotationMatrix transpose = matrix;
    transpose.m21 = matrix.m12;
    transpose.m31 = matrix.m13;
    transpose.m32 = matrix.m23;
    transpose.m12 = matrix.m21;
    transpose.m13 = matrix.m31;
    transpose.m23 = matrix.m32;
    return transpose;
}


@end
