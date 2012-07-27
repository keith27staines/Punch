//
//  ViewController.h
//  Punch!
//
//  Created by Keith Staines on 21/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PRKSVector;
@class PRKSFiniteList;
@class PRKSIntegrator;
@class PRKSPunch;
@class PRKSDynamics;

enum punchState 
{
    NO_PUNCH           = 0,
    PUNCH_SUSPECTED    = 1,
    PUNCH_DETECTED     = 2,
    PUNCH_ACCELERATING = 3,
    PUNCH_DECELERATING = 4,
    PUNCH_RECOVERING   = 5
};

@interface ViewController : UIViewController
{
    BOOL calibrationComplete;
    
    CMMotionManager  * motionManager;
    NSOperationQueue * queue;
    CMAttitude * referenceAttitude;
    BOOL frameIsSet;
    SystemSoundID soundID;
    
    NSTimeInterval timeStamp;
    PRKSIntegrator * integrator;
    PRKSDynamics * dynamics;
    PRKSVector * gravity;
    PRKSVector * acceleration;
    PRKSVector * origin;
    NSTimeInterval T0;
    NSTimeInterval T;
    
    PRKSVector * target;

    BOOL isCurrentlyPunching;

    PRKSFiniteList * modeDetectionList;
    PRKSPunch * punch;
    NSMutableArray * punches;
    enum punchState state;

}

@property (strong, nonatomic) IBOutlet UISlider *pitch;
@property (strong, nonatomic) IBOutlet UISlider *roll;
@property (strong, nonatomic) IBOutlet UISlider *yaw;

@property (strong, nonatomic) IBOutlet UILabel *punchDescription;
@property (strong, nonatomic) IBOutlet UILabel *positionX;
@property (strong, nonatomic) IBOutlet UILabel *positionY;
@property (strong, nonatomic) IBOutlet UILabel *positionZ;

@property (strong, nonatomic) IBOutlet UILabel *accX;
@property (strong, nonatomic) IBOutlet UILabel *accY;
@property (strong, nonatomic) IBOutlet UILabel *accZ;

@property (strong, nonatomic) IBOutlet UILabel *pitchV;
@property (strong, nonatomic) IBOutlet UILabel *rollV;
@property (strong, nonatomic) IBOutlet UILabel *yawV;

-(void)setupPitchSlider:(UISlider*)slider;
-(void)setupYawSlider:(UISlider*)slider;
-(void)setupRollSlider:(UISlider*)slider;
-(void)setupMotionDetection;

-(void)loadSoundFX;

-(BOOL)punchDetected;
-(double)punchMaxDeltaVy;

-(void)doDynamicsOverDeltaT:(double)dt;
-(double)displacement;
-(void)reportState;

@end



