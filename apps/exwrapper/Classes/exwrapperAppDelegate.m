//
//  nitroxdemoAppDelegate.m
//  nitroxdemo
//
//  Created by Robert Sanders on 9/26/08.
//  Copyright ViTrue, Inc. 2008. All rights reserved.
//

#import "exwrapperAppDelegate.h"

#import "NitroxCore.h"
#import "NitroxApp.h"

#import "PopupViewController.h"
#import "MainWindowViewController.h"

@implementation exwrapperAppDelegate

@synthesize homeApp;

- (void) setupPreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (! [defaults boolForKey:@"defaults_set"]) {
        [defaults setBool:YES forKey:@"autoload_home_app"];
        [defaults setObject:@"nitrox.html" forKey:@"home_app"];
        [defaults setBool:YES forKey:@"defaults_set"];
    }
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [self setupPreferences];
    
    self.homeApp = [[NSUserDefaults standardUserDefaults] stringForKey:@"home_app"];

    NitroxCore *core = [NitroxCore singleton];
    
    [core start];
    
    app = [core createApp];
    [app setParentView:containerView];
    
    //window.autoresizesSubviews = YES;
    //window.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleWidth;
    
    if (self.homeApp && [[NSUserDefaults standardUserDefaults] boolForKey:@"autoload_home_app"]) {
        [app openApplication:self.homeApp];
    } else {
        [app openApplication:@"blank.html"];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[super dealloc];
}

#pragma mark IBActions

- (IBAction) goHome {
    NSLog(@"goHome called, homeapp=%@", self.homeApp);
    if (self.homeApp) {
        [app openApplication:self.homeApp];
    }
}

- (IBAction) open {
    NSLog(@"open called");
    popupViewController.view.hidden = NO;
    [mainViewController presentModalViewController:popupViewController animated:YES];
}

- (void) popupCanceled {
    NSLog(@"open url popup canceled");
}

- (void) popupValueSubmitted:(NSString *)text {
    NSLog(@"open url value submitted: %@", text);
    [app openApplication:text];
}

#pragma mark URL handling

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"got new app URL request: %@", url);

    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"nitroxapp"]) {
        NSString *newUrl = [[url absoluteString] stringByReplacingOccurrencesOfString:@"nitroxapp://" 
                                                                           withString:@"http://"];
        [app openApplication:newUrl];
        return YES;
    } else {
        return NO;
    }
}


@end
