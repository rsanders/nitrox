//
//  NitroxApiPhoto.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxRPC.h"
@class NitroxPhoto;

@interface NitroxApiPhoto : NitroxStubClass {
    
}

- (BOOL) hasCamera;
- (BOOL) hasLibrary;

- (NitroxPhoto *) showPicker;
- (NitroxPhoto *) takePhoto;
- (NitroxPhoto *) chooseFromLibrary;

@end
