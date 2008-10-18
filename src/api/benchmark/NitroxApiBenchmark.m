//
//  NitroxApiBenchmark.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 Robert Sanders. All rights reserved.
//

#import "NitroxApiBenchmark.h"


@implementation NitroxApiBenchmark

- (NitroxApiBenchmark *)init
{
    [super init];
    return self;
}

#pragma mark Device specific methods

- (id) invokeClassMethod:(NSString *)method args:(NSDictionary *)args {
    
    NSString *res = nil;
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




@end
