//
//  NitroxRPCDispatcher.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxRPCDispatcher.h"
#import "Nibware.h";
#import "CJSONSerializer.h"

@implementation NitroxRPCDispatcher

- (NitroxRPCDispatcher *) initWithStubClass:(NitroxStubClass *)stubClass {
    stub = [stubClass retain];
    [stubClass setDispatcher:self];
    return self;
}

- (void) dealloc {
    stub.dispatcher = Nil;
    [stub release];
    [super dealloc];
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

    NSLog(@"RPC: argstring is %@", msg);
    
    NSString *query = [[[request requestMessage] URL] query];
    
    // need to separate id and token and other args
    if (false && query && ![query isEqualToString:@""]) {
        msg = [[[request requestMessage] URL] query];
    }
    
    NSDictionary* args = [NibwareUrlUtils parseQueryString:msg];
    
    /*
     * /rpc/CLASSNAME/c/CLASSMETHOD
     * /rpc/CLASSNAME/i/INSTANCEID/INSTANCEMETHOD (?)
     *
     * Next version:
     *  /rpc/CONTEXTID/CLASSNAME/[ic]/...
     */
    NSArray *components = [[NitroxHTTPUtils stripLeadingSlash:path] componentsSeparatedByString:@"/"];
    if ([components count] < 2) {
        NSLog(@"Bad arg format: %@", path);
        return [NitroxHTTPResponseMessage emptyResponseWithCode:400];
    }
    
    // NSString *className = [stub className];
    NSString *ic = [components objectAtIndex:0];

    NSString *result;
    @try {
        if ([ic isEqualToString:@"c"]) {
            result = [stub invokeClassMethod:[components objectAtIndex:1] args:args];
        } else if ([ic isEqualToString:@"i"]) {
            result = @"INSTANCE CALLS NOT SUPPORTED YET";
        } else {
            result = @"Incorrect i/c setting";
        }
    } 
    @catch (NSException *ne) { 
        result = [NSString stringWithFormat:@"Caught exception: %@", ne];
        return [NitroxHTTPResponseMessage responseWithBody:[result dataUsingEncoding:NSUTF8StringEncoding] 
                                               contentType:@"text/plain" statusCode:400];
    }
    
    CJSONSerializer *serializer = [[[CJSONSerializer alloc] init] autorelease];
    NSString *response;
    if (result == Nil) {
        response = @"null";
    } else {
        response = [serializer serializeObject:result];
    }
    return [NitroxHTTPResponseMessage responseWithBody:[response dataUsingEncoding:NSUTF8StringEncoding]
                                           contentType:@"application/javascript" statusCode:200];
}

- (void) scheduleCallback:(NitroxRPCCallback *)callback immediate:(BOOL)now
{
    NSLog(@"scheduling callback %@ for %@", callback, now ? @"now" : @"later");
    
    
}

@end
