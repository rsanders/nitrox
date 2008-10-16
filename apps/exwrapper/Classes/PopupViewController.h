//
//  PopupViewController.h
//  libnitrox
//
//  Created by Robert Sanders on 10/16/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class exwrapperAppDelegate;

@interface PopupViewController : UIViewController {
    IBOutlet exwrapperAppDelegate*   appDelegate;
    IBOutlet UITextField*            textField;
    IBOutlet id                      delegate;
}

- (IBAction) ok;
- (IBAction) cancel;

@property (retain) id delegate;

@end
