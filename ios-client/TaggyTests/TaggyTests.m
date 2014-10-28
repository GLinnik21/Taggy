//
//  TaggyTests.m
//  TaggyTests
//
//  Created by Gleb Linkin on 10/23/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PhotoCaptureViewController.h"

@interface TaggyTests : XCTestCase

@end

@implementation TaggyTests

+ (NSArray *)testImageIndex:(NSUInteger)index
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    NSString *filename = [NSString stringWithFormat:@"testImages/%@", @(index)];
    NSString *tessdataPath = [bundle pathForResource:filename ofType:@"jpg"];

    UIImage *image = [UIImage imageWithContentsOfFile:tessdataPath];

    return [PhotoCaptureViewController recognizeImage:image];
}

//#define TEST_VALUES

- (void)testImage1
{
    [self measureBlock:^{
        NSArray *result = [[self class] testImageIndex:1];
#ifdef TEST_VALUES
        XCTAssert([result containsObject:@(8100)]);
#endif
    }];
}

- (void)testImage2
{
    [self measureBlock:^{
        NSArray *result = [[self class] testImageIndex:2];
#ifdef TEST_VALUES
        XCTAssert([result containsObject:@(22000)]);
#endif
    }];
}

- (void)testImage3
{
    [self measureBlock:^{
        NSArray *result = [[self class] testImageIndex:3];
#ifdef TEST_VALUES
        XCTAssert([result containsObject:@(668750)]);
#endif
    }];
}

- (void)testImage4
{
    [self measureBlock:^{
        NSArray *result = [[self class] testImageIndex:4];
#ifdef TEST_VALUES
        XCTAssert([result containsObject:@(26350)]);
#endif
    }];
}

- (void)testImage5
{
    [self measureBlock:^{
        NSArray *result = [[self class] testImageIndex:5];
#ifdef TEST_VALUES
        XCTAssert([result containsObject:@(33000)]);
#endif
    }];
}

- (void)testImage6
{
    [self measureBlock:^{
        NSArray *result = [[self class] testImageIndex:6];
#ifdef TEST_VALUES
        XCTAssert([result containsObject:@(26300)]);
#endif
    }];
}

- (void)testImage7
{
    [self measureBlock:^{
        NSArray *result = [[self class] testImageIndex:7];
#ifdef TEST_VALUES
        XCTAssert([result containsObject:@(15200)]);
#endif
    }];
}

- (void)testImage8
{
    [self measureBlock:^{
        NSArray *result = [[self class] testImageIndex:8];
#ifdef TEST_VALUES
        XCTAssert([result containsObject:@(23150)]);
#endif
    }];
}

- (void)testImage9
{
    [self measureBlock:^{
        NSArray *result = [[self class] testImageIndex:9];
#ifdef TEST_VALUES
        XCTAssert([result containsObject:@(23050)]);
#endif
    }];
}

@end
