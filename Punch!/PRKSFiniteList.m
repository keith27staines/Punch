//
//  PRKSFiniteList.m
//  Punch!
//
//  Created by Keith Staines on 22/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "PRKSFiniteList.h"
#import "PRKSListNode.h"

@implementation PRKSFiniteList

@synthesize size;

-(id)init
{
    return [self initWithSize:1024];
}

-(id)initWithSize:(NSUInteger)maxSize
{
    self = [super init];
    
    size = maxSize;
    
    return self;
}

-(void)addBeforeFirst:(PRKSListNode*)node
{
    [super addBeforeFirst:node];
    
    if (count > size) 
    {
        [self removeLast];
    }
}

-(void)addAfterlast:(PRKSListNode *)node
{
    [super addAfterlast:node];

    if (count > size) 
    {
        [self removeFirst];
    }
}

@end
