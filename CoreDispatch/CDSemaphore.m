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

#import "CDSemaphore.h"
#import "CDObjectSubclass.h"

@implementation CDSemaphore

- (instancetype)initWithCount:(long)count
{
    self = [super init];
    self.object = dispatch_semaphore_create(1);
    return self;
}

+ (instancetype)semaphore:(long)count
{
    return [[self alloc] initWithCount:count];
}

- (long)wait:(NSTimeInterval)time
{
    dispatch_time_t dtt = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    return dispatch_semaphore_wait(self.semaphore, dtt);
}

- (long)waitForever
{
    return dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (long)signal
{
    return dispatch_semaphore_signal(self.semaphore);
}

- (dispatch_semaphore_t)semaphore
{
    return (dispatch_semaphore_t)self.object;
}

@end
