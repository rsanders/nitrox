//
//  NitroxBinaryData.m
//  libnitrox
//
//  Created by Robert Sanders on 10/17/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxBinaryData.h"

#import "CJSONSerializer.h"

@implementation NitroxBinaryData

@synthesize data;

- (NitroxBinaryData *)initWithData:(NSData*)newdata
{
    [super init];
    self.data = newdata;
    return self;
}

- (void) dealloc 
{
    self.data = Nil;
    [super dealloc];
}

// TODO: should convert binary data to JS string literal encoding OR send back URL
//   http://developer.mozilla.org/En/Core_JavaScript_1.5_Guide:Literals#String_Literals
- (NSString *) serializeToJSON
{
    int max = [data length];
    if (max > 100) { max = 100; }
    NSLog(@"serializing binary to JSON: %@", [[data description] substringToIndex:max]);
    NSString* string = [[NSString alloc] initWithData:data encoding:NSNEXTSTEPStringEncoding];
    if (!string ) {
        string = @"binary data";
    }
    CJSONSerializer *serializer = [[[CJSONSerializer alloc] init] autorelease];    
    
    return [serializer serializeString:string];
}

@end
