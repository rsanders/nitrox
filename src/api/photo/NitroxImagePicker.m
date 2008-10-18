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

@synthesize delegate;
@synthesize hostingController;

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

    [hostingController presentModalViewController:realPicker animated:YES];
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
        [delegate imagePickerControllerDidCancel:realPicker];
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
            [delegate imagePickerControllerDidCancel:realPicker];
            break;
    }
}


#pragma mark UIImagePickerControllerDelegate methods

- (void) hidePicker:(UIImagePickerController *)thispicker {
    [hostingController dismissModalViewControllerAnimated:YES];
    
//    [thispicker popToRootViewControllerAnimated:YES];
//    [thispicker.view resignFirstResponder];
//    [thispicker.view removeFromSuperview];
//    thispicker.view.hidden = YES;
}

- (void)imagePickerController:(UIImagePickerController *)thispicker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    // NSLog(@"Picked an image in PIP!");
    
    [image retain];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              image, @"image",
                              nil];
    [center postNotificationName:@"photo_picked" object:self userInfo:userInfo];
    
    [delegate imagePickerController:thispicker didFinishPickingImage:image editingInfo:editingInfo];
    
    [image release];
    
    [self hidePicker:thispicker];    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)thispicker {
    NSLog(@"Canceled picking an image in PIP");
    
    [self hidePicker:thispicker];
    [delegate imagePickerControllerDidCancel:thispicker];
}

#pragma mark -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    // [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    self.hostingController = nil;
    self.delegate = nil;
    [myView setDelegate:nil];
    [myView release];
    [mainView release];
    [realPicker release];

    [super dealloc];
}


@end
