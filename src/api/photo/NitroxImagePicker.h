//
//  NitroxImagePicker.h
//  Nitrox
//
//  Created by Robert Sanders on 9/15/08.
//  Copyright 2008 Robert Sanders. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NitroxImagePicker : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIImagePickerController *realPicker;
    IBOutlet UIActionSheet *myView;
    IBOutlet UIView *mainView;
    
    id <UIImagePickerControllerDelegate> delegate;
}

- (void) pickExistingPhoto;
- (void) pickNewPhoto;
- (void) pickPhoto:(BOOL)existing;
- (void) cancel;
- (void) showInView:(UIView *)view;
- (void) dismiss;

@property (nonatomic, assign) id<UIImagePickerControllerDelegate> delegate;

@end
