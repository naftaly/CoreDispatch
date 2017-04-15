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

#import "CDGroup.h"
#import "CDObjectSubclass.h"

@implementation CDGroup

- (instancetype)init
{
    return [super initWithDispatchObject:dispatch_group_create()];
}

- (dispatch_group_t)group
{
    return (dispatch_group_t)self.object;
}

+ (instancetype)group
{
    return [[self alloc] init];
}

- (void)asyncOnQueue:(CDQueue *)queue block:(dispatch_block_t)block
{
    dispatch_group_async(self.group, queue.queue, block);
}

- (long)waitForever
{
    return dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
}

- (long)wait:(NSTimeInterval)time
{
    dispatch_time_t dtt = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    return dispatch_group_wait(self.group, dtt);
}

- (void)notifyOnQueue:(CDQueue *)queue block:(dispatch_block_t)block
{
    dispatch_group_notify(self.group, queue.queue, block);
}

- (void)enter
{
    dispatch_group_enter(self.group);
}

- (void)leave
{
    dispatch_group_leave(self.group);
}

@end
