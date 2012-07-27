//
//  PRKSList.h
//  Punch!
//
//  Created by Keith Staines on 22/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PRKSListNode;


@interface PRKSList : NSObject
{
    PRKSListNode * firstNode;
    PRKSListNode * lastNode;
    NSInteger count;
}

// returns the node at the start of the list (head node)
@property (readonly) PRKSListNode* firstNode;

// returns the node at the end of the list (tail node)
@property (readonly) PRKSListNode* lastNode;

// the specified node becomes the new first node
-(void)addBeforeFirst:(PRKSListNode*)node;

// the specified node becomes the new last node
-(void)addAfterlast:(PRKSListNode*)node;

// the first node is removed from the list
-(void)removeFirst;

// the last node is removed from the list
-(void)removeLast;

// returns the number of nodes in the list
-(NSInteger)count;

// Remove all nodes
-(void)removeAll;

@end
