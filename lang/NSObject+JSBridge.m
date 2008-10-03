//
//  NSObject+Reflection.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/1/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NSObject+JSBridge.h"
#import <objc/objc-runtime.h>

@implementation NSObject (JSBridge)

- (NSArray*) methodNamesForClass:(Class)clazz {
    unsigned int count;
    Method * methodList = class_copyMethodList(clazz, &count);    
    NSMutableArray *names = [[NSMutableArray alloc] init];

    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        [names addObject:[NSString stringWithCString:sel_getName(method_getName(method))]];
    }
    
    free(methodList);
    
    return [names autorelease];
}

- (NSArray*) instanceMethodNames {
    return [self methodNamesForClass:[self class]];
}

- (NSArray*) classMethodNames {
    return [self methodNamesForClass:object_getClass([self class])];
}

- (NSString *) serializeToJSON {
}

@end
