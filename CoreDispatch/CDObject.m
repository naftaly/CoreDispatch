//
//  CDObject.m
//  CoreDispatch
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

#import "CDObject.h"
#import "CDObjectSubclass.h"
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

- (dispatch_object_t)objectWithoutLoading
{
    return _object;
}

- (BOOL)isObjectLoaded
{
    return _object != NULL;
}

- (void*)context
{
    return dispatch_get_context(self.object);
}

- (void)setContext:(void *)context
{
    dispatch_set_context(self.object, context);
}

- (void)setFinalizer:(dispatch_function_t)finalizer
{
    dispatch_set_finalizer_f(self.object, finalizer);
}

- (void)setTargetQueue:(CDQueue*)queue
{
    dispatch_set_target_queue(self.object, queue.queue);
}

- (void)activate
{
    dispatch_activate(self.object);
}

- (void)suspend
{
    dispatch_suspend(self.object);
}

- (void)resume
{
    dispatch_resume(self.object);
}

- (NSString *)description
{
    return [self.object debugDescription];
}

@end





