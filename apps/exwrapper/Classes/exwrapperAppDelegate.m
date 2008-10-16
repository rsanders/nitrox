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
}

@end
