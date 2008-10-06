//
//  NitroxApiPhoto.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxApiLocation.h"


@implementation NitroxApiLocation

@synthesize locationManager, started, currentLocation;

- (NitroxApiLocation *)initWithLocationManager:(CLLocationManager *)mgr
{
    self.locationManager = mgr;
    [self.locationManager setDelegate:self];
    self.currentLocation = Nil;
    return self;
}


- (NitroxApiLocation *)init
{
    [self initWithLocationManager:[[CLLocationManager alloc] init]];
    return self;
}

- (void) dealloc {
    if (started) {
        [locationManager stopUpdatingLocation];
    }
    [currentLocation release];
    [locationManager release];
    [super dealloc];
}

#pragma mark Photo specific methods


- (id) start {
    if (! started) {
        [locationManager startUpdatingLocation];
        self.currentLocation = Nil;
        started = YES;
    }
    return Nil;
}

- (id) stop {
    if (started) {
        [locationManager stopUpdatingLocation];
        started = NO;
    }
    return Nil;
}

- (id) getLocation {
    if (!started || currentLocation == Nil) {
        return Nil;
    }

    NSLog(@"current location info is %@", self.currentLocation);

    NSDictionary *linfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [NSNumber numberWithDouble:currentLocation.coordinate.latitude], @"latitude",
                         [NSNumber numberWithDouble:currentLocation.coordinate.longitude], @"longitude",
                         [NSNumber numberWithDouble:currentLocation.altitude], @"altitude",
                         [NSNumber numberWithDouble:currentLocation.verticalAccuracy], @"verticalAccuracy",
                         [NSNumber numberWithDouble:currentLocation.horizontalAccuracy], @"horizontalAccuracy",
                         [NSString stringWithFormat:@"%@", currentLocation.timestamp], @"timestamp",
                         Nil];
    return [linfo autorelease];
}

#pragma mark Location Delegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"received location update from %@ to %@", oldLocation, newLocation);
    
    self.currentLocation = newLocation;
    
    NSDictionary *linfo = [self getLocation];
    
    [self scheduleCallbackScript:[NSString stringWithFormat:@"Nitrox.Location.delegate(%@);",
                                  [self serialize:linfo]]];
    // TODO: call JS callback / fire event
}

/*
 *  locationManager:failedWithError:
 *  
 *  Discussion:
 *    Invoked when an error has occurred.
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"location manager failed: %@", error);
}


#pragma mark Stub methods; should refactor out


- (NSString *) className {
    return @"Location";
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
