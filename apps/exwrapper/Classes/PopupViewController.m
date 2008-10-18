//
//  PopupViewController.m
//  libnitrox
//
//  Created by Robert Sanders on 10/16/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "PopupViewController.h"

@interface NSObject (PopupViewController)
- (void) popupValueSubmitted:(NSString*)text;
- (void) popupCanceled;
@end

@implementation PopupViewController

@synthesize delegate;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrnil bundle:(NSBundle *)nibBundleOrnil {
    if (self = [super initWithNibName:nibNameOrnil bundle:nibBundleOrnil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

- (void) dismiss {
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
    // [self.view removeFromSuperview];
    // self.view.hidden = YES;
}

- (void) ok {
    NSString *value = [textField text];
    [self dismiss];
    if (delegate && [delegate respondsToSelector:@selector(popupValueSubmitted:)])
    {
        [delegate popupValueSubmitted:value];
    }
}

- (void) cancel {
    [self dismiss];
    if (delegate && [delegate respondsToSelector:@selector(popupCanceled)])
    {
        [delegate popupCanceled];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

@end
