//
//  PRKSPunch.m
//  Punch!
//
//  Created by Keith Staines on 22/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "PRKSPunch.h"
#import "PRKSVector.h"
#import "PRKSListNode.h"
#import "PRKSList.h"
#import "PRKSDynamics.h"

@implementation PRKSPunch

@synthesize motionHistory;
@synthesize type;
@synthesize target;
@synthesize shape;
@synthesize handed;

-(id)init
{
    self = [super init];
    
    strength      = 0.0;
    motionHistory = nil;
    soundID       = 0;
    type          = @"damp squib";
    shape         = @"";
    handed        = @"";

    return self;
}

-(void)analyze
{
    if (!motionHistory) return;
    
    PRKSListNode * firstNode = motionHistory.firstNode; 
    PRKSListNode * lastNode  = motionHistory.lastNode;
    PRKSDynamics * firstDynamics = (PRKSDynamics*)firstNode.content;
    PRKSDynamics * lastDynamics  = (PRKSDynamics*)lastNode.content;
    
    PRKSListNode * midNode     = nil;
    PRKSDynamics * midDynamics = nil;
    NSInteger midNodeNumber    = motionHistory.count/2;
    
    PRKSVector * initialVelocity = firstDynamics.velocity;
    PRKSVector * velocityDifference = nil;
    PRKSVector * maxVelocityDifference = [[PRKSVector alloc] initWithX:0 
                                                                 withY:0 
                                                                 withZ:0];
    PRKSListNode * node = firstNode;
    NSInteger i = 0;
    while (node) 
    {
        PRKSDynamics * dynamics = (PRKSDynamics *)node.content;
        velocityDifference = [dynamics.velocity subtract:initialVelocity];
        
        if (velocityDifference.length2 > maxVelocityDifference.length2) 
        {
            maxVelocityDifference = velocityDifference;
        }
        
        if (i == midNodeNumber) 
        {
            midNode = node;
            midDynamics = (PRKSDynamics*)midNode.content;
        }
        
        node = node.nextNode;
        i++;
    }
    strength = maxVelocityDifference.length2;
    
    PRKSVector * direction = [lastDynamics.position subtract:firstDynamics.position];
        
    // Test for uppercut
    if (direction.zComponent > 0 &&
        direction.zComponent > direction.xComponent && 
        direction.zComponent > direction.yComponent) 
    {
        // basically, the shot is going more upwards than in any other 
        // direction, so identify this as an uppercut
        type   = @"uppercut";
        target = @"Body shot";
        return;
    }
    
    // identify provisional target of shot
    if (direction.zComponent >= 0) 
    {
        // horizontal or going up means probable head shot
        target = @"Body shot";
    }
    else
    {
        // going down means probable body shot
        target = @"Head shot";
    }
    
    PRKSVector * v1 = [midDynamics.position subtract:firstDynamics.position];
    PRKSVector * v2 = [lastDynamics.position subtract:midDynamics.position];
    v1 = [v1 unitVector];
    v2 = [v2 unitVector];
    
    // alpha is the angle between v1 and v2
    double cosAlpha = [PRKSVector dotProductVector:v1 with:v2];
    
    shape = (cosAlpha > 0.866) ? @"straight" : @"round";
    
    PRKSVector * normal = [PRKSVector vectorProductOf:v1 with:v2];
    PRKSVector * up = [[PRKSVector alloc] initWithX:0 withY:0 withZ:1];
    
    double cosTheta = [PRKSVector dotProductVector:up with:normal];
    
    // theta is the angle between the up direction and the normal of the 
    // punch plane. Clockwise winding implies right hook, anticlockwise
    // implies left hook
    handed = (cosTheta > 0) ? @"right" : @"left";
    
}


@end
