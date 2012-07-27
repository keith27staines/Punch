//
//  PRKSDynamics.m
//  Punch!
//
//  Created by Keith Staines on 23/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "PRKSDynamics.h"
#import "PRKSVector.h"

@implementation PRKSDynamics

@synthesize position, velocity, acceleration, timeStamp, integrationInterval;

-(PRKSVector*)deltaV
{
    return [acceleration multiplyByScaler:integrationInterval];
}


@end
