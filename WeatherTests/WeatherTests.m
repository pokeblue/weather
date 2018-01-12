//
//  WeatherTests.m
//  WeatherTests
//
//  Created by mike oh on 2018-01-11.
//  Copyright © 2018 mike oh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WeatherModel.h"

@interface WeatherTests : XCTestCase
    @property (nonatomic,strong)    XCTestExpectation *expectation;
@end

@implementation WeatherTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _expectation = [self expectationWithDescription:@"Server response"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSTimeInterval time = 30;
    WeatherModel *model = [WeatherModel.alloc init];
    
    [model getWeatherData:@"München,DE" completion:^(NSDictionary *result, NSError *error){
        if (error != nil) {
            XCTFail(@"Failure: %@",error.description);
        } else {
            if (![result[@"weather"] isKindOfClass: [NSArray class]]) {
                XCTFail(@"Failure: No weather information.");
            }
        }
        
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:time handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Failure: user retrieval exceeded %f seconds.", time);
        }
    }];
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
