//
//  NitroxApiApplication.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 Robert Sanders. All rights reserved.
//

#import "NitroxApiApplication.h"

#import "NitroxWebViewController.h"
#import "NitroxWebView.h"

@implementation NitroxApiApplication

- (NitroxApiApplication *)init
{
    [super init];
    return self;
}

#pragma mark Device specific methods

- (id) openApplication:(NSDictionary *)args
{
    NSString *url = [args objectForKey:@"url"];
    NSLog(@"url in openApplication implementation is %@", url);
    // [[dispatcher webViewController] loadHTMLString:@"<html><body>hi2</body></html>" baseURL:[NSURL URLWithString:@"http://localhost/"]];
    [[dispatcher webViewController] performSelectorOnMainThread:@selector(loadRequest:)
                                                      withObject:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                                   waitUntilDone:NO];

    
    return nil;
}

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

- (id) setApplicationIconBadgeNumber:(NSDictionary *)args
{
    NSString *url = [args objectForKey:@"value"];
    if (! url) {
        NSLog(@"no number supplied to openURL");
        return nil;
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[url integerValue]];
    return nil;
}

- (id) applicationIconBadgeNumber
{

    return [NSNumber numberWithInteger:[[UIApplication sharedApplication] applicationIconBadgeNumber]];
}

- (id) back
{
    NSLog(@"going back");
    [[[dispatcher webViewController] webView] goBack];
    return nil;
}

- (id) forward
{
    NSLog(@"going forward");
    [[[dispatcher webViewController] webView] goForward];
    return nil;
}

#pragma mark app config and path information

- (id) bundleDirectory
{
    return [[NSBundle mainBundle] bundlePath];
}

- (id) documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    return documentsDirectory;
}

- (id) tmpDirectory
{
    return NSTemporaryDirectory();
}

- (id) homeDirectory
{
    return NSHomeDirectory();
}


- (id) translateDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *res = [[NSMutableDictionary alloc] init];
    NSString *key;
    for (key in [dict keyEnumerator]) {
        [res setObject:[dict objectForKey:key] //[NSString stringWithFormat:@"%@", [dict objectForKey:key]] 
                forKey:[NSString stringWithFormat:@"%@", key]];
//        [res setObject:[dict objectForKey:key] forKey:[NSString stringWithFormat:@"%@", key]];
    }
    return [res autorelease];
}

- (id) infoDictionary
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    
    return info; // [self translateDictionary:info];
}

- (id) getInfoValue:(NSDictionary *)args
{
    NSString *key = [args objectForKey:@"name"];
    if (!key) {
        return nil;
    }
    
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
}

- (id) userDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults dictionaryRepresentation];
}

- (id) getUserDefaults:(NSDictionary *)args
{
    NSArray *keys = [args objectForKey:@"names"];
    if (!keys) {
        return nil;
    }

    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSString *key;
    for (key in [keys objectEnumerator]) {
        [results setObject:[[NSUserDefaults standardUserDefaults] objectForKey:key]
                    forKey:key];
    }
    
    return results;
}

- (id) setUserDefaults:(NSDictionary *)args
{
    NSDictionary *defaults = [args objectForKey:@"defaults"];
    if (!defaults) {
        return nil;
    }
    
    NSString *key;
    for (key in [defaults keyEnumerator]) {
        [[NSUserDefaults standardUserDefaults] setObject:[defaults objectForKey:key] forKey:key];
    }
    
    return nil;
}

- (id) getUserDefault:(NSDictionary *)args
{
    NSString *key = [args objectForKey:@"name"];
    if (!key) {
        return nil;
    }
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (id) setUserDefault:(NSDictionary *)args
{
    NSString *key = [args objectForKey:@"name"];
    if (!key) {
        return nil;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[args objectForKey:@"value"]
                                              forKey:key];
    return nil;
}


- (id) appConfiguration
{
    @try {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                [self bundleDirectory], @"bundleDirectory",
                [self documentsDirectory], @"documentsDirectory",
                [self tmpDirectory], @"tmpDirectory",
                [self homeDirectory], @"homeDirectory",
                [self infoDictionary], @"infoDictionary",
                // this is too much stuff, prob also some encoding issues
                // [self userDefaults], @"userDefaults",
            nil];
    } @catch (NSException *e) {
        NSLog(@"caught exception doing appConfiguration: %@", e);
    }
    return @"error";
}

#pragma mark Stub methods; should refactor out



@end
