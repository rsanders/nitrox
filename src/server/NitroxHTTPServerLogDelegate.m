//
//  NitroxHTTPServerLogDelegate.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxHTTPServerLogDelegate.h"

#import "NibwareLog.h"

#undef NSLog

@implementation NitroxHTTPServerLogDelegate

+ (NitroxHTTPServerLogDelegate *) singleton
{
    static NitroxHTTPServerLogDelegate *singleton = nil;
    @synchronized(self)
    {
        if (!singleton)
            singleton = [[NitroxHTTPServerLogDelegate alloc] init];
        
        return singleton;
    }
    
    // shutup Xcode
    return singleton;
}

- (NitroxHTTPServerLogDelegate *) init {
    return self;
}

- (BOOL) willHandlePath:(NSString *)path
            fromRequest:(NitroxHTTPRequest *)request
               onServer:(NitroxHTTPServer *)server
{
    return YES;
}


- (NitroxHTTPResponseMessage *)httpServer:(NitroxHTTPServer *)server
                            handleRequest:(NitroxHTTPRequest *)request
                                   atPath:(NSString *)path
{
    NSString *msg = [[[NSString alloc] initWithData:[[request requestMessage] body] 
                                           encoding:NSUTF8StringEncoding] 
                     autorelease];
    NSLog(@"JSLOG: %@", msg);
    [[NibwareLog singleton] logWithFormat:@"JSLOG: %@", msg];

    return [NitroxHTTPResponseMessage emptyResponseWithCode:200];
}

@end
