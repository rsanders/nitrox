//
//  NitroxApiPhoto.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxApiPhoto.h"


@implementation NitroxApiPhoto

#pragma mark Photo specific methods

/*
 * Data URI
 *
 *
 */

- (id) hasCamera {
    return [NSNumber numberWithBool:YES];
}

- (id) hasLibrary {
    return [NSNumber numberWithBool:YES];
}

- (NitroxPhoto *) showPicker {
    return Nil;
}

- (NitroxPhoto *) takePhoto {
    return Nil;
}

- (NitroxPhoto *) chooseFromLibrary {
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

- (id) invoke:(NSString *)method args:(NSDictionary *)args {
    return Nil;
}


@end
