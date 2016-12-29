//
//  CoreDispatchTests.m
//  CoreDispatchTests
//
//  Created by Alexander Cohen on 2016-12-28.
//  Copyright © 2016 X-Rite, Inc. All rights reserved.
//

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
    
    [CDQueue.defaultQuality async:^{
        val++;
        [sem signal];
    }];
    
    [sem wait:10];
    
    XCTAssertEqual(val, 1);
}

- (void)testSemaphoreWaitForever
{
    CDSemaphore* sem = [CDSemaphore semaphore:0];
    
    __block int32_t val = 0;
    
    [CDQueue.defaultQuality async:^{
        val++;
        [sem signal];
    }];
    
    [sem waitForever];
    
    XCTAssertEqual(val, 1);
}

@end
