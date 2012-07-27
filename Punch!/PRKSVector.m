//
//  PRKSVector.m
//  Punch!
//
//  Created by Keith Staines on 22/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "PRKSVector.h"

@implementation PRKSVector

@synthesize xComponent, yComponent, zComponent;

- (id)copyWithZone:(NSZone *)zone
{
    PRKSVector * copy = [[[self class] alloc] init];
    [copy setXComponent:[self xComponent]];
    [copy setYComponent:[self yComponent]];
    [copy setZComponent:[self zComponent]];
    return copy;
}

-(id)init
{
    return [self initWithX:0 withY:0 withZ:0];
}

-(id)initWithX:(double) x withY:(double) y withZ:(double)z
{
    self = [super init];
    
    xComponent = x;
    yComponent = y;
    zComponent = z;

    return self;
}

+(PRKSVector*)vectorFromAcceleration:(CMAcceleration)acc
{
    return [[PRKSVector alloc] initWithX:acc.x withY:acc.y withZ:acc.z];
}

-(double)length2
{
    return xComponent * xComponent + 
           yComponent * yComponent + 
           zComponent * zComponent;
}

-(double)length
{
    return sqrt([self length2]);
}

-(PRKSVector*)copy
{
    return [[PRKSVector alloc] initWithX:xComponent 
                                   withY:yComponent 
                                   withZ:zComponent];
}

-(PRKSVector *)multiplyByScaler:(double)scale
{
    return [[PRKSVector alloc] initWithX:scale * xComponent 
                                   withY:scale * yComponent 
                                   withZ:scale * zComponent] ;
}

-(void)scaleBy:(double)scale
{
    xComponent *= scale;
    yComponent *= scale;
    zComponent *= scale;
}

-(PRKSVector*)unitVector
{
    
    PRKSVector * unit = [self copy];
    double scale = [unit length];
    
    if (scale <= 0) 
    {
        unit.xComponent = 1.0;
        return unit;
    }
    
    scale = 1.0 / scale;
    [unit scaleBy:scale];
    return unit;
}

-(PRKSVector *)add:(PRKSVector*)otherVector
{
    return [[PRKSVector alloc] initWithX:xComponent + [otherVector xComponent] 
                                   withY:yComponent + [otherVector yComponent] 
                                   withZ:zComponent + [otherVector zComponent]];
}    

-(PRKSVector *)subtract:(PRKSVector*)otherVector
{
    return [[PRKSVector alloc] initWithX:xComponent - [otherVector xComponent] 
                                   withY:yComponent - [otherVector yComponent] 
                                   withZ:zComponent - [otherVector zComponent]];
    
}

-(double)dotProduct:(PRKSVector*)otherVector
{
    return xComponent * [otherVector xComponent] +
           yComponent * [otherVector yComponent] +
           zComponent * [otherVector zComponent];
}

+(double)dotProductVector:(PRKSVector*)aVector with:(PRKSVector*)bVector
{
    return [aVector dotProduct:bVector];
}

-(PRKSVector*)vectorProduct:(PRKSVector*)otherVector
{
    PRKSVector* product = [[PRKSVector alloc] init];
    [product setXComponent:yComponent * [otherVector zComponent] - 
                           zComponent * [otherVector yComponent]];

    [product setYComponent:zComponent * [otherVector xComponent] - 
                           xComponent * [otherVector zComponent]];

    [product setZComponent:xComponent * [otherVector yComponent] - 
                           yComponent * [otherVector zComponent]];
    
    return product;
}

+(PRKSVector*)vectorProductOf:(PRKSVector*)aVector with:(PRKSVector*)bVector
{
    return [aVector vectorProduct:bVector];
}

+(PRKSVector*)addVector:(PRKSVector*)aVector toVector:(PRKSVector*)bVector
{
    return [aVector add:bVector];
}

+(PRKSVector*)subtractVector:(PRKSVector*)aVector from:(PRKSVector*)bVector
{
    return [bVector subtract:aVector];
}

+(double)distanceBetweenPosition:(PRKSVector*)aVector 
                     andPosition:(PRKSVector*)bVector
{
    PRKSVector * sep = [PRKSVector subtractVector:aVector from:bVector];
    return [sep length];
}

-(PRKSVector*)multiplyByRotationMatrix:(CMRotationMatrix)rotation
{
    PRKSVector * result = [[PRKSVector alloc] init];
    result.xComponent = rotation.m11 * xComponent + 
                        rotation.m12 * yComponent +
                        rotation.m13 * zComponent;

    result.yComponent = rotation.m21 * xComponent + 
                        rotation.m22 * yComponent +
                        rotation.m23 * zComponent;

    result.zComponent = rotation.m31 * xComponent + 
                        rotation.m32 * yComponent +
                        rotation.m33 * zComponent;

    return result;
}
@end
