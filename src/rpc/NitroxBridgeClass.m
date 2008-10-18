//
//  NitroxBridgeClass.m
//
//  Created by Robert Sanders
//

#import "NitroxApp.h"

#import "Nibware.h"

#import "NitroxBridgeClass.h"

#import "NitroxRPCDispatcher.h"

#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>

@implementation NitroxBridgeClass

@synthesize app;

- (NitroxBridgeClass *) initWithApp:(NitroxApp*)newapp
{
    [super init];
    self.app = newapp;
    return self;
}

- (NitroxWebViewController *) webViewController
{
    return app.webViewController;
}


// this is an apple method which we'd have to invert
+ (NSString *) webScriptNameForSelector:(SEL)sel {
    // NSLog(@"%@ received %@ with sel='%@'", self, NSStringFromSelector(_cmd), NSStringFromSelector(sel));
    if (sel == @selector(getKey:fromDictionary:)) {
        return @"getKey";
    } else if (sel == @selector(log:)) {
        return @"log";
    }
    else {
        return NSStringFromSelector(sel);
    }
}

// this is a quick hack which should invert the standard Apple bridge function
+ (SEL) selectorForWebScriptName:(NSString *)name {
    return NSSelectorFromString(name);
}

- (NSArray *)convertArguments:(NSArray *)parameters bySignature:(NSMethodSignature *)signature
{
    // only works for all string args
    return parameters;
}


- (id) invokeClassMethod:(NSString *)method args:(NSDictionary *)args {
    NSObject *res = Nil;
    NSString *paramstring = [args objectForKey:@"parameters"];
    CJSONDeserializer *deserializer = [[CJSONDeserializer alloc] init];
    NSError *error;
    NSArray *parameters;
    
    @try {
        parameters = [deserializer deserialize:[paramstring dataUsingEncoding:NSUTF8StringEncoding]
                                              error:&error];
    } @catch (NSException *e) {
        NSLog(@"caught exception deserializing: %@", e);
        return Nil;
    }
    
    if (! parameters || ! [parameters isKindOfClass:[NSArray class]]) {
        NSLog(@"parameters is %@, not an array", parameters);
        [NSException raise:@"NSGenericException" format:@"Bad paramaters for method: %@", method];
    }

    SEL sel = [[self class] selectorForWebScriptName:method];
    
    // TODO: check for explicit exports here
    if (! sel || ! [self respondsToSelector:sel]) {
        NSLog(@"call to bad method %@", method);
        [NSException raise:@"NitroxNoSuchMethod" format:@"No such method: %@", method];
    }
    
    NSMethodSignature *signature = [self methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setTarget:self];
    [invocation setSelector:sel];

    NSLog(@"got signature %@, invocation %@", signature, invocation);

    if ([signature numberOfArguments] != [parameters count] + 2) {
        NSLog(@"signature takes %d args, have %d parameters",
              [signature numberOfArguments]-2, [parameters count]);
        return Nil;
    }
    
    NSArray *converted = [self convertArguments:parameters bySignature:signature];

    for (int i = 0; i < [converted count]; i++)
    {
        NSObject *obj = [converted objectAtIndex:i];
        [invocation setArgument:&obj atIndex:i+2];
    }
    
    [invocation invoke];
    
    [invocation getReturnValue:&res];
    NSLog(@"invocation result is %@", res);
    
    return res;
}

- (void) scheduleCallback:(NitroxRPCCallback *)callback immediate:(BOOL)now
{
    [app.webViewController  performSelectorOnMainThread:@selector(scheduleCallback:)
                        withObject:callback waitUntilDone:now];
}

- (void) scheduleCallbackScript:(NSString *)jsscript
{
    [self scheduleCallback:[NitroxRPCCallback callbackWithString:jsscript]
                            immediate:NO];
}

- (NSString *) serialize:(id)object
{
    
    CJSONSerializer *serializer = [[[CJSONSerializer alloc] init] autorelease];    
    
    return [serializer serializeObject:object];
}

- (id) boolObject:(BOOL)val
{
    return [NitroxBool objectForBool:val];
}

#pragma mark test method

- (NSNumber *) add:(NSNumber *)num1 and:(NSNumber *)num2
{
    return [NSNumber numberWithDouble:([num1 doubleValue] + [num2 doubleValue])];
}

- (NSString *) concat:(NSString *)str1 and:(NSString *)str2
{
    return [str1 stringByAppendingString:str2];
}


#pragma mark NitroxHTTPDelegate methods


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
    
    CJSONSerializer *serializer = [[[CJSONSerializer alloc] init] autorelease];    
    
    // NSString *className = [stub className];
    NSString *ic = [components objectAtIndex:0];
    
    NSString *result;
    @try {
        if ([ic isEqualToString:@"c"]) {
            result = [self invokeClassMethod:[components objectAtIndex:1] args:args];
        } else if ([ic isEqualToString:@"i"]) {
            result = @"INSTANCE CALLS NOT SUPPORTED YET";
        } else {
            result = @"Incorrect i/c setting";
        }
    } 
    @catch (NSException *ne) { 
        result = [NSString stringWithFormat:@"Caught exception: %@", ne];
        NSLog(@"raised exception invoking method in NitroxBridgeClass: %@", result);
        return [NitroxHTTPResponseMessage responseWithBody:[[serializer serializeString:result] dataUsingEncoding:NSUTF8StringEncoding]
                                               contentType:@"text/plain" statusCode:400];
    }
    
    NSLog(@"response is %@", result);
    
    NSString *response;
    if (result == Nil) {
        response = @"null";
    } else {
        response = [serializer serializeObject:result];
    }
    return [NitroxHTTPResponseMessage responseWithBody:[response dataUsingEncoding:NSUTF8StringEncoding]
                                           contentType:@"application/javascript" statusCode:200];
}



@end
