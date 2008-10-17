//
//  nitroxdemoAppDelegate.m
//  nitroxdemo
//
//  Created by Robert Sanders on 9/26/08.
//  Copyright ViTrue, Inc. 2008. All rights reserved.
//

#import "nitroxdemoAppDelegate.h"
#import "RootViewController.h"
#import "NitroxCore.h"

@implementation nitroxdemoAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
    
    NitroxCore *core = [NitroxCore singleton];
    
    [core start];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
