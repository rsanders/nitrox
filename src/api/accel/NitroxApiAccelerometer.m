//
//  NitroxApiAccelerometer.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxApiAccelerometer.h"


@implementation NitroxApiAccelerometer

// @synthesize locationManager, started, currentLocation;

@synthesize started, frequency, accelerometer, currentAcceleration;

 - (NitroxApiAccelerometer *)initWithAccelerometer:(UIAccelerometer *)mgr
 {
     accelerometer = mgr;
     self.frequency = 1/20.0;
     self.currentAcceleration = nil;
     return self;
 }

- (NitroxApiAccelerometer *)init
{
    return [self initWithAccelerometer:[UIAccelerometer sharedAccelerometer]];
}

- (void) dealloc {
    if (started) {
        [self stop];
    }
    accelerometer = nil;
    self.currentAcceleration = nil;
    [super dealloc];
}

#pragma mark Photo specific methods


- (id) start {
    if (! started) {
        self.currentAcceleration = nil;
        accelerometer.delegate = self; 
        accelerometer.updateInterval = 1 / self.frequency;
        started = YES;
    }
    return nil;
}

- (id) stop {
    if (started) {
        accelerometer.updateInterval = 0;
        accelerometer.delegate = nil; 
        started = NO;
    }
    return nil;
}

- (id) getAcceleration {
     if (!started || currentAcceleration == nil) {
         return nil;
     }
 
     NSLog(@"current acceleration info is %@", self.currentAcceleration);
 
     NSDictionary *linfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithDouble:currentAcceleration.x], @"x",
                          [NSNumber numberWithDouble:currentAcceleration.y], @"y",
                          [NSNumber numberWithDouble:currentAcceleration.z], @"z",
                          [NSNumber numberWithDouble:currentAcceleration.timestamp], @"timestamp",
                          nil];
     return [linfo autorelease];
}

- (id) updateFrequency:(NSDictionary *)dict
{
    NSString *arg = [dict objectForKey:@"frequency"];
    double newFreq = [arg doubleValue];
    if (newFreq <= 0) {
        return nil;
    }
    self.frequency = newFreq;
    accelerometer.updateInterval = 1/self.frequency;
    
    return nil;
}


#pragma mark Accelerometer Delegate methods

- (void)accelerometer:(UIAccelerometer *)accelerometer 
        didAccelerate:(UIAcceleration *)acceleration 
{ 
    NSLog(@"received accelerometer update %@", acceleration);    
    self.currentAcceleration = acceleration;

    NSDictionary *linfo = [self getAcceleration];
    
    [self scheduleCallbackScript:[NSString stringWithFormat:@"Nitrox.Accelerometer.delegate(%@);",
                                  [self serialize:linfo]]];
} 


#pragma mark Stub methods; should refactor out


- (NSString *) className {
    return @"Accelerometer";
}

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
