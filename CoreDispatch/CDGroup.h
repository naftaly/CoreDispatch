//
//  CDGroup.h
//  CoreDispatch
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

#import <CoreDispatch/CDObject.h>
#import <CoreDispatch/CDQueue.h>

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE(10_0,9_0) @interface CDGroup : CDObject

- (instancetype)init;
+ (instancetype)group;

- (void)asyncOnQueue:(CDQueue*)queue block:(dispatch_block_t)block;

- (long)waitForever;
- (long)wait:(NSTimeInterval)time;

- (void)notifyOnQueue:(CDQueue*)queue block:(dispatch_block_t)block;

- (void)enter;
- (void)leave;

@property (nonatomic,readonly) dispatch_group_t group;

@end

NS_ASSUME_NONNULL_END
