//
//  NitroxApiDirectSystem.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/6/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxApiDirectSystem.h"


@implementation NitroxApiDirectSystem

@synthesize attr;

- (NitroxApiDirectSystem *) init {
    [super init];
    self.attr = @"default attr value";
    return self;
}

- (NSString *) model
{
    return [[UIDevice currentDevice] model];
}

- (void) log:(NSString *)msg
{
    NSLog(@"Direct LOG: %@", msg);
}

- (NSString *) getKey:(NSString *)key fromDictionary:(id)dict
{
    NSLog(@"key is %@, dict is %@", key, dict);
    return [dict valueForKey:key];
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
    //NSLog(@"%@ received %@ for '%@'", self, NSStringFromSelector(_cmd), NSStringFromSelector(selector));
    return NO;
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)property {
    //NSLog(@"%@ received %@ for '%s'", self, NSStringFromSelector(_cmd), property);
    return NO;
}

+ (NSString *) webScriptNameForSelector:(SEL)sel {
    NSLog(@"%@ received %@ with sel='%@'", self, NSStringFromSelector(_cmd), NSStringFromSelector(sel));
    if (sel == @selector(getKey:fromDictionary:)) {
        return @"getKey";
    } else if (sel == @selector(log:)) {
        return @"log";
    }
    else {
        return NSStringFromSelector(sel);
    }
}

@end
