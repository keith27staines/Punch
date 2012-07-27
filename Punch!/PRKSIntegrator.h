//
//  PRKSIntegrator.h
//  Punch!
//
//  Created by Keith Staines on 23/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PRKSVector;
@class PRKSDynamics;

@interface PRKSIntegrator : NSObject
{
    PRKSVector * position;
    PRKSVector * acceleration;
    PRKSVector * velocity;
    NSTimeInterval timeStamp;
}

@property (copy) PRKSVector * position;
@property (copy) PRKSVector * velocity;
@property (copy) PRKSVector * acceleration;
@property (readonly) NSTimeInterval timeStamp;

-(id)initWithPosition:(PRKSVector*) pos 
             velocity:(PRKSVector*) vel 
         acceleration:(PRKSVector*) accel 
            timeStamp:(NSTimeInterval) time;

-(PRKSDynamics *)integrateOverInterval:(NSTimeInterval)dt 
       withFinalAcceleration:(PRKSVector*)finalAccel;

-(void)resetPosition:(PRKSVector*) pos 
            velocity:(PRKSVector*) vel 
        acceleration:(PRKSVector*) accel 
           timeStamp:(NSTimeInterval) time;
@end
