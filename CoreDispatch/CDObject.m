//
//  CDObject.m
//  CoreDispatch
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

#import "CDObject.h"
#import "CDQueue.h"

@interface CDObject () {
    dispatch_object_t _object;
}

@end

@implementation CDObject

+ (instancetype)withDispatchObject:(dispatch_object_t)object
{
    return [[self alloc] initWithDispatchObject:object];
}

- (instancetype)init
{
    return [self initWithDispatchObject:NULL];
}

- (instancetype)initWithDispatchObject:(dispatch_object_t)object
{
    self = [super init];
    _object = object;
    return self;
}

- (dispatch_object_t)object
{
    return _object;
}

- (void)setObject:(dispatch_object_t)object
{
    _object = object;
}

- (BOOL)isObjectLoaded
{
    return _object != NULL;
}

- (void*)context
{
    return dispatch_get_context(_object);
}

- (void)setContext:(void *)context
{
    dispatch_set_context(_object, context);
}

- (void)setFinalizer:(dispatch_function_t)finalizer
{
    dispatch_set_finalizer_f(_object, finalizer);
}

- (void)setTargetQueue:(CDQueue*)queue
{
    dispatch_set_target_queue(self.object, queue.queue);
}

- (void)activate
{
    dispatch_activate(_object);
}

- (void)suspend
{
    dispatch_suspend(_object);
}

- (void)resume
{
    dispatch_resume(_object);
}

- (NSString *)description
{
    return [_object debugDescription];
}

@end





