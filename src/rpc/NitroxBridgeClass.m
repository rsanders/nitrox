//
//  NitroxBridgeClass.m
//
//  Created by Robert Sanders
//

#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>

#import <strings.h>

#import "NitroxApp.h"

#import "Nibware.h"

#import "NitroxBool.h"

#import "NitroxBridgeClass.h"

#import "NitroxRPCDispatcher.h"

#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

#import "GTMObjC2Runtime.h"

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

/* Mappings:  (see http://tinyurl.com/6285f9)
 *
 * NSNumber  <=>   c,i,s,l,q,C,I,S,L,Q,f,d
 * boolean?  (B, c/C
 * NSNull  <->  v (void)
 * NSDictionary, NSString, NSArray, NSNull, id <=>  @
 * NSString <->  *
 * NSString <->  :  (selector)
 * NSArray <->   [type]  (array)
 *
 * Unmapped: # (Class object), ? (unknown), ^type (pointers), {types} (structs)
 *
 */

/*
 *
 * CGRect shows as:
 *     {CGRect={CGPoint=ff}{CGSize=ff}}
 *
 * xlate to?  [[5.0, 4.0], [9.0, 0.0]]
 *
 */ 

- (NSInteger) extractInt:(id) object
{
    if ([object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber*)object integerValue];
    } else if ([object respondsToSelector:@selector(integerValue)]) {
        return [(NSNumber*)object integerValue];
    } else {
        NSLog(@"couldn't covert object %@ of type %@ to integer", 
              object, [object class]);
        return -1;
    }
}

- (double) extractDouble:(id) object
{
    if ([object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber*)object doubleValue];
    } else if ([object respondsToSelector:@selector(doubleValue)]) {
        return [(NSNumber*)object doubleValue];
    } else {
        NSLog(@"couldn't covert object %@ of type %@ to double", 
              object, [object class]);
        return -1;
    }
}

- (BOOL) extractBOOL:(id) object
{
    if ([object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber*)object boolValue];
    } else if ([object respondsToSelector:@selector(boolValue)]) {
        return [(NSNumber*)object boolValue];
    } else {
        NSLog(@"couldn't covert object %@ of type %@ to double", 
              object, [object class]);
        return NO;
    }
}

- (NSString*) extractString:(id) object
{
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else if ([object respondsToSelector:@selector(stringValue)]) {
        return [(NSNumber*)object stringValue];
    } else {
        NSLog(@"couldn't covert object %@ of type %@ to double", 
              object, [object class]);
        return [NSString stringWithFormat:@"%@", object];
    }
}

/*
 * Converts native C/Obj-C types to the types we pass into
 * Javascript; mostly NSNumber, NSString, NitroxBool
 *
 * TODO: NSArray <-> [type] array
 *
 */
- (id) convertValue:(ObjcValue) value
     toObjectOfType:(const char *) type
{
    id object = nil;
    
    if (strlen(type) != 1) {
        NSLog(@"type is not a single char, bailing: %s", type);
        return object;
    }
    
    // TODO: handle multi-char types
    char typechar = type[0];
    
    switch (typechar) 
    {
            // numerics
        case 'c':
        case 'C':
            object = [NSNumber numberWithChar:value.charValue];
            break;
            
        case 'i':
        case 'I':
            object = [NSNumber numberWithInt:value.intValue];
            break;
            
        case 's':
        case 'S':
            object = [NSNumber numberWithShort:value.shortValue];
            break;
            
        case 'l':
        case 'L':
            object = [NSNumber numberWithLong:value.longValue];
            break;
            
        case 'q':
        case 'Q':
            object = [NSNumber numberWithLongLong:value.longLongValue];
            break;
            
        case 'f':
            object = [NSNumber numberWithFloat:value.floatValue];
            break;
            
        case 'd':
            object = [NSNumber numberWithDouble:value.doubleValue];
            break;
            
            // C99 boolean
        case 'B':
            // object = [NSNumber numberWithBool:(value.booleanValue ? YES : NO)];
            object = [NitroxBool objectForBool:(value.booleanValue ? YES : NO)];
            break;
            
            // object - TODO: make this work for array and dict types (?)
        case '@':
            object = value.objectValue;
            break;
            
            // C string
        case '*':
            object = [NSString stringWithCString:value.stringValue encoding:NSUTF8StringEncoding];
            break;
            
            // selector
        case ':':
            object = NSStringFromSelector(value.selectorValue);
            break;

        case '#':
            object = NSStringFromClass(value.classValue);
            break;
            
        default:
            NSLog(@"unhandled type %s", type);
            return object;
    }
    
    return object;
}

/*
 * Converts JSON-decoded objects from Javascript into native 
 * C/Obj-C types Javascript; mostly handles NSNumber, NSString
 *
 * TODO: NSArray <-> [type] array
 */
- (ObjcValue) convertObject:(id) object
                     toType:(const char *)type
{
    ObjcValue value;
    memset(&value, 0, sizeof(value));
    
    if (strlen(type) != 1) {
        NSLog(@"type is not a single char, bailing: %s", type);
        return value;
    }
    
    // TODO: handle multi-char types
    char typechar = type[0];
    
    switch (typechar) 
    {
        // numerics
        case 'c':
        case 'C':
            value.charValue = [self extractInt:object];
            break;

        case 'i':
        case 'I':
            value.intValue = [self extractInt:object];
            break;

        case 's':
        case 'S':
            value.shortValue = [self extractInt:object];
            break;

        case 'l':
        case 'L':
            value.longValue = [self extractInt:object];
            break;

        case 'q':
        case 'Q':
            value.longLongValue = [self extractInt:object];
            break;

        case 'f':
            value.floatValue = [self extractDouble:object];
            break;
            
        case 'd':
            value.doubleValue = [self extractDouble:object];
            break;
            
        // C99 boolean
        case 'B':
            value.booleanValue = [self extractBOOL:object] ?
                                 true : false;
            break;
    
        // object
        case '@':
            value.objectValue = object;
            break;
            
        // C string
        case '*':
            value.stringValue = [[self extractString:object] cStringUsingEncoding:NSUTF8StringEncoding];
            break;
            
        // selector
        case ':':
            value.selectorValue = NSSelectorFromString([self extractString:object]);
            break;
        
        case '#':
            value.classValue = NSClassFromString([self extractString:object]);
            break;
            
        default:
            NSLog(@"unhandled type %s", type);
            return value;
    }
    
    return value;
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

        ObjcValue val = [self convertObject:[parameters objectAtIndex:i] toType:(char *)argType];
        
        // TODO: convert other types, e.g. numerics, C string, bool, array
        // NSObject *obj = [parameters objectAtIndex:i];
        [invocation setArgument:&val atIndex:i+2];
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
    res = [self convertValue:returnValue toObjectOfType:[signature methodReturnType]];
    NSLog(@"invocation result is %@, type %s, class %@", 
          res, [signature methodReturnType], [res class]);
    
    return res;
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
