/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2017 Alexander Cohen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import <CoreDispatch/CDObject.h>

NS_ASSUME_NONNULL_BEGIN

NS_ENUM_AVAILABLE(10_10, 9_0) typedef NS_ENUM(NSUInteger,CDQueueType) {
    CDQueueTypeConcurrent,
    CDQueueTypeSerial
};

NS_CLASS_AVAILABLE(10_0,9_0) @interface CDQueue : CDObject

- (instancetype)initWithLabel:(NSString* _Nullable)label qos:(NSQualityOfService)qos type:(CDQueueType)type;

@property (nullable,nonatomic,copy) NSString* label;
@property (nonatomic,assign) NSQualityOfService qualityOfService;
@property (nonatomic,assign) CDQueueType type;

+ (instancetype)concurrent;
+ (instancetype)serial;

@property (class,atomic,readonly) CDQueue* main;
@property (class,atomic,readonly) CDQueue* userInteractiveQuality;
@property (class,atomic,readonly) CDQueue* userInitiatedQuality;
@property (class,atomic,readonly) CDQueue* defaultQuality;
@property (class,atomic,readonly) CDQueue* utilityQuality;
@property (class,atomic,readonly) CDQueue* backgroundQuality;

- (void)async:(dispatch_block_t)block;
- (void)sync:(DISPATCH_NOESCAPE dispatch_block_t)block;
- (void)after:(NSTimeInterval)time block:(dispatch_block_t)block;

- (void)barrierAsync:(dispatch_block_t)block;
- (void)barrierSync:(DISPATCH_NOESCAPE dispatch_block_t)block;

typedef void (^CDApplyBlock)(NSUInteger iteration);
- (void)applyIterations:(NSUInteger)iterations block:(DISPATCH_NOESCAPE CDApplyBlock)block;

- (void)setSpecific:(void* _Nullable)specific forKey:(void*)key destructor:(dispatch_function_t _Nullable)destructor;
- (void* _Nullable)specificForKey:(void*)key;
+ (void* _Nullable)specificForKey:(void*)key;

@property (nonatomic,readonly,getter=isCurrent) BOOL current;

@property (nonatomic,readonly) dispatch_queue_t queue;

@end

NS_ASSUME_NONNULL_END
