//
//  PRKSVector.h
//  Punch!
//
//  Created by Keith Staines on 22/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface PRKSVector : NSObject <NSCopying>
{
    double xComponent;
    double yComponent;
    double zComponent;
}

@property (atomic, assign) double xComponent;
@property (atomic, assign) double yComponent;
@property (atomic, assign) double zComponent;

// designated constructor
-(id)initWithX:(double) x withY:(double) y withZ:(double)z;

// the length (aka magnitude, aka norm) of the vector
-(double)length;

// the square of the length of the vector
-(double)length2;

// returns a new vector equal to the specified vector * scale
-(PRKSVector *)multiplyByScaler:(double)scale;

// scales this vector
-(void)scaleBy:(double)scale;

// returns a new copy of this vector
-(PRKSVector *)copy;

// returns a unit vector in the same direction as this vector
-(PRKSVector *)unitVector;

// returns a new vector equal to the vector sum of
// this vector and the specified vector
-(PRKSVector *)add:(PRKSVector*)otherVector;

// returns a new vector equal to the vector difference of
// this vector and the specified vector (i.e subtracts other from this)
-(PRKSVector *)subtract:(PRKSVector *)otherVector;

// returns the dot product of this vector with the other vector
-(double)dotProduct:(PRKSVector*)otherVector;

// returns a new vector equal to the vector product of this vector with 
// the specified vector
-(PRKSVector*)vectorProduct:(PRKSVector*)otherVector;

// returns the dot product of the specified vectors
+(double)dotProductVector:(PRKSVector*)aVector with:(PRKSVector*)bVector;

// returns a new vector equal to the vector product of the two vectors
+(PRKSVector*)vectorProductOf:(PRKSVector*)aVector with:(PRKSVector*)bVector;

// creates a PRKSVector from a CMAcceleration
+(PRKSVector*)vectorFromAcceleration:(CMAcceleration)acc;

// returns a new vector = aVector + bVector
+(PRKSVector*)addVector:(PRKSVector*)aVector toVector:(PRKSVector*)bVector;

// returns a new vector = bVector - aVector
+(PRKSVector*)subtractVector:(PRKSVector*)aVector from:(PRKSVector*)bVector;

// returns the distance between two specified positions
+(double)distanceBetweenPosition:(PRKSVector*)aVector 
                     andPosition:(PRKSVector*)bVector;

-(PRKSVector*)multiplyByRotationMatrix:(CMRotationMatrix)rotation;

@end
