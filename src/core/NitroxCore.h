//
//  NitroxCore.h
//  libnitrox
//
//  Created by Robert Sanders on 10/15/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NitroxApp;

@interface NitroxCore : NSObject {

}

+ (NitroxCore*) singleton;

- (NitroxApp*) createApp;

- (void) start;
- (void) stop;

@end
