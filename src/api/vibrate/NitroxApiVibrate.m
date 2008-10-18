//
//  NitroxApiVibrate.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import <AudioToolbox/AudioToolbox.h> 

#import "NitroxApiVibrate.h"

@implementation NitroxApiVibrate

- (NitroxApiVibrate *)init
{
    return [super init];
}

- (void) dealloc {
    [super dealloc];
}

#pragma mark Vibration specific methods


- (id) vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); 
    return nil;
}

#pragma mark Stub methods; should refactor out

- (NSString *) instanceMethods {
    return nil;
}

- (NSString *) classMethods {
    return nil;
}

- (id) newInstance {
    return nil;
}

- (id) newInstanceWithArgs:(NSDictionary *)args {
    return nil;
}

@end
