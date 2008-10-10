//
//  CJSONSerializer_UnitTests.m
//  TouchJSON
//
//  Created by Jonathan Wight on 12/12/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CJSONSerializer_UnitTests.h"

#import "CJSONSerializer.h"

@implementation CJSONSerializer_UnitTests
-(void)testEmptyDictionary {
	NSString *jsonEquivalent = @"{}";
	NSDictionary *emptyDictionary = [NSDictionary dictionary];
	id theObject = [[CJSONSerializer serializer] serializeObject:emptyDictionary];
	STAssertEqualObjects(jsonEquivalent, theObject, nil);
}

-(void)testSingleKeyValuePair {
	NSString *jsonEquivalent = @"{\"a\":\"b\"}";
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"b" forKey:@"a"];
	id theObject = [[CJSONSerializer serializer] serializeObject:dictionary];
	STAssertEqualObjects(jsonEquivalent, theObject, nil);
}
@end
