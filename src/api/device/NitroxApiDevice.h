//
//  NitroxApiPhoto.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxRPC.h"

@interface NitroxApiDevice : NitroxStubClass {
@private
    BOOL monitoringOrientation;
    NSInteger lastOrientation;
}

- (NitroxApiDevice *)init;

- (id) startMonitoringOrientation;
- (id) stopMonitoringOrientation;

- (void) sendOrientationNotification:(NSInteger)newOrientation from:(NSInteger)oldOrientation
                              ofType:(NSString*)type;

@end
