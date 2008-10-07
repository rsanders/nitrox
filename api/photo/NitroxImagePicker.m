//
//  NitroxImagePicker.m
//  Nitrox
//
//  Created by Robert Sanders on 9/15/08.
//  Copyright 2008 Robert Sanders. All rights reserved.
//

#import "NitroxImagePicker.h"


#import "NibwareLog.h"



@implementation NitroxImagePicker

@synthesize mainController;
@synthesize delegate;

-(UIView *) view {
    return myView;
}

-(void) showInView:(UIView *)view {
    myView = [[UIActionSheet alloc] 
              initWithTitle:@"Pick Photo Source"
              delegate:self 
              cancelButtonTitle:@"Cancel"
              destructiveButtonTitle:nil
              otherButtonTitles:
                @"Photo from Album",
                @"Take with Camera",
                nil];
    myView.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    mainView = view;
    [myView setDelegate:self];
    [myView showInView:view];
}



-(void) dismiss {
    [myView dismissWithClickedButtonIndex:-1 animated:NO];
}


- (void) pickExistingPhoto {
    [self pickPhoto:YES];
}

- (void) pickNewPhoto {
    [self pickPhoto:NO];
}

-(void) pickPhoto:(BOOL)existing 
{
    realPicker = [[UIImagePickerController alloc] init];
    realPicker.delegate=self;
    
    if (existing || ! [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [realPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    } else {
        [realPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }

    realPicker.view.hidden = NO;
    [[[UIApplication sharedApplication] keyWindow] insertSubview:realPicker.view atIndex:0];
    [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:realPicker.view];
}

-(void) cancel {
    [self dismiss];
    [delegate imagePickerControllerDidCancel:realPicker];
}


#pragma mark UIActionSheetDelegate fields

- (void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [myView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    NSLog(@"picked button index %d", buttonIndex);
    
    if (buttonIndex == sheet.cancelButtonIndex || buttonIndex == sheet.destructiveButtonIndex) {
        NSLog(@"Canceling photo selection");
        return;
    }
    
    buttonIndex -= [sheet firstOtherButtonIndex];
    
    NSLog(@"other button index = %d", buttonIndex);
    
    switch (buttonIndex) {
        case 0:
            [self pickExistingPhoto];
            break;
        case 1:
            [self pickNewPhoto];
            break;
        default:
            NSLog(@"Unhandled other button index %d", buttonIndex);
            break;
    }
}


#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)thispicker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    NSLog(@"Picked an image in PIP!");
    
    //[thispicker dismissModalViewControllerAnimated:YES];
    thispicker.view.hidden = YES;
    [[thispicker parentViewController] dismissModalViewControllerAnimated:YES];
    
    [thispicker popToRootViewControllerAnimated:YES];
    [thispicker.view resignFirstResponder];
    [thispicker.view removeFromSuperview];
    
    [image retain];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              image, @"image",
                              nil];
    [center postNotificationName:@"photo_picked" object:self userInfo:userInfo];
    
    [delegate imagePickerController:thispicker didFinishPickingImage:image editingInfo:editingInfo];
    
    [image release];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)thispicker {
    NSLog(@"Canceled picking an image in PIP");
    
    [thispicker dismissModalViewControllerAnimated:YES];
    [delegate imagePickerControllerDidCancel:thispicker];
}

#pragma mark -

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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
    // [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [myView setDelegate:nil];
    [super dealloc];
}


@end
