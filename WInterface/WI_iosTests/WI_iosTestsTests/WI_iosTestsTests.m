//
//  WI_iosTestsTests.m
//  WI_iosTestsTests
//
//  Created by Will Smart on 23/11/12.
//  Copyright (c) 2012 Will Smart. All rights reserved.
//

#import "WI_iosTestsTests.h"
#import "../../../wi.wi.h"

@implementation WI_iosTestsTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSet
{
    SetTester *t=[[[SetTester alloc] init] autorelease];
    if ([t steps:10000]) STFail(@"Failed SetTester fair test");
}
- (void)testArray
{
    ArrayTester *t=[[[ArrayTester alloc] init] autorelease];
    if ([t steps:10000]) STFail(@"Failed ArrayTester fair test");
}
- (void)testDictionary
{
    DictionaryTester *t=[[[DictionaryTester alloc] init] autorelease];
    if ([t steps:10000]) STFail(@"Failed DictionaryTester fair test");
}

@end
