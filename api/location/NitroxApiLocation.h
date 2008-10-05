//
//  NitroxApiLocation.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxRPC.h"

#import <CoreLocation/CoreLocation.h>

@interface NitroxApiLocation : NitroxStubClass <CLLocationManagerDelegate> {
    CLLocationManager*       locationManager;
    BOOL                     started;
    CLLocation*              currentLocation;
}

@property (retain)  CLLocationManager*       locationManager;
@property (assign)  BOOL                     started;
@property (retain)  CLLocation*              currentLocation;


- (NitroxApiLocation *)initWithLocationManager:(CLLocationManager *)manager;
- (NitroxApiLocation *)init;

- (id) start;
- (id) stop;
- (id) getLocation;

@end
