//
//  NitroxHTTPUtils.m
//  nitroxy1
//
//  Created by Robert Sanders on 9/30/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxHTTPUtils.h"


@implementation NitroxHTTPUtils

+ (NSString *)stripLeadingPathElement:(NSString *)path {
    if ([path characterAtIndex:0] == '/') {
        path = [path substringFromIndex:1];
    }
    NSArray *components = [path componentsSeparatedByString:@"/"];
    if ([components count] >= 1) {
        return [[components subarrayWithRange:NSMakeRange([components count]-1,1)] componentsJoinedByString:@"/"];
    } else {
        return @"";
    }
}

+ (NSString *)getLeadingPathElement:(NSString *)path {
    if ([path characterAtIndex:0] == '/') {
        path = [path substringFromIndex:1];
    }
    NSArray *components = [path componentsSeparatedByString:@"/"];
    if ([components count] >= 1) {
        return [components objectAtIndex:0];
    } else {
        return @"";
    }
}

+ (NSString *) stripLeadingSlash:(NSString *)path {
    if ([path characterAtIndex:0] == '/') {
        return [path substringFromIndex:1];
    } else {
        return path;
    }
}

+ (NSString *) stripTrailingSlash:(NSString *)path {
    if ([path characterAtIndex:[path length]-1] == '/') {
        return [path substringToIndex:[path length]-1];
    } else {
        return path;
    }
}

@end
