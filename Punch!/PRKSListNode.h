//
//  PRKSListNode.h
//  Punch!
//
//  Created by Keith Staines on 22/11/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRKSListNode : NSObject
{
    NSObject * content;
    PRKSListNode * nextNode;
    PRKSListNode * previousNode;
}

@property (atomic, strong) NSObject * content;
@property (atomic, strong) PRKSListNode * nextNode;
@property (atomic, strong) PRKSListNode * previousNode;

-(void)insertNodeBefore:(PRKSListNode*)node;
-(void)insertNodeAfter:(PRKSListNode*)node;
-(void)remove;

@end
