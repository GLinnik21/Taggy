//
//  TaggyTests.m
//  TaggyTests
//
//  Created by Gleb Linkin on 10/23/14.
//  Copyright (c) 2014 Gleb Linkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TGPriceRecognizer.h"

@interface TaggyTests : XCTestCase

@property (nonatomic, weak) NSDictionary *testImages;

@end

@implementation TaggyTests

+ (BOOL)testImageIndex:(NSUInteger)index
{
    NSDictionary *images  = @{
                              @(1): @(8100),
                              @(2): @(22000),
                              @(3): @(668750),
                              @(4): @(26350),
                              @(5): @(33000),
                              @(6): @(26300),
                              @(7): @(15200),
                              @(8): @(23150),
                              @(9): @(23050),
                              @(10): @(6950),
                              @(11): @(10150),
                              @(12): @(17050),
                              @(13): @(3150),
                              @(14): @(26300),
                              @(15): @(26350),
                              @(16): @(26350),
                              @(17): @(26350),
                              @(18): @(81000),
                              @(19): @(81000),
                              @(20): @(81000),
                              @(21): @(55200),
                              @(22): @(55200),
                              @(23): @(55200),
                              @(24): @(26350),
                              @(25): @(26350),
                              @(26): @(26350),
                              @(27): @(14800),
                              @(28): @(26350),
                              };

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    NSString *filename = [NSString stringWithFormat:@"testImages/%@", @(index)];
    NSString *tessdataPath = [bundle pathForResource:filename ofType:@"jpg"];

    UIImage *image = [UIImage imageWithContentsOfFile:tessdataPath];
    NSArray *blocks = [TGPriceRecognizer recognizeImage:image];

    for (TGRecognizedBlock *block in blocks) {
        if ([[block number] isEqualToNumber:images[@(index)]]) {
            return true;
        }
    }

    return false;
}

#define TEST_VALUES

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)testImage1
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:1]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:1];
    }];
#endif
}

- (void)testImage2
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:2]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:2];
    }];
#endif
}

- (void)testImage3
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:3]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:3];
    }];
#endif
}

- (void)testImage4
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:4]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:4];
    }];
#endif
}

- (void)testImage5
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:5]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:5];
    }];
#endif
}

- (void)testImage6
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:6]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:6];
    }];
#endif
}

- (void)testImage7
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:7]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:7];
    }];
#endif
}

- (void)testImage8
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:8]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:8];
    }];
#endif
}

- (void)testImage9
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:9]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:9];
    }];
#endif
}

- (void)testImage10
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:10]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:10];
    }];
#endif
}

- (void)testImage11
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:11]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:11];
    }];
#endif
}

- (void)testImage12
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:12]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:12];
    }];
#endif
}

- (void)testImage13
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:13]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:13];
    }];
#endif
}

- (void)testImage14
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:14]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:14];
    }];
#endif
}

- (void)testImage15
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:15]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:15];
    }];
#endif
}

- (void)testImage16
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:16]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:16];
    }];
#endif
}

- (void)testImage17
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:17]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:17];
    }];
#endif
}

- (void)testImage18
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:18]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:18];
    }];
#endif
}

- (void)testImage19
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:19]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:19];
    }];
#endif
}

- (void)testImage20
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:20]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:20];
    }];
#endif
}

- (void)testImage21
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:21]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:21];
    }];
#endif
}

- (void)testImage22
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:22]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:22];
    }];
#endif
}

- (void)testImage23
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:23]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:23];
    }];
#endif
}

- (void)testImage24
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:24]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:24];
    }];
#endif
}

- (void)testImage25
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:25]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:25];
    }];
#endif
}

- (void)testImage26
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:26]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:26];
    }];
#endif
}

- (void)testImage27
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:27]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:27];
    }];
#endif
}

- (void)testImage28
{
#ifdef TEST_VALUES
    XCTAssert([[self class] testImageIndex:28]);
#else
    [self measureBlock:^{
        [[self class] testImageIndex:28];
    }];
#endif
}

@end
