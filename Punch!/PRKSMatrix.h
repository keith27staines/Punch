//
//  PRKSMatrix.h
//  Punch!
//
//  Created by Keith Staines on 25/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface PRKSMatrix : NSObject
{
    
}

+(CMRotationMatrix)transpose:(CMRotationMatrix)matrix;


@end
