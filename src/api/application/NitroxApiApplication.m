//
//  NitroxApiApplication.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 Robert Sanders. All rights reserved.
//

#import "NitroxApiApplication.h"


@implementation NitroxApiApplication

- (NitroxApiApplication *)init
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
}

- (id) applicationBadgeNumber
{

    return [NSNumber numberWithInteger:[[UIApplication sharedApplication] applicationBadgeNumber]];
}

#pragma mark Stub methods; should refactor out



@end