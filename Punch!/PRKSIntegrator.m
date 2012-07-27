//
//  PRKSIntegrator.m
//  Punch!
//
//  Created by Keith Staines on 23/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "PRKSIntegrator.h"
#import "PRKSVector.h"
#import "PRKSDynamics.h"

@implementation PRKSIntegrator

@synthesize position, velocity, acceleration, timeStamp;

-(id)init
{
    PRKSVector * zeroVector = [[PRKSVector alloc] initWithX:0 withY:0 withZ:0];
    
    return [self initWithPosition:zeroVector 
                         velocity:zeroVector 
                     acceleration:zeroVector 
                        timeStamp:0];
}

-(id)initWithPosition:(PRKSVector *)pos 
             velocity:(PRKSVector *)vel 
         acceleration:(PRKSVector *)accel
            timeStamp:(double)time
{
    self = [super init]; 
    [self resetPosition:pos 
               velocity:vel 
           acceleration:accel 
              timeStamp:time];
    
    return self;
}

-(void)resetPosition:(PRKSVector *)pos 
            velocity:(PRKSVector *)vel 
        acceleration:(PRKSVector *)accel 
           timeStamp:(NSTimeInterval)time
{
    position = pos;
    velocity = vel;    
    acceleration = accel;
    timeStamp = time;  
}

-(PRKSDynamics *)integrateOverInterval:(double)dt 
                 withFinalAcceleration:(PRKSVector *)a
{
    // Verlet integration (velocity variant)
    
    // position to O(h3)
    self.position = [[position add:[velocity multiplyByScaler:dt]] 
                               add:[acceleration multiplyByScaler:dt * dt / 2.0]];
    
    // velocity to O(h2)
    self.velocity = [velocity add:[[acceleration add:a] multiplyByScaler:dt * 0.5 ]];
  
    // update acceleration and timestamp
    self.acceleration = a;
    timeStamp = timeStamp + dt;
    
    PRKSDynamics * dynamics = [[PRKSDynamics alloc] init];
    [dynamics setPosition:position];
    [dynamics setVelocity:velocity];
    [dynamics setAcceleration:acceleration];
    [dynamics setTimeStamp:timeStamp];
    [dynamics setIntegrationInterval:dt];
    
    return dynamics;
    
}


@end
