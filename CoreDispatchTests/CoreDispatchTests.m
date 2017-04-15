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

#import <XCTest/XCTest.h>
#import <libkern/OSAtomicDeprecated.h>

@import CoreDispatch;

@interface CoreDispatchTests : XCTestCase

@end

@implementation CoreDispatchTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testQueues
{
    XCTAssertEqualObjects( [CDQueue main], [CDQueue main] );
    XCTAssertEqualObjects( [CDQueue userInteractiveQuality], [CDQueue userInteractiveQuality] );
    XCTAssertEqualObjects( [CDQueue userInitiatedQuality], [CDQueue userInitiatedQuality] );
    XCTAssertEqualObjects( [CDQueue defaultQuality], [CDQueue defaultQuality] );
    XCTAssertEqualObjects( [CDQueue utilityQuality], [CDQueue utilityQuality] );
    XCTAssertEqualObjects( [CDQueue backgroundQuality], [CDQueue backgroundQuality] );
}

- (void)testQuality
{
    CDQueue* queue = [CDQueue concurrent];
    queue.qualityOfService = NSQualityOfServiceUserInitiated;
    XCTAssertEqual(queue.qualityOfService, NSQualityOfServiceUserInitiated);
    XCTAssertNotNil(queue.queue);
    XCTAssertEqual(queue.qualityOfService, NSQualityOfServiceUserInitiated);
    
    queue = [CDQueue serial];
    queue.qualityOfService = NSQualityOfServiceUtility;
    XCTAssertEqual(queue.qualityOfService, NSQualityOfServiceUtility);
    XCTAssertNotNil(queue.queue);
    XCTAssertEqual(queue.qualityOfService, NSQualityOfServiceUtility);
}

- (void)testLabel
{
    CDQueue* queue = [CDQueue concurrent];
    queue.label = @"test queue label";
    XCTAssertEqualObjects(queue.label, @"test queue label");
    XCTAssertNotNil(queue.queue);
    XCTAssertEqualObjects(queue.label, @"test queue label");
}

- (void)testCurrent
{
    XCTestExpectation*  expectation = [self expectationWithDescription:@"CoreDispatch Expectation"];
    
    CDQueue* queue = [CDQueue concurrent];
    [queue async:^{
        XCTAssertTrue(queue.isCurrent);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testSyncCurrent
{
    XCTestExpectation*  expectation = [self expectationWithDescription:@"CoreDispatch Expectation"];
    
    CDQueue* queue = [CDQueue concurrent];
    [queue async:^{
        [queue sync:^{
            XCTAssertTrue(queue.isCurrent);
        }];
        XCTAssertTrue(queue.isCurrent);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testTargetQueue
{
    XCTestExpectation*  expectation = [self expectationWithDescription:@"CoreDispatch Expectation"];
    
    CDQueue* queue = [CDQueue concurrent];
    [queue setTargetQueue:[CDQueue backgroundQuality]];
    [queue async:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testBasicBarrierAsync
{
    XCTestExpectation*  expectation = [self expectationWithDescription:@"CoreDispatch Expectation"];
    
    CDQueue* queue = [CDQueue concurrent];
    [queue barrierAsync:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testBasicBarrierSync
{
    __block BOOL passed = NO;
    
    CDQueue* queue = [CDQueue concurrent];
    [queue barrierSync:^{
        passed = YES;
    }];
    
    XCTAssertTrue(passed,@"sync failed to run");
}

- (void)testBasicAsync
{
    XCTestExpectation*  expectation = [self expectationWithDescription:@"CoreDispatch Expectation"];
    
    CDQueue* queue = [CDQueue concurrent];
    [queue async:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testBasicSync
{
    __block BOOL passed = NO;
    
    CDQueue* queue = [CDQueue concurrent];
    [queue sync:^{
        passed = YES;
    }];
    
    XCTAssertTrue(passed,@"sync failed to run");
}

- (void)testAfter
{
    XCTestExpectation*  expectation = [self expectationWithDescription:@"CoreDispatch Expectation"];
    
    NSTimeInterval testDuration = 1;
    NSTimeInterval time = [NSDate date].timeIntervalSinceReferenceDate;
    [[CDQueue main] after:testDuration block:^{
        NSTimeInterval now =  [NSDate date].timeIntervalSinceReferenceDate;
        XCTAssertGreaterThanOrEqual(now-time, testDuration, @"Failure");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testApply
{
    __block int32_t count = 0;
    const int32_t final = 32;
    
    [[CDQueue defaultQuality] applyIterations:final block:^(NSUInteger iteration) {
        OSAtomicIncrement32(&count);
    }];
    XCTAssertEqual(count, final);
    
    count = 0;
    [[CDQueue defaultQuality] applyIterations:final block:^(NSUInteger iteration) {
        [[CDQueue defaultQuality] applyIterations:final block:^(NSUInteger iteration) {
            [[CDQueue defaultQuality] applyIterations:final block:^(NSUInteger iteration) {
                OSAtomicIncrement32(&count);
            }];
        }];
    }];
    XCTAssertEqual(count, final * final * final);
}

- (void)testGroup
{
    XCTestExpectation*  expectation = [self expectationWithDescription:@"CoreDispatch Expectation"];
    
    __block int32_t count = 0;
    const int32_t final = 32;
    
    CDQueue* queue = [CDQueue defaultQuality];
    CDGroup* group = [CDGroup group];
    
    for ( int32_t i = 0; i < final; i++ )
    {
        [group asyncOnQueue:queue block:^{
            OSAtomicIncrement32(&count);
        }];
    }

    [group notifyOnQueue:queue block:^{
        XCTAssertEqual(count, final);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testGroupEnterLeaveNotify
{
    XCTestExpectation*  expectation = [self expectationWithDescription:@"CoreDispatch Expectation"];
    
    __block int32_t count = 0;
    const int32_t final = 32;
    
    CDQueue* queue = [CDQueue defaultQuality];
    CDGroup* group = [CDGroup group];
    
    for ( int32_t i = 0; i < final; i++ )
    {
        [group enter];
        [queue async:^{
            OSAtomicIncrement32(&count);
            [group leave];
        }];
    }
    
    [group notifyOnQueue:queue block:^{
        XCTAssertEqual(count, final);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testGroupEnterLeaveWait
{
    __block int32_t count = 0;
    const int32_t final = 32;
    
    CDQueue* queue = [CDQueue defaultQuality];
    CDGroup* group = [CDGroup group];
    
    for ( int32_t i = 0; i < final; i++ )
    {
        [group enter];
        [queue async:^{
            OSAtomicIncrement32(&count);
            [group leave];
        }];
    }
    
    [group waitForever];
    XCTAssertEqual(count, final);

    count = 0;
    for ( int32_t i = 0; i < final; i++ )
    {
        [group enter];
        [queue async:^{
            OSAtomicIncrement32(&count);
            [group leave];
        }];
    }
    
    [group wait:5];
    XCTAssertEqual(count, final);
}

- (void)testSemaphoreWait
{
    CDSemaphore* sem = [CDSemaphore semaphore:0];
    
    __block int32_t val = 0;
    
    CDQueue* queue = [CDQueue concurrent];
    [queue async:^{
        OSAtomicIncrement32(&val);
        [sem signal];
    }];
    
    [sem wait:10];
    
    XCTAssertEqual(val, 1);
}

- (void)testSemaphoreWaitForever
{
    CDSemaphore* sem = [CDSemaphore semaphore:0];
    
    __block int32_t val = 0;
    
    CDQueue* queue = [CDQueue concurrent];
    [queue async:^{
        OSAtomicIncrement32(&val);
        [sem signal];
    }];
    
    [sem waitForever];
    
    XCTAssertEqual(val, 1);
}

- (void)testContext
{
    const void* kContext = &kContext;
    
    CDQueue* queue = [CDQueue concurrent];
    queue.context = (void*)kContext;
    XCTAssertEqual(queue.context, kContext);
    
}

static void _finalizer( void* context ) {
    XCTestExpectation* expect = (__bridge XCTestExpectation *)(context);
    [expect fulfill];
}

- (void)testFinalizer
{
    XCTestExpectation*  expectation = [self expectationWithDescription:@"CoreDispatch Expectation"];
    
    @autoreleasepool {
        CDQueue* queue = [CDQueue concurrent];
        queue.context = (__bridge void * _Nullable)(expectation);
        [queue setFinalizer:_finalizer];
    }
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testObject
{
    CDQueue* queue = [CDQueue concurrent];
    [queue activate];
    [queue suspend];
    [queue resume];
}

- (void)testDescription
{
    CDQueue* queue = [CDQueue concurrent];
    queue.qualityOfService = NSQualityOfServiceDefault;
    queue.label = @"test concurrent queue";
    XCTAssertNotNil(queue.description);
    
    queue = [CDQueue serial];
    queue.qualityOfService = NSQualityOfServiceBackground;
    queue.label = @"test serial queue";
    XCTAssertNotNil(queue.description);
}

@end
