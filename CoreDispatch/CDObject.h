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

@property (nullable,nonatomic,readonly) dispatch_object_t object;
@property (nullable,nonatomic,assign) void* context;

- (void)setFinalizer:(dispatch_function_t _Nullable)finalizer;
- (void)setTargetQueue:(CDQueue*)queue;

- (void)activate;

- (void)suspend;
- (void)resume;

@end

NS_ASSUME_NONNULL_END

#define CDOnce(EXP)\
static id onceObject = nil;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
onceObject = EXP;\
});\
return onceObject;
