//
//  CJSONScanner_UnitTests.m
//  TouchCode
//
//  Created by Jonathan Wight on 12/07/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CJSONScanner_UnitTests.h"

#import "CJSONScanner.h"

static id TXPropertyList(NSString *inString)
{
NSData *theData = [inString dataUsingEncoding:NSUTF8StringEncoding];

NSPropertyListFormat theFormat;
NSString *theError = NULL;

id thePropertyList = [NSPropertyListSerialization propertyListFromData:theData mutabilityOption:NSPropertyListImmutable format:&theFormat errorDescription:&theError];
return(thePropertyList);
}

static BOOL Scan(NSString *inString, id *outResult)
{
CJSONScanner *theScanner = [CJSONScanner scannerWithData:[inString dataUsingEncoding:NSUTF8StringEncoding]];;
BOOL theResult = [theScanner scanJSONObject:outResult error:NULL];
return(theResult);
}

@implementation CJSONScanner_UnitTests

- (void)testTrue
{
id theObject = NULL;
BOOL theResult = Scan(@"true", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject boolValue] == YES, @"Result of scan didn't match expectations.");
}

- (void)testFalse
{
id theObject = NULL;
BOOL theResult = Scan(@"false", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject boolValue] == NO, @"Result of scan didn't match expectations.");
}

- (void)testNull
{
id theObject = NULL;
BOOL theResult = Scan(@"null", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:[NSNull null]], @"Result of scan didn't match expectations.");
}

- (void)testNumber
{
id theObject = NULL;
BOOL theResult = Scan(@"3.14", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject doubleValue] == 3.14, @"Result of scan didn't match expectations.");
}

- (void)testEngineeringNumber
{
id theObject = NULL;
BOOL theResult = Scan(@"3.14e4", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject doubleValue] == 3.14e4, @"Result of scan didn't match expectations.");
}

#pragma mark -

- (void)testString
{
id theObject = NULL;
BOOL theResult = Scan(@"\"Hello world.\"", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:@"Hello world."], @"Result of scan didn't match expectations.");

theResult = Scan(@"    \"Hello world.\"      ", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:@"Hello world."], @"Result of scan didn't match expectations.");
}

- (void)testUnicode
{
id theObject = NULL;
BOOL theResult = Scan(@"\"••••Über©©©©\"", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:@"••••Über©©©©"], @"Result of scan didn't match expectations.");
}

- (void)testStringEscaping
{
id theObject = NULL;
BOOL theResult = Scan(@"\"\\r\\n\\f\\b\\\\\"", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:@"\r\n\f\b\\"], @"Result of scan didn't match expectations.");
}

- (void)testStringEscaping2
{
id theObject = NULL;
BOOL theResult = Scan(@"\"Hello\r\rworld.\"", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:@"Hello\r\rworld."], @"Result of scan didn't match expectations.");
}

- (void)testStringUnicodeEscaping
{
id theObject = NULL;
BOOL theResult = Scan(@"\"x\\u0078xx\"", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:@"xxxx"], @"Result of scan didn't match expectations.");
}

#pragma mark -

- (void)testSimpleDictionary
{
id theObject = NULL;
BOOL theResult = Scan(@"{\"bar\":\"foo\"}", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:TXPropertyList(@"{bar = foo; }")], @"Result of scan didn't match expectations.");
}

- (void)testNestedDictionary
{
id theObject = NULL;
BOOL theResult = Scan(@"{\"bar\":{\"bar\":\"foo\"}}", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:TXPropertyList(@"{bar = {bar = foo; }; }")], @"Result of scan didn't match expectations.");
}

#pragma mark -

- (void)testSimpleArray
{
id theObject = NULL;
BOOL theResult = Scan(@"[\"bar\",\"foo\"]", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:TXPropertyList(@"(bar, foo)")], @"Result of scan didn't match expectations.");
}

- (void)testNestedArray
{
id theObject = NULL;
BOOL theResult = Scan(@"[\"bar\",[\"bar\",\"foo\"]]", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:TXPropertyList(@"(bar, (bar, foo))")], @"Result of scan didn't match expectations.");
}

#pragma mark -

- (void)testWhitespace1
{
id theObject = NULL;
BOOL theResult = Scan(@"    \"Hello world.\"      ", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:@"Hello world."], @"Result of scan didn't match expectations.");
}

- (void)testWhitespace2
{
id theObject = NULL;
BOOL theResult = Scan(@"[ true, false ]", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
//STAssertTrue([theObject isEqual:TXPropertyList(@"(1, 0)")], @"Result of scan didn't match expectations.");
}

- (void)testWhitespace3
{
id theObject = NULL;
BOOL theResult = Scan(@"{ \"x\" : [ 1 , 2 ] }", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
//STAssertTrue([theObject isEqual:TXPropertyList(@"{x, (1, 2)}")], @"Result of scan didn't match expectations.");
}

#pragma mark -

- (void)testComments1
{
//id theObject = NULL;
//BOOL theResult = Scan(@"/* cmt */ [ 1, /* cmt */ 2 ] /* cmt */", &theObject);
//STAssertTrue(theResult, @"Scan return failure.");
//STAssertTrue([theObject isEqual:TXPropertyList(@"(1, 2)")], @"Result of scan didn't match expectations.");
}


/*
- (void)testComments2
{
id theObject = NULL;
BOOL theResult = Scan(@"[ 1, // cmt \r 2 ]", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
//STAssertTrue([theObject isEqual:TXPropertyList(@"(1, 2)")], @"Result of scan didn't match expectations.");
}
*/

#pragma mark -

- (void)testNegative
{
id theObject = NULL;
//STAssertThrows(Scan(@"[", &theObject), @"Incomplete array.");
}

#pragma mark -

- (void)testBlakesCode
{
id theObject = NULL;
BOOL theResult = Scan([NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Blake" ofType:@"json"]], &theObject);
STAssertTrue(theResult, @"Scan returned failure");
}

- (void)testExtraCommasInDictionary
{
id theObject = NULL;
BOOL theResult = Scan(@"{\r\"title\": \"space - Everyone's Tagged Photos\",\r}", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:TXPropertyList(@"{title = \"space - Everyone's Tagged Photos\"; }")], @"Result of scan didn't match expectations.");
}

- (void)testEmptyArray1
{
id theObject = NULL;
BOOL theResult = Scan(@"[]", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:TXPropertyList(@"()")], @"Result of scan didn't match expectations.");
}

- (void)testEmptyArray2
{
id theObject = NULL;
BOOL theResult = Scan(@"[ ]", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:TXPropertyList(@"()")], @"Result of scan didn't match expectations.");
}

- (void)testEmptyDictionary1
{
id theObject = NULL;
BOOL theResult = Scan(@"{}", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
//STAssertTrue([theObject isEqual:TXPropertyList(@"{}")], @"Result of scan didn't match expectations.");
}

- (void)testEmptyDictionary2
{
id theObject = NULL;
BOOL theResult = Scan(@"{\"Foo\":{}}", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:TXPropertyList(@"{Foo = { }; }")], @"Result of scan didn't match expectations.");
}

- (void)testEmptyDictionary3
{
id theObject = NULL;
BOOL theResult = Scan(@"{ }", &theObject);
STAssertTrue(theResult, @"Scan return failure.");
STAssertTrue([theObject isEqual:TXPropertyList(@"{}")], @"Result of scan didn't match expectations.");
}

- (void)testDanielPascoCode1
{
id theObject = NULL;
NSString *theSource = @"{\"status\": \"ok\", \"operation\": \"new_task\", \"task\": {\"status\": 0, \"updated_at\": {}, \"project_id\": 7179, \"dueDate\": null, \"creator_id\": 1, \"type_id\": 0, \"priority\": 1, \"id\": 37087, \"summary\": \"iPhone test\", \"description\": null, \"creationDate\": {}, \"owner_id\": 1, \"noteCount\": 0, \"commentCount\": 0}}";
BOOL theResult = Scan(theSource, &theObject);
STAssertTrue(theResult, @"Scan return failure.");
}

- (void)testDanielPascoCode2
{
id theObject = NULL;
NSString *theSource = @"{\"status\": \"ok\", \"operation\": \"new_task\", \"task\": {\"status\": 0, \"project_id\": 7179, \"dueDate\": null, \"creator_id\": 1, \"type_id\": 0, \"priority\": 1, \"id\": 37087, \"summary\": \"iPhone test\", \"description\": null, \"owner_id\": 1, \"noteCount\": 0, \"commentCount\": 0}}";
BOOL theResult = Scan(theSource, &theObject);
STAssertTrue(theResult, @"Scan return failure.");
}

- (void)testTomHaringtonCode1
{
id theObject = NULL;
NSString *theSource = @"{\"r\":[{\"name\":\"KEXP\",\"desc\":\"90.3 - Where The Music Matters\",\"icon\":\"\\/img\\/channels\\/radio_stream.png\",\"audiostream\":\"http:\\/\\/kexp-mp3-1.cac.washington.edu:8000\\/\",\"type\":\"radio\",\"stream\":\"fb8155000526e0abb5f8d1e02c54cb83094cffae\",\"relay\":\"r2b\"}]}";
BOOL theResult = Scan(theSource, &theObject);
STAssertTrue(theResult, @"Scan return failure.");
}

@end
