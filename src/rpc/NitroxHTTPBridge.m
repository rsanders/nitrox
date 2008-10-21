//
//  NitroxHTTPBridge.m
//  libnitrox
//
//  Created by Robert Sanders on 10/20/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxHTTPBridge.h"

#import "NitroxApp.h"

#import "Nibware.h"

#import "NitroxBridgeClass.h"

#import "NitroxRPCDispatcher.h"

#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "NitroxFallbackJSONSerializer.h"


@implementation NitroxHTTPBridge

@synthesize bridge;

- (NitroxHTTPBridge *) initWithBridge:(NitroxBridgeClass *)newbridge
{
    [super init];
    self.bridge = newbridge;
    return self;
}

- (void) dealloc
{
    self.bridge = Nil;
    [super dealloc];
}

#pragma mark NitroxHTTPDelegate method

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
    
    NSString *query = [[[request requestMessage] URL] query];
    
    // need to separate id and token and other args
    if (query && ![query isEqualToString:@""]) {
        msg = [[[request requestMessage] URL] query];
    }
    
    NSDictionary* args = [NibwareUrlUtils parseQueryString:msg];
    
    /*
     * 0. turn HTTP request into general request, then
     *    call method which...
     * 1. lookup object in symboltable
     * 2. invoke methods on it (using our method or its)
     * 3. process 
     *
     *
     *
     */
    
    /*
     * _app/<APPID>/invoke?object=<jsonstring_or_object>&method=<string>&parameters=<jsonarray>
     *
     */
    
    CJSONDeserializer *deserializer = [[[CJSONDeserializer alloc] init] autorelease];        
    CJSONSerializer *serializer = [[[CJSONSerializer alloc] init] autorelease];    
    serializer.fallbackSerializer = [[[NitroxFallbackJSONSerializer alloc] init] autorelease];

    NSString* sobjkey = [args objectForKey:@"object"];         // JSON string or object
    NSError *error = nil;
    id object = [deserializer deserialize:[sobjkey dataUsingEncoding:NSUTF8StringEncoding]
                                    error:&error];
    if (!object) {
        @throw [NSException exceptionWithName:@"NitroxEncodingException"
                                       reason:@"Cannot decode object ref"
                                     userInfo:nil];
    }

    id result;
    if ([path isEqualToString:@"invoke"]) {
        NSString* method = [args objectForKey:@"method"];         // plain string
        NSString* sparameters = [args objectForKey:@"parameters"];  // JSON array

        NSArray *parameters;
        
        if (sparameters && ! [sparameters isEqualToString:@""]) {
            parameters = [deserializer deserialize:[sparameters dataUsingEncoding:NSUTF8StringEncoding]
                                             error:&error];
            if (!parameters || ![parameters isKindOfClass:[NSArray class]]) {
                @throw [NSException exceptionWithName:@"NitroxEncodingException"
                                               reason:@"Cannot decode parameters array"
                                             userInfo:nil];
            }
        } else {
            parameters = [[[NSArray alloc] init] autorelease];
        }
        
        @try {
            result = [bridge invoke:method withTarget:object parameters:parameters];
        } 
        @catch (NSException *ne) { 
            result = [NSString stringWithFormat:@"Caught exception: %@", ne];
            NSLog(@"raised exception invoking method in NitroxBridgeClass: %@", result);
            // TODO: gateway exception into Javascript
            return [NitroxHTTPResponseMessage responseWithBody:[[serializer serializeString:result] dataUsingEncoding:NSUTF8StringEncoding]
                                                   contentType:@"text/plain" statusCode:400];
        }
    } 
    else if ([path isEqualToString:@"describe"]) {
        NSLog(@"describing object: %@", object);
        result = [bridge describeObject:object];
    }
    else {
        NSLog(@"unknown bridge operation: %@", path);
        result = nil;
    }
    
    NSLog(@"response is %@", result);
    
    NSString *response;
    if (result == nil) {
        response = @"null";
    } else {
        response = [serializer serializeObject:result];
    }
    return [NitroxHTTPResponseMessage responseWithBody:[response dataUsingEncoding:NSUTF8StringEncoding]
                                           contentType:@"application/javascript" statusCode:200];
}



@end
