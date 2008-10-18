//
//  NitroxStubClass.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxStubClass.h"

#import "NitroxRPCDispatcher.h"

#import "CJSONSerializer.h"

@implementation NitroxStubClass

@synthesize dispatcher;

- (NSString *) className {
    return [NSStringFromClass([self class]) stringByReplacingOccurrencesOfString:@"NitroxApi" withString:@""];
}

- (NSString *) instanceMethods {
    return nil;
}

- (NSString *) classMethods {
    return nil;
}

- (id) newInstance {
    return nil;
}

- (id) newInstanceWithArgs:(NSDictionary *)args {
    return nil;
}

- (id) object:(id)object invoke:(NSString *)method args:(NSDictionary *)args {
    return nil;
}

- (id) invokeClassMethod:(NSString *)method args:(NSDictionary *)args {
    
    NSString *res = nil;

    SEL sel = NSSelectorFromString( [method stringByAppendingString:@":"] );       
    if ([self respondsToSelector:sel]) {
        res = [self performSelector:sel withObject:args];
    } else if ([self respondsToSelector:(sel = NSSelectorFromString(method))]) {
        res = [self performSelector:sel];
    } else {
        NSLog(@"call to bad method %@", method);
        [NSException raise:@"NitroxNoSuchMethod" format:@"No such method: %@", method];
    }
    
    return res;
}

- (void) scheduleCallbackScript:(NSString *)jsscript
{
    [self.dispatcher scheduleCallback:[NitroxRPCCallback callbackWithString:jsscript]
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


@end
