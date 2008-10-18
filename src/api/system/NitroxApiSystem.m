//
//  NitroxApiSystem.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 Robert Sanders. All rights reserved.
//

#import "NitroxApiSystem.h"

#import "NitroxRPCDispatcher.h"
#import "NitroxWebViewController.h"
#import "NitroxWebView.h"

@implementation NitroxApiSystem

- (NitroxApiSystem *)init
{
    [super init];
    return self;
}

#pragma mark Device specific methods


- (id) openURL:(NSDictionary *)args
{
    NSString *url = [args objectForKey:@"url"];
    if (! url) {
        NSLog(@"no URL supplied to openURL");
        return Nil;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    return Nil;
}

- (id) exit:(NSDictionary *)args
{
    BOOL hard = [[args objectForKey:@"hard"] boolValue];
    
    if (! hard) {
        NSLog(@"notifying application delegate of intent to exit");
        id<UIApplicationDelegate> appdel = [[UIApplication sharedApplication] delegate];
        if (appdel) {
            [appdel applicationWillTerminate:[UIApplication sharedApplication]];
        }
    }

    NSLog(@"exiting...");
    exit(0);
    return Nil;
}

- (id) setApplicationBadgeNumber:(NSDictionary *)args
{
    NSString *url = [args objectForKey:@"number"];
    if (! url) {
        NSLog(@"no number supplied to openURL");
        return Nil;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[url integerValue]];
    return Nil;
}

- (id) applicationBadgeNumber
{

    return [NSNumber numberWithInteger:[[UIApplication sharedApplication] applicationIconBadgeNumber]];
}

- (id) enableScriptDebugging
{
    [[[[self dispatcher] webViewController] webView] setScriptDebuggingEnabled:YES];
    return Nil;
}

- (id) disableScriptDebugging
{
    [[[[self dispatcher] webViewController] webView] setScriptDebuggingEnabled:NO];
    return Nil;
}

- (id) getEnv:(NSDictionary *)args
{
    NSString *name = [args objectForKey:@"name"];
    if (!name) {
        return Nil;
    }
    
    char *val = getenv([name cStringUsingEncoding:NSISOLatin1StringEncoding]);
    if (! val) {
        return Nil;
    }
    return [NSString stringWithCString:val encoding:NSISOLatin1StringEncoding];
}

- (id) setEnv:(NSDictionary *)args
{
    NSString *name = [args objectForKey:@"name"];
    if (!name) {
        return Nil;
    }
    NSString *value = [args objectForKey:@"value"];
    if (value) {
        setenv([name cStringUsingEncoding:NSISOLatin1StringEncoding],
               [value cStringUsingEncoding:NSISOLatin1StringEncoding], 1);
    } else {
        unsetenv([name cStringUsingEncoding:NSISOLatin1StringEncoding]);
    }
    return Nil;
}

#pragma mark Stub methods; should refactor out



@end
