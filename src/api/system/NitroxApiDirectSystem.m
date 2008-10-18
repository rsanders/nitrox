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
    NSLog(@"JSLOG: %@", msg);
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

// see http://developer.apple.com/documentation/Cocoa/Reference/WebKit/Protocols/WebScripting_Protocol/Reference/Reference.html#//apple_ref/occ/cat/WebScripting
/*
 Overview
 
 WebScripting is an informal protocol that defines methods that classes can implement to export their interfaces 
 to a WebScript environment such as JavaScript.
 
 Not all properties and methods are exported to JavaScript by default. The object need to implement the 
 class methods described below to specify the properties and methods to export. Furthermore, a method 
 is not exported if its return type and all its parameters are not Objective-C objects or scalars.
 
 Method argument and return types that are Objective-C objects will be converted to appropriate types 
 for the scripting environment. For example:
 
 nil is converted to undefined.
 NSNumber objects will be converted to JavaScript numbers.
 NSString objects will be converted to JavaScript strings.
 NSArray objects will be mapped to special read-only arrays.
 NSNull will be converted to JavaScript’s null.
 WebUndefined will be converted to undefined.
 WebScriptObject instances will be unwrapped for the scripting environment.
 Instances of all other classes will be wrapped before being passed to the script, and unwrapped as they 
 return to Objective-C. Primitive types such as int and char are cast to a numeric in JavaScript.
 
 Access to an object’s attributes, such as instance variables, is managed by key-value coding (KVC). The 
 KVC methods setValue:forKey: and valueForKey: are used to access the attributes of an object from the 
 scripting environment. Additionally, the scripting environment can attempt any number of attribute requests 
 or method invocations that are not exported by your class. You can manage these requests by overriding the 
 setValue:forUndefinedKey: and valueForUndefinedKey: methods from the key-value coding protocol.
 
 Exceptions can be raised from the scripting environment by sending a throwException: message to the relevant 
 WebScriptObject instance. The method raising the exception must be within the scope of the script invocation.
 
 
 */
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

@end
