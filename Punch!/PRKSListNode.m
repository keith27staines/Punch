//
//  PRKSListNode.m
//  Punch!
//
//  Created by Keith Staines on 22/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "PRKSListNode.h"

@implementation PRKSListNode


@synthesize content, nextNode, previousNode;

-(id)init
{
    self = [super init];
    
    [self setNextNode:nil];
    [self setPreviousNode:nil];
    [self setContent:nil];

    return self;
}

-(void)insertNodeBefore:(PRKSListNode*)node
{
    [node setNextNode:self];
    [node setPreviousNode:[self previousNode]];
    [previousNode setNextNode:node];
    [self setPreviousNode:node];
}

-(void)insertNodeAfter:(PRKSListNode*)node
{
    [node setNextNode:[self nextNode]];
    [node setPreviousNode:self];
    [nextNode setPreviousNode:node];
    [self setNextNode:node];
}

-(void)remove
{
    [previousNode setNextNode:[self nextNode]];
    [nextNode setPreviousNode:[self previousNode]];
    [self setNextNode:nil];
    [self setPreviousNode:nil];
}


@end
