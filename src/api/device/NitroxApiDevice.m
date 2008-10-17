//
//  NitroxApiPhoto.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxApiDevice.h"


@implementation NitroxApiDevice

- (NitroxApiDevice *)init
{
    [super init];
    
    monitoringOrientation = NO;
    lastOrientation = -1;
    
    return self;
}

- (void) dealloc {
    [self stopMonitoringOrientation];
    
    [super dealloc];
}

#pragma mark Device specific methods

- (id) invokeClassMethod:(NSString *)method args:(NSDictionary *)args {
    
    NSString *res = Nil;
    UIDevice *device = [UIDevice currentDevice];
    
    SEL sel = NSSelectorFromString( [method stringByAppendingString:@":"] );       
    if ([device respondsToSelector:sel]) {
        res = [device performSelector:sel withObject:args];
    } else if ([device respondsToSelector:(sel = NSSelectorFromString(method))]) {
        res = [device performSelector:sel];
    } else {
        res = [super invokeClassMethod:method args:args];
    }
    
    return res;
}

#pragma mark Stub methods; should refactor out

- (id) startMonitoringOrientation {
    if (! monitoringOrientation) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        // this triggers when the UI reorients
        [center addObserver:self 
                   selector:@selector(orientationDidChange:) 
                       name:UIApplicationDidChangeStatusBarOrientationNotification
                     object:Nil];

        // this triggers when the device reorients
        [center addObserver:self 
                   selector:@selector(orientationDidChange:) 
                       name:UIDeviceOrientationDidChangeNotification
                     object:Nil];        
        
        
        lastOrientation = [[UIDevice currentDevice] orientation];
        if (lastOrientation == -1 || lastOrientation == UIDeviceOrientationUnknown) {
            lastOrientation = UIDeviceOrientationPortrait;
        }
        [self sendOrientationNotification:lastOrientation from:lastOrientation ofType:@"initial"];
        
        monitoringOrientation = YES;
    }
    return Nil;
}

- (id) stopMonitoringOrientation {
    if (monitoringOrientation) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];

        monitoringOrientation = NO;
    }
    return Nil;
}

#pragma mark delegate and notification methods

- (void) sendOrientationNotification:(NSInteger)newOrientation from:(NSInteger)oldOrientation
                              ofType:(NSString*)type
{
    [self scheduleCallbackScript:[NSString stringWithFormat:@"Nitrox.Device.orientationDelegate(%d, %d, '%@')",
                                      newOrientation, oldOrientation, type]];
}

- (void) orientationDidChange:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    NSNumber *orientation = [dict objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
    
    UIDeviceOrientation oldOrientation;
    if (orientation) {
        oldOrientation = [orientation intValue];
    } else {
        oldOrientation = lastOrientation;
    }
    UIDeviceOrientation newOrientation = [[UIDevice currentDevice] orientation];
    
    NSLog(@"got orientation update for type %@: from %d to %d", 
          notification.name, oldOrientation, newOrientation);
    
    [self sendOrientationNotification:newOrientation from:oldOrientation ofType:notification.name];
    
    lastOrientation = newOrientation;
}

#pragma mark Generic Stub methods

- (NSString *) className {
    return @"Device";
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
