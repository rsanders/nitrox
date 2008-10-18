//
//  NSDate+JSON.m
//  libnitrox
//
//  Created by Robert Sanders on 10/18/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NSDate+JSON.h"


@implementation NSDate (JSON)

- (NSString*) serializeToJSON
{
    return @"\"a date\"";
}

@end
