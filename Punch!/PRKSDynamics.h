//
//  PRKSDynamics.h
//  Punch!
//
//  Created by Keith Staines on 23/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PRKSVector;

@interface PRKSDynamics : NSObject
{
    double timeStamp;
    double integrationInterval;
    PRKSVector * position;
    PRKSVector * velocity;
    PRKSVector * acceleration;
}

@property (copy) PRKSVector * position;
@property (copy) PRKSVector * velocity;
@property (copy) PRKSVector * acceleration;
@property (assign)     double timeStamp;
@property (assign)     double integrationInterval;
@property (readonly) PRKSVector * deltaV;

@end
