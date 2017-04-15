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
