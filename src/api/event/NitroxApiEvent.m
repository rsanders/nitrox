//
//  NitroxApiEvent.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 Robert Sanders. All rights reserved.
//

#import "NitroxApiEvent.h"

#import "CJSONDeserializer.h"

@implementation NitroxApiEvent

- (NitroxApiEvent *)init
{
    [super init];
    return self;
}

#pragma mark Device specific methods

- (id) addNotificationListener:(NSDictionary *)args
{
    NSString *name = [args objectForKey:@"name"];
    if (! name) {
        return nil;
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleNotification:) name:name object:nil];
    
    return nil;
}

- (id) removeNotificationListener:(NSDictionary *)args
{
    NSString *name = [args objectForKey:@"name"];
    if (! name) {
        return nil;
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:name object:nil];
    
    return nil;
}

- (id) postNotification:(NSDictionary *)args
{
    NSString *name = [args objectForKey:@"name"];
    if (! name) {
        return nil;
    }

    NSDictionary *userInfo = nil;
    NSString *userInfoString = [args objectForKey:@"userInfo"];
    if (userInfoString) {
        CJSONDeserializer *deserializer = [[[CJSONDeserializer alloc] init] autorelease];
        NSError *outError = nil;
        @try  {
            userInfo = [deserializer deserializeAsDictionary:[userInfoString dataUsingEncoding:NSUTF8StringEncoding]
                                                                 error:&outError];
        } @catch (NSException * e) {
            NSLog(@"could not deserialize userInfo: %@", e);
        }
        if (outError) {
            NSLog(@"error deserializing userInfo: %@", outError);
            userInfo = nil;
        }
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:name object:nil userInfo:userInfo];
    
    return nil;
}


#pragma mark delegate / handler methods
    
- (void) handleNotification:(NSNotification *)notification
{
    NSLog(@"received notification for JS: %@", notification);
    
    NSString *name = [self serialize:[notification name]];
    NSDictionary *dict = [notification userInfo];
    
    NSString *args;
    @try {
        args = [self serialize:dict];
    } @catch (NSException * e) {
        NSLog(@"could not serialize userInfo: %@", e);
        args = @"{}";
    }
    
    [self scheduleCallbackScript:[NSString stringWithFormat:@"Nitrox.Event._receiveNotification(%@, %@)",
                                  name, args]];
}

#pragma mark Stub methods; should refactor out



@end
