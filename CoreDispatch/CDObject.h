//
//  CDObject.h
//  CoreDispatch
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CDQueue;

NS_CLASS_AVAILABLE(10_0,9_0) @interface CDObject : NSObject

+ (instancetype)withDispatchObject:(dispatch_object_t _Nullable)object;
- (instancetype)initWithDispatchObject:(dispatch_object_t _Nullable)object NS_DESIGNATED_INITIALIZER;

@property (nullable,nonatomic,strong) dispatch_object_t object;
@property (nullable,nonatomic,assign) void* context;

- (void)setFinalizer:(dispatch_function_t _Nullable)finalizer;
- (void)setTargetQueue:(CDQueue*)queue;

- (void)activate;

- (void)suspend;
- (void)resume;

- (BOOL)isObjectLoaded;

@end

NS_ASSUME_NONNULL_END

#define CDOnce(EXP)\
static id onceObject = nil;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
onceObject = EXP;\
});\
return onceObject;
