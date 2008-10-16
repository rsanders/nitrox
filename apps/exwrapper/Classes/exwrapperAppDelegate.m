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

@implementation exwrapperAppDelegate


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    app = [[NitroxApp alloc] init];
    
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//    [window addSubview:toplevelView];
//    [window makeKeyAndVisible];

	// Configure and show the window
	//[window addSubview:[navigationController view]];
	//[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[super dealloc];
}

#pragma mark IBActions

- (IBAction) goHome {
    NSLog(@"goHome called");
}

- (IBAction) open {
    NSLog(@"open called");
}

@end
