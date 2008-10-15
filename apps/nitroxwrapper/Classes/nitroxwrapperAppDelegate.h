//
//  nitroxdemoAppDelegate.h
//  nitroxdemo
//
//  Created by Robert Sanders on 9/26/08.
//  Copyright ViTrue, Inc. 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface nitroxwrapperAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

