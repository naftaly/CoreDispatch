//
//  CDGroup.m
//  CoreDispatch
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

#import "CDGroup.h"
#import "CDObjectSubclass.h"

@implementation CDGroup

- (instancetype)init
{
    return [super initWithDispatchObject:dispatch_group_create()];
}

- (dispatch_group_t)group
{
    return (dispatch_group_t)self.object;
}

+ (instancetype)group
{
    return [[self alloc] init];
}

- (void)asyncOnQueue:(CDQueue *)queue block:(dispatch_block_t)block
{
    dispatch_group_async(self.group, queue.queue, block);
}

- (long)waitForever
{
    return dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
}

- (long)wait:(NSTimeInterval)time
{
    dispatch_time_t dtt = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    return dispatch_group_wait(self.group, dtt);
}

- (void)notifyOnQueue:(CDQueue *)queue block:(dispatch_block_t)block
{
    dispatch_group_notify(self.group, queue.queue, block);
}

- (void)enter
{
    dispatch_group_enter(self.group);
}

- (void)leave
{
    dispatch_group_leave(self.group);
}

@end
