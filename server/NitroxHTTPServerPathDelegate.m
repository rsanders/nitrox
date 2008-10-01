//
//  NitroxHTTPServerPathDelegate.m
//  nitroxy1
//
//  Created by Robert Sanders on 9/28/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxHTTPServerPathDelegate.h"
#import "NitroxHTTPUtils.h"

@implementation NitroxHTTPServerPathDelegate

@synthesize paths;

- (NitroxHTTPServerPathDelegate *) init {
    [super init];
    paths = [[NSMutableDictionary alloc] init];
    return self;
}

- (BOOL) willHandlePath:(NSString *)path
            fromRequest:(NitroxHTTPRequestMessage *)request
               onServer:(NitroxHTTPServer *)server
{
    return ([paths objectForKey:path] != Nil || [paths objectForKey:[[request URL] path]]);
}

- (NitroxHTTPResponseMessage *)httpServer:(NitroxHTTPServer *)server
                            handleRequest:(NitroxHTTPRequestMessage *)request
                                   atPath:(NSString *)path
{
    NSArray *components = [path componentsSeparatedByString:@"/"];
    
    if ([paths objectForKey:path]) {
        return [(id<NitroxHTTPServerDelegate>)[paths objectForKey:path] httpServer:server handleRequest:request atPath:path];
    }
    
    NSString *key;
    if ([components count] >= 1) {
        key = [components objectAtIndex:0];
    } else {
        NSLog(@"empty component set for path");
        @throw [NSException exceptionWithName:@"error" reason:@"no components" userInfo:Nil];
    }

    if (key) {
        return [(id<NitroxHTTPServerDelegate>)[paths objectForKey:key] httpServer:server handleRequest:request atPath:path];
    }
    
    return Nil;
}

- (void) addPath:(NSString *)path delegate:(id<NitroxHTTPServerDelegate>)delegate
{
    [paths setObject:delegate forKey:path];
}

- (void) dealloc {
    
    [super dealloc];
}

@end
