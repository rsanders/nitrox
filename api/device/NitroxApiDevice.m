//
//  NitroxApiPhoto.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxApiDevice.h"


@implementation NitroxApiDevice

- (NitroxApiDevice *)init
{
    [super init];
    return self;
}

#pragma mark Device specific methods

- (id) invokeClassMethod:(NSString *)method args:(NSDictionary *)args {
    
    NSString *res = Nil;
    UIDevice *device = [UIDevice currentDevice];
    
    SEL sel = NSSelectorFromString( [method stringByAppendingString:@":"] );       
    if ([device respondsToSelector:sel]) {
        res = [device performSelector:sel withObject:args];
    } else if ([device respondsToSelector:(sel = NSSelectorFromString(method))]) {
        res = [device performSelector:sel];
    } else {
        res = [super invokeClassMethod:method args:args];
    }
    
    return res;
}

#pragma mark Stub methods; should refactor out


- (NSString *) className {
    return @"Device";
}

- (NSString *) instanceMethods {
    return Nil;
}

- (NSString *) classMethods {
    return Nil;
}

- (id) newInstance {
    return Nil;
}

- (id) newInstanceWithArgs:(NSDictionary *)args {
    return Nil;
}




@end
