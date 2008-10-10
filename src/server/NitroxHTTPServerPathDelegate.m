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

@synthesize paths, defaultDelegate;

- (NitroxHTTPServerPathDelegate *) init {
    [super init];
    paths = [[NSMutableDictionary alloc] init];
    return self;
}

- (BOOL) willHandlePath:(NSString *)path
            fromRequest:(NitroxHTTPRequest *)request
               onServer:(NitroxHTTPServer *)server
{
    return ([paths objectForKey:path] != Nil || [paths objectForKey:[[request URL] path]]);
}

- (NitroxHTTPResponseMessage *)httpServer:(NitroxHTTPServer *)server
                            handleRequest:(NitroxHTTPRequest *)request
                                   atPath:(NSString *)path
{
    NSArray *components = [path componentsSeparatedByString:@"/"];
    id<NitroxHTTPServerDelegate> handler = Nil;
    
    handler = [paths objectForKey:path];
    
    if (! handler) {
        NSString *key = Nil;
        if ([components count] >= 1) {
            key = [components objectAtIndex:0];
        } else {
            NSLog(@"empty component set for path");
        }

        if (key) {
            handler = [paths objectForKey:key];
        }
    }
    
    if (handler) {
        NitroxHTTPRequest *nextRequest = [request nextLevelRequest];
        return [handler httpServer:server handleRequest:nextRequest atPath:[nextRequest path]];
    } else if (defaultDelegate) {
        return [defaultDelegate httpServer:server handleRequest:request atPath:path];
    } else {
        return Nil;
    }
}

- (void) addPath:(NSString *)path delegate:(id<NitroxHTTPServerDelegate>)delegate
{
    [paths setObject:delegate forKey:path];
}

- (void) dealloc {
    [(id<NSObject>)defaultDelegate release];
    [paths release];
    [super dealloc];
}

@end
