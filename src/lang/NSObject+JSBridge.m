//
//  NSObject+Reflection.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/1/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NSObject+JSBridge.h"

#import "GTMObjC2Runtime.h"

#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

// #import <objc/objc-runtime.h>

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

// TODO: incomplete
- (NSString *) serializeToJSON {
    CJSONSerializer *serializer = [[[CJSONSerializer alloc] init] autorelease];    
    
    return [serializer serializeObject:self];
}

+ (id) unserializeFromJSON:(NSString *)json {
    CJSONDeserializer *deserializer = [[[CJSONDeserializer alloc] init] autorelease];    
    
    NSError *error;
    id retval = [deserializer deserialize:[json dataUsingEncoding:NSUTF8StringEncoding]
                               error:&error];
    if (error) {
        NSLog(@"failed to deserialize in class %@ from json: %@", 
              NSStringFromClass([self class]), json);
        return nil;
    } else {
        return retval;
    }
    
}


@end
