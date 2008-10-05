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

@end
