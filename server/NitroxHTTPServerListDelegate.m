//
//  NitroxHTTPServerListDelegate.m
//  nitroxy1
//
//  Created by Robert Sanders on 9/30/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxHTTPServerListDelegate.h"
#import "NitroxHTTPUtils.h"


@implementation NitroxHTTPServerListDelegate

@synthesize list;

- (NitroxHTTPServerListDelegate *) init {
    [super init];
    list = [[NSMutableArray alloc] init];
    return self;
}

- (id) getDelegateForPath:(NSString *)path fromRequest:(NitroxHTTPRequestMessage *)request onServer:(NitroxHTTPServer *)server
{
    id <NitroxHTTPServerDelegate> delegate;
    for (delegate in list)
    {
        if ([delegate willHandlePath:path fromRequest:request onServer:server])
            return delegate;
    }
    return Nil;
}


- (BOOL) willHandlePath:(NSString *)path
            fromRequest:(NitroxHTTPRequestMessage *)request
               onServer:(NitroxHTTPServer *)server
{
    return [self getDelegateForPath:path fromRequest:request onServer:server] != Nil;
}


- (NitroxHTTPResponseMessage *)httpServer:(NitroxHTTPServer *)server
                            handleRequest:(NitroxHTTPRequestMessage *)request
                                   atPath:(NSString *)path

{
    id <NitroxHTTPServerDelegate> delegate;
    delegate = [self getDelegateForPath:path fromRequest:request onServer:server];
    if (delegate != Nil) {
        return [delegate httpServer:server handleRequest:request atPath:path];
    } else {
        return Nil;
    }
}

- (void) addDelegate:(id<NitroxHTTPServerDelegate>)delegate {
    [list addObject:delegate];
}

- (void) insertDelegate:(id<NitroxHTTPServerDelegate>)delegate atIndex:(NSInteger)index {
    [list insertObject:delegate atIndex:index];
}


- (void) dealloc {
    
    [super dealloc];
}

@end
