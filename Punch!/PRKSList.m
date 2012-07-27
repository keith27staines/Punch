//
//  PRKSList.m
//  Punch!
//
//  Created by Keith Staines on 22/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import "PRKSList.h"
#import "PRKSListNode.h"

@implementation PRKSList

@synthesize firstNode, lastNode;

-(id)init
{
    self = [super init];
    firstNode = nil;
    lastNode = nil;
    count = 0;
    return self;
}

-(void)addBeforeFirst:(PRKSListNode*)node
{
    // Take care of house keeping. We are adding a node so increment the count
    count++;
    
    // if the list is empty we need to do things a little differently
    if (!firstNode) 
    {
        // this node will become the first (and also the last) node in the list
        firstNode = node;
        lastNode = node;
        
        // the list only has one node so we set previous and next nodes to nil
        [node setNextNode:nil];
        [node setPreviousNode:nil];
        return;
    }
    
    // at least one node already exists, so the new node is added before the
    // current first node, and then we reassign the first node pointer 
    [firstNode insertNodeBefore:node];
    firstNode = node;
}

-(void)addAfterlast:(PRKSListNode *)node
{
    // if the list is empty we must do things a little differently
    if (!lastNode) 
    {
        // the list is empty so we are effectively adding this node before
        // the first (equiv. operation given an empty list). We will delegate the
        // operation and its associated house-keeping to addBeforeFirst. 
        // Note that the call to addVeforeFirst increments the count, so we 
        // mustn't do it again here!
        [self addBeforeFirst:node];
        return;
    }

    // housekeeping - increment the count
    count++;

    // at least one node already exists so we add the new node after the current
    // last node and then reassign the last node pointer to point to it
    [lastNode insertNodeAfter:node];
    lastNode = node;
    
}

-(void)removeLast
{
    if (!lastNode) 
    {
        // the list is empty so there is nothing to do
        return;
    }
    
    // we will end up with one less node in the list than there is now
    count--;
    
    // what is now the penultimate node will ulimately become the last node
    PRKSListNode * penultimateNode = [lastNode previousNode];
    
    // remove the current last node
    [lastNode remove];
    
    // reassign the last node pointer
    lastNode = penultimateNode;
    
    // make sure the first node pointer isn't left hanging if the list is now
    // empty
    if (lastNode==nil) firstNode = nil; 
}

-(void)removeFirst
{
    if (!firstNode) 
    {
        // the list is empty so there is nothing to do
        return;
    }
    
    // we will end up with one less node in the list than there is now
    count--;

    // what is now the second node will ultimately become the first
    PRKSListNode * secondNode = [firstNode nextNode];
    
    // remove first node
    [firstNode remove];
    
    // reassign first node pointer
    firstNode = secondNode;
    
    // make sure that the last node pointer isn't left hanging if the list
    // is now empty
    if (firstNode==nil) lastNode = nil;
}

// NB the count will only be accurate if nodes have been added through methods
// exposed by this class rather than calling the node methods directly.
-(NSInteger)count
{
    return count;
}

-(void)removeAll
{
    while (firstNode) 
    {
        [[self lastNode] setContent:nil];
        [self removeLast];
    }
}

@end
