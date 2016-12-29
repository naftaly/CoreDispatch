//
//  CDObjectSubclass.h
//  CoreDispatch
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDObject ()

+ (instancetype)withDispatchObject:(dispatch_object_t _Nullable)object;
- (instancetype)initWithDispatchObject:(dispatch_object_t _Nullable)object NS_DESIGNATED_INITIALIZER;

@property (nullable,nonatomic,strong) dispatch_object_t object;

- (BOOL)isObjectLoaded;

@end

NS_ASSUME_NONNULL_END
