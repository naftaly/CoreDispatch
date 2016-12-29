//
//  CDSemaphore.m
//  CoreDispatch
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

#import "CDSemaphore.h"
#import "CDObjectSubclass.h"

@implementation CDSemaphore

+ (instancetype)semaphore:(long)count
{
    return [self withDispatchObject:dispatch_semaphore_create(count)];
}

- (instancetype)initWithCount:(long)count
{
    self = [super init];
    self.object = dispatch_semaphore_create(1);
    return self;
}

- (long)wait:(NSTimeInterval)time
{
    dispatch_time_t dtt = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    return dispatch_semaphore_wait((dispatch_semaphore_t)self.object, dtt);
}

- (long)waitForever
{
    return dispatch_semaphore_wait((dispatch_semaphore_t)self.object, DISPATCH_TIME_FOREVER);
}

- (long)signal
{
    return dispatch_semaphore_signal((dispatch_semaphore_t)self.object);
}

@end
