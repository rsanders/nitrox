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

#pragma mark Photo specific methods

- (id) invokeClassMethod:(NSString *)method args:(NSDictionary *)args {
    SEL sel = NSSelectorFromString(method);
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *res = @"no result";
    
    if ([device respondsToSelector:sel]) {
        res = [device performSelector:sel];
    }
    
    return res;
}

- (id) invoke:(NSString *)method args:(NSDictionary *)args {
    return Nil;
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
