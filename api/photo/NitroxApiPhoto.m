//
//  NitroxApiPhoto.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxApiPhoto.h"


@implementation NitroxApiPhoto

@synthesize picker;

- (void) dealloc {
    self.picker = Nil;
    [super dealloc];
}

#pragma mark Photo specific methods

/*
 * Data URI
 *
 *
 */

- (id) hasCamera {
    return [NSNumber numberWithBool:
            [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]];
}

- (id) hasLibrary {
    return [NSNumber numberWithBool:
            [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]];
}

- (id) showPicker {
    self.picker = [[NitroxImagePicker alloc] initWithNibName:@"NitroxImagePickerUI"
                                                      bundle:[NSBundle mainBundle]];
    self.picker.mainController = self.dispatcher.webViewController;
    UIView *view = [self.dispatcher.webViewController webView];
    [picker showInView:view];
    return Nil;
}

- (NitroxPhoto *) takePhoto {
    return Nil;
}

- (NitroxPhoto *) chooseFromLibrary {
    return Nil;
}

#pragma mark Stub methods; should refactor out


- (NSString *) instanceMethods {
    return Nil;
}

- (NSString *) classMethods {
    return Nil;
}

- (id) newInstance {
    return Nil;
}

- (id) newInstanceWithArgs:(NSDictionary *)args {
    return Nil;
}

- (id) invoke:(NSString *)method args:(NSDictionary *)args {
    return Nil;
}


@end
