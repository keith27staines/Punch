//
//  ViewController.m
//  Punch!
//
//  Created by Keith Staines on 21/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

#import "ViewController.h"
#import "PRKSVector.h"
#import "PRKSFiniteList.h"
#import "PRKSListNode.h"
#import "PRKSIntegrator.h"
#import "PRKSDynamics.h"
#import "PRKSPunch.h"
#import "PRKSMatrix.h"

double radiansToDegrees(double radians);

double radiansToDegrees(double radians)
{
    return radians * 180.0 / 3.1415926;
}

// acceleration due to gravity in meters per second squared
const double g = 9.81; 

// used as a reasonable max for controls showing accelerations
const double maxG = 10.0 * g;

// square of the minimum acceleration required to be called a punch
const double minimumPunch = 1.0 * 1.0;

 // window over which captures are recorded (1 second)
const double motionCaptureWindow = 1.0; 

// time between motion detections
const double motionUpdateInterval = motionCaptureWindow / 100.0f;

// number of individual motion captures held in the window
const NSUInteger maxMotionHistory = motionCaptureWindow / motionUpdateInterval;

const double MINIMUM_PUNCH_DELTAV = 0.5;

const double ARM_LENGTH = 0.6;          // meters
const double ARM_TIME   = 1/20.0;       // seconds
const double ARM_SPEED  = ARM_LENGTH / ARM_TIME;  // meters per second
const double ARM_ACCEL  = ARM_SPEED  / ARM_TIME;  // meters per second squared
                           
const double MIN_PUNCH_SPEED = 0.1 * ARM_SPEED;   // meters per second



@implementation ViewController

@synthesize pitch;
@synthesize roll;
@synthesize yaw;
@synthesize punchDescription;
@synthesize positionX;
@synthesize positionY;
@synthesize positionZ;
@synthesize accX;
@synthesize accY;
@synthesize accZ;
@synthesize pitchV;
@synthesize rollV;
@synthesize yawV;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setupYawSlider:yaw];
    [self setupPitchSlider:pitch];
    [self setupRollSlider:roll];
    
    // load sound FX files
    [self loadSoundFX];
            
    // setup motion detection
    [self setupMotionDetection];
    
    // initialise the current punch to nil
    punch = nil;
    punches = [NSMutableArray arrayWithCapacity:1024];
    calibrationComplete = NO;
}

- (void)viewDidUnload
{
    [self setPitch:nil];
    [self setRoll:nil];
    [self setYaw:nil];
    [self setPunchDescription:nil];
    
    [self setPositionX:nil];
    [self setPositionY:nil];
    [self setPositionZ:nil];
    [self setAccX:nil];
    [self setPitchV:nil];
    [self setRollV:nil];
    [self setYawV:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    // return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return NO;
}

-(PRKSVector*)lowPassFilter:(PRKSVector*)newEstimateVector 
          ontoCurrentVector:(PRKSVector*)lowPassVector
                     deltaT:(double)dt
               cutoffFrequency:(double)cutoff
{
    if (!lowPassVector) return newEstimateVector;
 
    double timeConstant = 1.0/(6 * cutoff);
    double alpha = dt / (dt + timeConstant);
    
    PRKSVector * delta = [newEstimateVector multiplyByScaler:alpha];    
    PRKSVector * accumulator = [lowPassVector multiplyByScaler:(1-alpha)];
    return [accumulator add:delta];
}

-(void)logAcceleration:(PRKSVector*)acc deltaT:(double)dt
{
    NSLog(@"ax= %+06.2f ay= %+06.2f az= %+06.2f dt= %0.2f",
          acc.xComponent,
          acc.yComponent,
          acc.zComponent,
          dt);
    
}

-(void)reportList
{
    PRKSVector * acc;
    PRKSDynamics * aDynamics;
    PRKSListNode * aNode = [modeDetectionList firstNode];
    while (aNode) 
    {
        aDynamics = (PRKSDynamics*)aNode.content;
        acc = aDynamics.acceleration;
        NSLog(@"x = %0.2f, y = %0.2f, z = %0.2f",acc.xComponent,acc.yComponent, acc.zComponent);
        aNode = aNode.nextNode;
    }
    return;
}

-(void)doDynamicsOverDeltaT:(double)dt
{
    // create a dynamics object to encapsulate the dynamics data
    // for this delta t
    dynamics= [integrator integrateOverInterval:dt 
                                            withFinalAcceleration:acceleration];
    
    
    // create a new node to hold the dynamics object
    PRKSListNode * newNode = [[PRKSListNode alloc] init];
    
    // add the dynamics to the node, and then add the node to the list
    [newNode setContent:dynamics];
    [modeDetectionList addAfterlast:newNode];
   
}

-(void)setupMotionDetection
{
    
    // set up the motion manager
    if (!motionManager) 
    {
        // only one instance of motion manager
        motionManager = [[CMMotionManager alloc] init];

        // set up the queue to handle the incoming data
        queue = [NSOperationQueue mainQueue];

//        // set up the linked list that will hold the motion objects
//        motionHistory = [[PRKSFiniteList alloc] initWithSize:maxMotionHistory];
                
    }
    
    // setup motion detection and provide handler block
    if ([motionManager isDeviceMotionAvailable] && 
        [motionManager isGyroAvailable])
    {
        PRKSVector * zeroVector = [[PRKSVector alloc] init];
        [motionManager setDeviceMotionUpdateInterval:motionUpdateInterval];
        [motionManager startDeviceMotionUpdatesToQueue:queue
                                           withHandler:
         ^(CMDeviceMotion *motion, NSError *error)
         {
             
             if (!modeDetectionList) 
             {
                 modeDetectionList = [[PRKSFiniteList alloc] 
                                                 initWithSize:maxMotionHistory];
             }
             
             CMAttitude * attitude = motion.attitude;
             static NSTimeInterval  startTime; 
             if (!referenceAttitude) 
             {
                 // one time setup here...
                 startTime = motion.timestamp;
                 
                 // get the reference attitude
                 referenceAttitude = attitude;
                 origin = [zeroVector copy];
                 
                 // initialise the integrator
                 integrator   = [[PRKSIntegrator alloc] init];
                 gravity      = [zeroVector copy];
                 acceleration = [zeroVector copy];
                 
                 isCurrentlyPunching   = NO;
                 state = NO_PUNCH;

             }
             
             // convert to attitude with respect to the reference attitude
             [attitude multiplyByInverseOfAttitude:referenceAttitude];

             // Get rotation matrix from Z coords (Z being the reference attitude) 
             // to device coords
             CMRotationMatrix rotZtoDC = attitude.rotationMatrix;
             
             // We will usually want to go the other way, that is, transform 
             // vectors expressed in device coordinates to Z. This requires the
             // inverse matrix, but because we are dealing with a
             // rotation matrix, the inverse is just the transpose...
             CMRotationMatrix rotDCtoZ = [PRKSMatrix transpose:rotZtoDC];

             // For the first set of maxMotionHistory motion detections
             // we just self-calibrate
             static NSUInteger i = 0;
             
             BOOL calibrating = i < 10 || (motion.timestamp - startTime < 1.0f);
             if (calibrating)
             {
                 i++;
                 
                 // get the residual acceleration for this delta in device
                 // coords
                 PRKSVector * residualDeltaDC = [PRKSVector 
                                vectorFromAcceleration:motion.userAcceleration];
                 
                 residualDeltaDC = [residualDeltaDC add:[PRKSVector 
                                       vectorFromAcceleration:motion.gravity]];
                 
                 // convert the residual to world coordinates (Z)
                 PRKSVector * residualDelta = [residualDeltaDC 
                                             multiplyByRotationMatrix:rotDCtoZ];
                 
                 // add to sum
                 gravity = [gravity add:residualDelta];
                 
                 return;
             }

             // Have we finished calibrating?
             if ( !calibrationComplete ) 
             {
                 // rescale and final setup if calibrating is now finished
                 calibrationComplete = YES;
                 
                 // calculate average acceleration
                 [gravity scaleBy:g / (double)i];
                 
                 
                 // set the timestamp
                 timeStamp = motion.timestamp;
                 
             }
             
             // get the raw acceleration in device coordinates
             PRKSVector * accelerationDC = [PRKSVector 
                                vectorFromAcceleration:motion.userAcceleration];
             
             accelerationDC = [accelerationDC add:[PRKSVector 
                                        vectorFromAcceleration:motion.gravity]];
             [accelerationDC scaleBy:g];
                          
             // get acceleration in world coordinates
             acceleration = [accelerationDC multiplyByRotationMatrix:rotDCtoZ];
             
             // subtract the residual acceleration
             acceleration = [acceleration subtract:gravity];
             
             // the reported acceleration is actually the local gravity
             // perceived by the device, so we reverse it to get the
             // acceleration of the device relative to world
             [acceleration scaleBy:-1];
                                       
             // determine the interval since last update (in decimal seconds)
             double dt = motion.timestamp - timeStamp;
             
             // Now do punch mode identification. Are we between punches,
             // beginning a new punch, in the middle of punching, or ending 
             // a punch?
             if (!isCurrentlyPunching) 
             {            
                 
                 if (acceleration.yComponent < 0.5) 
                 {
                     // below threshold so we reject the possibility
                     // of a punch even beginning and also allow for a
                     // suspected punch fizzling out
                     if (state == PUNCH_SUSPECTED) 
                     {
                         // fizzling out
                         state = NO_PUNCH;
                         [self reportState];

                     }
                     [modeDetectionList removeAll];
                     [integrator resetPosition:[zeroVector copy] 
                                      velocity:[zeroVector copy] 
                                  acceleration:[zeroVector copy]
                                     timeStamp:timeStamp]; 

                 }
                 else
                 {

                     // if we are transitioning from NO_PUNCH to PUNCH_SUSPECTED
                     // we record the current position as the point of origin
                     // of the punch
                     if (state == NO_PUNCH) 
                     {
                         origin = [zeroVector copy];
                         T0 = [integrator timeStamp];
                     }

                     // do integrations and add to motion history 
                     [self doDynamicsOverDeltaT:dt];
                     T = [integrator timeStamp] - T0;

                     // Now we enter the PUNCH_SUSPECTED state proper
                     state = PUNCH_SUSPECTED;                     
                     [self reportState];
                     
                     // do a more detailed test to firm up the suspicion. The
                     // result of the test is either that a punch is firmly
                     // detected or still ambiguous. In other words, we might 
                     // still be in PUNCH_SUSPECTED after this test
                     
                     double displacement = [self displacement];
                     
                     if ( displacement > 0.1 ) 
                     {
                         if ([self punchDetected]) 
                         {
                             // We know that a punch is being thrown
                             isCurrentlyPunching = YES;
                             state = PUNCH_ACCELERATING;
                             [self reportState];
                             
                             // create the punch and add to the history
                             punch = [[PRKSPunch alloc] init];
                             [punches addObject:punch];
                         }                         
                     }
                     
                     // log the acceleration
                     // [self logAcceleration:accelerationDC deltaT:dt];

                 }
             }
             else // is currently punching
             {
                 // do integrations and add to motion history 
                 [self doDynamicsOverDeltaT:dt];
                 T = [integrator timeStamp] - T0;
                 
                 if (state == PUNCH_ACCELERATING) 
                 {
                     [self reportState];

                     if (acceleration.yComponent < 0) 
                     {
                         // punch acceleration phase is over, entering the
                         // deceleration  phase
                         state = PUNCH_DECELERATING;
                         [self reportState];

                     }
                 }
                 
                 if (state == PUNCH_DECELERATING)
                 {
                     [self reportState];

                     if (dynamics.velocity.yComponent < 0) 
                     {
                         state = PUNCH_RECOVERING;
                         [self reportState];
                         target = dynamics.position;
                         
                         // In principle, we now have all the information we 
                         // need to analyse this punch, so we do exactly that.
                         [punch setMotionHistory:modeDetectionList];
                         [punch analyze];
                         
                         // report the results of the motion analysis
                         NSMutableString * s = 
                         [NSMutableString stringWithString:@"Punch!!!\n"];
                         
                         [s appendString:punch.type];   [s appendString:@"\n"];
                         [s appendString:punch.target]; [s appendString:@"\n"];
                         [s appendString:punch.shape];  [s appendString:@"\n"];
                         [s appendString:punch.handed]; [s appendString:@"\n"];
                         
                         punchDescription.text = s;
                     }
                 }
                 
                 if (state == PUNCH_RECOVERING) 
                 {
                     [self reportState];
                     double displacement = [self displacement];
                     if ( displacement < 0.2 ) 
                     {
                         // close enough to the origin to assume the punch is over
                         state = NO_PUNCH;
                         [self reportState];

                         isCurrentlyPunching = NO;
                         modeDetectionList = nil;
                     }
                 }
             }             
             
             // update GUI
             static NSUInteger guiUpdate = 0;
             guiUpdate = ++guiUpdate % 10;
             if (guiUpdate == 0) 
             {
                 accX.text = [NSString stringWithFormat:@"%+05.1f",acceleration.xComponent];
                 accY.text = [NSString stringWithFormat:@"%+05.1f",acceleration.yComponent];
                 accZ.text = [NSString stringWithFormat:@"%+05.1f",acceleration.zComponent];
                 
                 PRKSVector * position = dynamics.position;
                 positionX.text = [NSString stringWithFormat:@"%+0.1f",position.xComponent];
                 positionY.text = [NSString stringWithFormat:@"%+0.1f",position.yComponent];
                 positionZ.text = [NSString stringWithFormat:@"%+0.1f",position.zComponent];
                 
                 pitch.value = radiansToDegrees(attitude.pitch);
                 yaw.value   = radiansToDegrees(attitude.yaw);
                 roll.value  = radiansToDegrees(attitude.roll); 
                 
                 pitchV.text = [NSString stringWithFormat:@"%+0.0f", pitch.value];
                 rollV.text  = [NSString stringWithFormat:@"%+0.0f", roll.value];
                 yawV.text   = [NSString stringWithFormat:@"%+0.0f", yaw.value];
                 
             }

             // prepare for next timestep
             acceleration = [zeroVector copy];
             timeStamp = motion.timestamp;


         }
         ];
        
    }
   
}

-(void)reportState
{
    NSString * stateString = nil;
    switch (state) 
    {
        case NO_PUNCH:
            stateString = @"NO_PUNCH";
            break;
            
        case PUNCH_SUSPECTED:
            stateString = @"PUNCH_SUSPECTED";
            break;
            
        case PUNCH_ACCELERATING:
            stateString = @"PUNCH_ACCELERATING";
            break;
            
        case PUNCH_DECELERATING:
            stateString = @"PUNCH_DECELERATING";
            break;

        case PUNCH_RECOVERING:
            stateString = @"PUNCH_RECOVERING";
            break;
            
        default:
            stateString = @"UNEXPECTED";
            break;
    }    
    
    double d = [self displacement];
    
    NSString * displacementString = [NSString stringWithFormat:@" distance = %0.2f at t=%0.2f",d,T];
    NSLog(@"%@",[stateString stringByAppendingString:displacementString]);
}

-(double)displacement
{
    return dynamics.position.yComponent - origin.yComponent;
}

-(BOOL)punchDetected
{
    PRKSVector * zeroVector = [[PRKSVector alloc] initWithX:0 withY:0 withZ:0];
    PRKSVector * impulseAccumulator = [zeroVector copy];
    PRKSVector * deltaV;
    PRKSDynamics * aDynamics;
    PRKSListNode * aNode = [modeDetectionList firstNode];
    const double MIN_PUNCH_DVY = 0.5;
    while (aNode) 
    {
        aDynamics = (PRKSDynamics*)[aNode content];
        deltaV = aDynamics.deltaV;
        impulseAccumulator = [impulseAccumulator add:deltaV];        
        aNode = [aNode nextNode];
        if (impulseAccumulator.yComponent > MIN_PUNCH_DVY ) 
        {
            // punch detected, so return immediately
            return YES;
        }
    }
    return NO;
}

-(double)punchMaxDeltaVy
{
    PRKSVector * zeroVector = [[PRKSVector alloc] initWithX:0 withY:0 withZ:0];
    PRKSVector * impulseAccumulator = [zeroVector copy];
    PRKSVector * deltaV;
    PRKSDynamics * aDynamics;
    PRKSListNode * aNode = [modeDetectionList firstNode];
    while (aNode) 
    {
        aDynamics = (PRKSDynamics*)[aNode content];
        deltaV = aDynamics.deltaV;
        
        // have we found the point at which the acceleration reverses?
        if (deltaV < 0) break;
        
        impulseAccumulator = [impulseAccumulator add:deltaV];        
        aNode = [aNode nextNode];
    }
    return impulseAccumulator.yComponent;
}


-(void)loadSoundFX
{
    NSError * error;
    NSBundle * bundle = [NSBundle mainBundle];    
    NSString * resourcePath = [bundle resourcePath];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray* files = [fileManager contentsOfDirectoryAtPath:resourcePath 
                                                      error:&error];    
    
    NSPredicate * soundFileFilter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.wav'"];
                                     
    NSArray* soundFiles = [files filteredArrayUsingPredicate:soundFileFilter];
    for (NSString * soundFile in soundFiles) 
    {
        NSURL * url = [NSURL fileURLWithPath:soundFile];
        NSLog(@"file %@", url);
        
        url = [bundle URLForResource:@"x264" withExtension:@"wav"];
        
        OSStatus status = AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, 
                                                           &soundID);
        
        if (status != kAudioServicesNoError) 
        {
            NSLog(@"error %ld loading soundFile %@",status, soundFile);
        }
        else
        {
            AudioServicesPlaySystemSound(soundID);
        }
        
    }
    
}

-(void)setupYawSlider:(UISlider *)slider
{
    [slider setMinimumValue:-180.0f];
    [slider setMaximumValue:180.0f];
    [slider setValue:0.0f];    
}

-(void)setupPitchSlider:(UISlider *)slider
{
    [slider setMinimumValue:-90.0f];
    [slider setMaximumValue:90.0f];
    [slider setValue:0.0f];
    [slider setUserInteractionEnabled:NO];
}

-(void)setupRollSlider:(UISlider *)slider
{
    [slider setMinimumValue:-180.0f];
    [slider setMaximumValue:180.0f];
    [slider setValue:0.0f];
}

-(void)dealloc
{
    AudioServicesDisposeSystemSoundID(soundID);
    [motionManager stopDeviceMotionUpdates];
}

@end
