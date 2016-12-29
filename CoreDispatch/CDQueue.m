//
//  CDQueue.m
//  CoreDispatch
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

#import "CDQueue.h"
#import "CDObjectSubclass.h"

@interface CDQueue () {
    NSString* _initialLabel;
    NSQualityOfService _initalQualityOfService;
}

@end

@implementation CDQueue

- (instancetype)initWithLabel:(NSString *)label qos:(NSQualityOfService)qos type:(CDQueueType)type
{
    self = [self init];
    self.label = label;
    self.qualityOfService = qos;
    self.type = type;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _initalQualityOfService = NSQualityOfServiceDefault;
    _initialLabel = [[NSBundle mainBundle].bundleIdentifier stringByAppendingString:[NSProcessInfo processInfo].globallyUniqueString];
    return self;
}

static void* CDQueueSpecificKey = &CDQueueSpecificKey;

- (dispatch_queue_t)queue
{
    if ( ![self isObjectLoaded] )
    {
        dispatch_queue_attr_t   attr = dispatch_queue_attr_make_with_qos_class( self.type == CDQueueTypeSerial ? DISPATCH_QUEUE_SERIAL : DISPATCH_QUEUE_CONCURRENT,_initalQualityOfService,0);
        dispatch_queue_t        queue = dispatch_queue_create(_initialLabel.UTF8String, attr);
        self.object = queue;
        [self setSpecific:(__bridge void * _Nullable)(self) forKey:CDQueueSpecificKey destructor:NULL];
    }
    return (dispatch_queue_t)self.object;
}

- (void)setTargetQueue:(CDQueue *)queue
{
    (void)self.queue;
    [super setTargetQueue:queue];
}

+ (instancetype)serial
{
    return [[self alloc] initWithLabel:nil qos:NSQualityOfServiceDefault type:CDQueueTypeSerial];
}

+ (instancetype)concurrent
{
    return [[self alloc] initWithLabel:nil qos:NSQualityOfServiceDefault type:CDQueueTypeConcurrent];
}

+ (instancetype)main
{
    CDOnce( [CDQueue withDispatchObject:dispatch_get_main_queue()] );
}

+ (instancetype)userInteractiveQuality
{
    CDOnce( [CDQueue withDispatchObject:dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)] );
}

+ (instancetype)userInitiatedQuality
{
    CDOnce( [CDQueue withDispatchObject:dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)] );
}

+ (instancetype)defaultQuality
{
    CDOnce( [CDQueue withDispatchObject:dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)] );
}

+ (instancetype)utilityQuality
{
    CDOnce( [CDQueue withDispatchObject:dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)] );
}

+ (instancetype)backgroundQuality
{
    CDOnce( [CDQueue withDispatchObject:dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)] );
}

- (BOOL)isCurrent
{
    return [self.class specificForKey:CDQueueSpecificKey] == [self specificForKey:CDQueueSpecificKey];
}

- (void)async:(dispatch_block_t)block
{
    dispatch_async(self.queue, block);
}

- (void)sync:(dispatch_block_t)block
{
    if ( self.isCurrent )
        block();
    else
        dispatch_sync(self.queue, block);
}

- (void)after:(NSTimeInterval)time block:(dispatch_block_t)block
{
    dispatch_time_t dtt = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    dispatch_after(dtt, self.queue, block);
}

- (void)barrierAsync:(dispatch_block_t)block
{
    dispatch_barrier_async(self.queue, block);
}

- (void)barrierSync:(dispatch_block_t)block
{
    dispatch_barrier_sync(self.queue, block);
}

- (void)applyIterations:(NSUInteger)iterations block:(CDApplyBlock)block
{
    dispatch_apply(iterations, self.queue, block);
}

- (void)setType:(CDQueueType)type
{
    if ( ![self isObjectLoaded] )
        _type = type;
}

- (void)setLabel:(NSString *)label
{
    if ( ![self isObjectLoaded] )
        _initialLabel = [label copy];
}

- (NSString *)label
{
    if ( ![self isObjectLoaded] )
        return [_initialLabel copy];
    const char* l = dispatch_queue_get_label(self.queue);
    return [NSString stringWithUTF8String:l];
}

- (void)setQualityOfService:(NSQualityOfService)qualityOfService
{
    if ( ![self isObjectLoaded] )
        _initalQualityOfService = qualityOfService;
}

- (NSQualityOfService)qualityOfService
{
    if ( ![self isObjectLoaded] )
        return _initalQualityOfService;
    return (NSQualityOfService)dispatch_queue_get_qos_class(self.queue, NULL);
}

- (void)setSpecific:(void *)specific forKey:(void *)key destructor:(dispatch_function_t)destructor
{
    dispatch_queue_set_specific(self.queue, key, specific, destructor);
}

- (void *)specificForKey:(void *)key
{
    return dispatch_queue_get_specific(self.queue, key);
}

+ (void *)specificForKey:(void *)key
{
    return dispatch_get_specific(key);
}

@end







