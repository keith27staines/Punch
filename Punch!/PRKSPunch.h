//
//  PRKSPunch.h
//  Punch!
//
//  Created by Keith Staines on 22/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class PRKSList;

@interface PRKSPunch : NSObject
{
    double strength;
    PRKSList * motionHistory;
    SystemSoundID soundID;
    NSString * type;
    NSString * target;
    NSString * shape;
    NSString * handed;
}

@property (strong) PRKSList * motionHistory;
@property (copy) NSString* type;
@property (copy) NSString* target;
@property (copy) NSString* shape;
@property (copy) NSString* handed;
-(void)analyze;
@end
