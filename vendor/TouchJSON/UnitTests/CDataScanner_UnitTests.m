//
//  CDataScanner_UnitTests.m
//  TouchCode
//
//  Created by Jonathan Wight on 04/16/08.
//  Copyright 2008 Toxic Software. All rights reserved.
//

#import "CDataScanner_UnitTests.h"

#import "CDataScanner.h"
#import "CDataScanner_Extensions.h"

@implementation CDataScanner_UnitTests

- (void)testSomething
{
CDataScanner *theScanner = [CDataScanner scannerWithData:[@"Hello World" dataUsingEncoding:NSUTF8StringEncoding]];

STAssertFalse(theScanner.isAtEnd, NULL);

NSString *theString = NULL;
BOOL theResult = 

theResult = [theScanner scanString:@"Hello" intoString:&theString];
STAssertTrue(theResult, NULL);
STAssertEqualObjects(theString, @"Hello", NULL);
STAssertEquals(theScanner.scanLocation, 5U, NULL);

theResult = [theScanner scanCharacter:' '];
STAssertTrue(theResult, NULL);
STAssertEquals(theScanner.scanLocation, 6U, NULL);

theResult = [theScanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&theString];
STAssertTrue(theResult, NULL);
STAssertEqualObjects(theString, @"World", NULL);
STAssertEquals(theScanner.scanLocation, 11U, NULL);


STAssertTrue(theScanner.isAtEnd, NULL);

}

@end
