//
//  nitroxdemoAppDelegate.h
//  nitroxdemo
//
//  Created by Robert Sanders on 9/26/08.
//  Copyright ViTrue, Inc. 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NitroxApp;

@interface exwrapperAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet NitroxApp*       app;
    IBOutlet UIView*          toplevelView;
    IBOutlet UIView*          containerView;
}

- (IBAction) goHome;
- (IBAction) open;

@end

