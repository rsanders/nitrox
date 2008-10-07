//
//  NitroxApiPhoto.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxRPC.h"
#import "NitroxImagePicker.h"

@class NitroxPhoto;

@interface NitroxApiPhoto : NitroxStubClass <UIImagePickerControllerDelegate> {
    NitroxImagePicker*     picker;
}

@property (retain) NitroxImagePicker* picker;

- (id) hasCamera;
- (id) hasLibrary;

- (id) showPicker;
- (NitroxPhoto *) takePhoto;
- (NitroxPhoto *) chooseFromLibrary;

@end
