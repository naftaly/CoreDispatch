//
//  CDSemaphore.h
//  CoreDispatch
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

#import <CoreDispatch/CDObject.h>

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE(10_0,9_0) @interface CDSemaphore : CDObject

+ (instancetype)semaphore:(long)count;
- (instancetype)initWithCount:(long)count;
- (instancetype)init NS_UNAVAILABLE;

- (long)waitForever;
- (long)wait:(NSTimeInterval)time;
- (long)signal;

@property (nonatomic,readonly) dispatch_semaphore_t semaphore;

@end

NS_ASSUME_NONNULL_END
