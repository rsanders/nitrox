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
        return nil;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    return nil;
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
    return nil;
}

- (id) setApplicationBadgeNumber:(NSDictionary *)args
{
    NSString *url = [args objectForKey:@"number"];
    if (! url) {
        NSLog(@"no number supplied to openURL");
        return nil;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[url integerValue]];
    return nil;
}

- (id) applicationBadgeNumber
{

    return [NSNumber numberWithInteger:[[UIApplication sharedApplication] applicationIconBadgeNumber]];
}

- (id) enableScriptDebugging
{
    [[[[self dispatcher] webViewController] webView] setScriptDebuggingEnabled:YES];
    return nil;
}

- (id) disableScriptDebugging
{
    [[[[self dispatcher] webViewController] webView] setScriptDebuggingEnabled:NO];
    return nil;
}

- (id) getEnv:(NSDictionary *)args
{
    NSString *name = [args objectForKey:@"name"];
    if (!name) {
        return nil;
    }
    
    char *val = getenv([name cStringUsingEncoding:NSISOLatin1StringEncoding]);
    if (! val) {
        return nil;
    }
    return [NSString stringWithCString:val encoding:NSISOLatin1StringEncoding];
}

- (id) setEnv:(NSDictionary *)args
{
    NSString *name = [args objectForKey:@"name"];
    if (!name) {
        return nil;
    }
    NSString *value = [args objectForKey:@"value"];
    if (value) {
        setenv([name cStringUsingEncoding:NSISOLatin1StringEncoding],
               [value cStringUsingEncoding:NSISOLatin1StringEncoding], 1);
    } else {
        unsetenv([name cStringUsingEncoding:NSISOLatin1StringEncoding]);
    }
    return nil;
}

#pragma mark Stub methods; should refactor out



@end
