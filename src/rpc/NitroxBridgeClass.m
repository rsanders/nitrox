//
//  NitroxBridgeClass.m
//
//  Created by Robert Sanders
//

#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>

#import "NitroxApp.h"

#import "Nibware.h"

#import "NitroxBridgeClass.h"

#import "NitroxRPCDispatcher.h"

#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

// #import "NSObject+JSBridge.h"

#import "GTMObjC2Runtime.h"


typedef union {
    id objectValue;
    bool booleanValue;
    char charValue;
    short shortValue;
    int intValue;
    long longValue;
    long long longLongValue;
    float floatValue;
    double doubleValue;
    void *arrayValue;
    char *stringValue;
    void *ptrValue;
} ObjcValue;


@implementation NitroxBridgeClass

@synthesize app;

#pragma mark initialization

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

- (void) dealloc
{
    self.app = nil;
    [super dealloc];
}

#pragma mark Standard WebScriptObject protocol methods

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

#pragma mark Nitrox Bridge reflection methods

// TODO: support more reference types
- (id) resolveObjectRef:(id)ref
{
    id target = nil;
    if ([ref isKindOfClass:[NSString class]]) {
        target = [[self.app symbolTable] valueForKeyPath:ref];
    } else {
        NSLog(@"cannot resolve object ref, using literally: %@", target);
        target = ref;
    }
    
    return target;
}

// only works for all string args
// see http://developer.apple.com/documentation/Cocoa/Conceptual/ObjectiveC/Articles/chapter_13_section_9.html#//apple_ref/doc/uid/TP30001163-CH9-TPXREF165

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
- (NSArray *)convertArguments:(NSArray *)parameters bySignature:(NSMethodSignature *)signature
{
    
    for (int i = 0; i < [signature numberOfArguments]-2; i++)
    {
        const char *argType = [signature getArgumentTypeAtIndex:i+2];
        NSLog(@"argument type at idx %d is %s, provided type is %@", 
              i, argType, [[parameters objectAtIndex:i] class]);
    }
    
    return parameters;
}

- (BOOL)copyArguments:(NSArray *)parameters 
       intoInvocation:(NSInvocation*)invocation 
          bySignature:(NSMethodSignature *)signature
{
    NSAssert([signature numberOfArguments]-2 == [parameters count],
             @"Check signature and provided param count match exactly");

    for (int i = 0; i < [signature numberOfArguments]-2; i++)
    {
        const char *argType = [signature getArgumentTypeAtIndex:i+2];
        NSLog(@"argument type at idx %d is %s, provided type is %@", 
              i, argType, [[parameters objectAtIndex:i] class]);

        // TODO: convert other types, e.g. numerics, C string, bool, array
        NSObject *obj = [parameters objectAtIndex:i];
        [invocation setArgument:&obj atIndex:i+2];
    }    
    
    return YES;
}



- (id) invokeMethod:(NSString *)method withTarget:(id)target parameters:(NSArray *)parameters 
{
    NSObject *res = nil;
    
    if (! parameters || ! [parameters isKindOfClass:[NSArray class]]) {
        NSLog(@"parameters is %@, not an array", parameters);
        [NSException raise:@"NSGenericException" format:@"Bad paramaters for method: %@", method];
    }
    
    SEL sel;
    if ([target respondsToSelector:@selector(selectorForWebScriptName:)])
    {
        sel = [target selectorForWebScriptName:method];
    } else {
        sel = NSSelectorFromString(method);
    }
    
    // TODO: check for explicit exports here
    if (! sel || ! [target respondsToSelector:sel]) {
        NSLog(@"call to bad method %@", method);
        [NSException raise:@"NitroxNoSuchMethod" format:@"No such method: %@", method];
    }
    
    NSMethodSignature *signature = [target methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setTarget:target];
    [invocation setSelector:sel];
    
    NSLog(@"got signature %@, invocation %@", signature, invocation);
    
    if ([signature numberOfArguments] != [parameters count] + 2) {
        NSLog(@"signature takes %d args, have %d parameters",
              [signature numberOfArguments]-2, [parameters count]);
        // TODO throw exception here?
        return nil;
    }
    
    BOOL copyRes = [self copyArguments:parameters intoInvocation:invocation bySignature:signature];

    if (! copyRes) {
        // TODO: throw exception here?
        NSLog(@"failed to copy/convert arguments, failing to invoke");
        return NO;
    }
    
    [invocation invoke];
    
    // no return value
    if (!strcmp([signature methodReturnType], "v")) {
        NSLog(@"void function");
        return nil;
    }
    
    ObjcValue returnValue;
    [invocation getReturnValue:&returnValue];
    NSLog(@"invocation result is %@", res);
    
    return returnValue.objectValue;
}

- (id)invoke:(NSString *)method withTarget:(id)object parameters:(NSArray*)parameters
{
    NSLog(@"invoking %@ on target %@ with parameters %@",
          method, object, parameters);
    
    id target = [self resolveObjectRef:object];

    if (!target) {
        NSLog(@"cannot resolve object reference: %@", object);
        return nil;
    }
    
    return [self invokeMethod:method withTarget:target parameters:parameters];
}

#pragma mark Introspection

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

- (NSArray*) instanceMethodNames:(id)target {
    NSArray *names = [self methodNamesForClass:[target class]];
    
    if ([target respondsToSelector:@selector(webScriptNameForSelector:)]) {
        NSMutableArray *xlated = [[NSMutableArray alloc] initWithCapacity:[names count]];
        
        NSString* name;
        for (name in names) {
            NSString* xname = [target webScriptNameForSelector:NSSelectorFromString(name)];
            [xlated addObject:(xname ? xname : name)];
        }
        
        names = [xlated autorelease];
    }
    
    return names;
}

- (NSArray*) classMethodNames:(id)target {
    return [self methodNamesForClass:object_getClass([target class])];
}

- (NSArray*) propertyNamesForClass:(Class)cls {
    unsigned int outCount;
    objc_property_t *plist =  class_copyPropertyList(cls, &outCount);
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:outCount];
    for (int i = 0; i < outCount; i++)
    {
        [names addObject:[NSString stringWithCString:property_getName(plist[i]) encoding:NSUTF8StringEncoding]];
    }
    free(plist);
    return [names autorelease];
}

- (NSArray*) propertyNames:(id) target {
    NSMutableArray* allNames = [[NSMutableArray alloc] init];
    
    Class cls = [target class];
    while (cls != Nil ) 
    {
        [allNames addObjectsFromArray:[self propertyNamesForClass:cls]];
        cls = class_getSuperclass(cls);
    }
         
    return [allNames autorelease];
}         

- (id) describeObject:(id)objectRef
{
    id target = [self resolveObjectRef:objectRef];

    if (!target) {
        return @"null";
    }
    
    NSMutableDictionary *dict = 
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            NSStringFromClass([target class]), @"__type",
            [NSString stringWithFormat:@"0x%x", target], @"__ptr", 
            [self instanceMethodNames:target], @"instanceMethods", 
         // TODO: this doesn't seem to work at all, or at least not recursively
            [self classMethodNames:target], @"classMethods", 
            [self propertyNames:target], @"properties",
            [NSNumber numberWithInteger:[target retainCount]], @"retaincount",
         nil];

    return [dict autorelease];
}

#pragma mark Callback methods

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

#pragma mark (De)serialization methods

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
