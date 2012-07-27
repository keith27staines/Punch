//
//  PRKSFiniteList.h
//  Punch!
//
//  Created by Keith Staines on 22/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "PRKSList.h"


@interface PRKSFiniteList : PRKSList
{
    NSUInteger size;
}

@property (readonly) NSUInteger size;

-(id)initWithSize:(NSUInteger)maxSize;
@end
