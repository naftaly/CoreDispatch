//
//  CDQueue.h
//  CoreDispatch
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

#import <CoreDispatch/CDObject.h>

NS_ASSUME_NONNULL_BEGIN

NS_ENUM_AVAILABLE(10_10, 9_0) typedef NS_ENUM(NSUInteger,CDQueueType) {
    CDQueueTypeConcurrent,
    CDQueueTypeSerial
};

NS_CLASS_AVAILABLE(10_0,9_0) @interface CDQueue : CDObject

- (instancetype)initWithLabel:(NSString* _Nullable)label qos:(NSQualityOfService)qos type:(CDQueueType)type;

+ (instancetype)concurrent;
+ (instancetype)serial;

+ (instancetype)main;
+ (instancetype)userInteractiveQuality;
+ (instancetype)userInitiatedQuality;
+ (instancetype)defaultQuality;
+ (instancetype)utilityQuality;
+ (instancetype)backgroundQuality;

@property (nonatomic,readonly) dispatch_queue_t queue;

- (void)async:(dispatch_block_t)block;
- (void)sync:(DISPATCH_NOESCAPE dispatch_block_t)block;
- (void)after:(NSTimeInterval)time block:(dispatch_block_t)block;

- (void)barrierAsync:(dispatch_block_t)block;
- (void)barrierSync:(DISPATCH_NOESCAPE dispatch_block_t)block;

typedef void (^CDApplyBlock)(NSUInteger iteration);
- (void)applyIterations:(NSUInteger)iterations block:(DISPATCH_NOESCAPE CDApplyBlock)block;

@property (nullable,nonatomic,copy) NSString* label;
@property (nonatomic,assign) NSQualityOfService qualityOfService;
@property (nonatomic,assign) CDQueueType type;

- (void)setSpecific:(void* _Nullable)specific forKey:(void*)key destructor:(dispatch_function_t _Nullable)destructor;
- (void* _Nullable)specificForKey:(void*)key;
+ (void* _Nullable)specificForKey:(void*)key;

@property (nonatomic,readonly,getter=isCurrent) BOOL current;

@end

NS_ASSUME_NONNULL_END
