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
     self.frequency = 1;
     self.currentAcceleration = Nil;
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
    accelerometer = Nil;
    self.currentAcceleration = Nil;
    [super dealloc];
}

#pragma mark Photo specific methods


- (id) start {
    if (! started) {
        self.currentAcceleration = Nil;
        accelerometer.delegate = self; 
        accelerometer.updateInterval = 1 / self.frequency;
        started = YES;
    }
    return Nil;
}

- (id) stop {
    if (started) {
        accelerometer.updateInterval = 0;
        accelerometer.delegate = Nil; 
        started = NO;
    }
    return Nil;
}

- (id) getAcceleration {
     if (!started || currentAcceleration == Nil) {
         return Nil;
     }
 
     NSLog(@"current acceleration info is %@", self.currentAcceleration);
 
     NSDictionary *linfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithDouble:currentAcceleration.x], @"x",
                          [NSNumber numberWithDouble:currentAcceleration.y], @"y",
                          [NSNumber numberWithDouble:currentAcceleration.z], @"z",
                          [NSNumber numberWithDouble:currentAcceleration.timestamp], @"timestamp",
                          Nil];
     return [linfo autorelease];
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
