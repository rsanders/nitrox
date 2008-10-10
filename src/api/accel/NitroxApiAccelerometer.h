//
//  NitroxApiAccelerometer.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxRPC.h"


@interface NitroxApiAccelerometer : NitroxStubClass  <UIAccelerometerDelegate> {
    BOOL                     started;
    UIAccelerometer*         accelerometer;
    double                   frequency;
    UIAcceleration*          currentAcceleration;
}

@property (assign)  BOOL                     started;
@property (assign)  double                   frequency;
@property (assign,readonly)  UIAccelerometer*         accelerometer;
@property (retain)  UIAcceleration*          currentAcceleration;

- (NitroxApiAccelerometer *)init;
- (NitroxApiAccelerometer *)initWithAccelerometer:(UIAccelerometer *)mgr;

- (id) start;
- (id) stop;
- (id) getAcceleration;
- (id) updateFrequency:(NSDictionary *)dict;

@end
