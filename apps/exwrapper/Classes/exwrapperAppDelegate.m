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


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    NitroxCore *core = [NitroxCore singleton];
    
    [core start];
    
    app = [core createApp];
    [app setParentView:containerView];
    
    [app openApplication:@"nitrox.html"];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[super dealloc];
}

#pragma mark IBActions

- (IBAction) goHome {
    [app openApplication:@"nitrox.html"];
    NSLog(@"goHome called");
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



@end
