//
//  NitroxFallbackJSONSerializer.m
//  libnitrox
//
//  Created by Robert Sanders on 10/21/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxFallbackJSONSerializer.h"

#import "CJSONSerializer.h"

@implementation NitroxFallbackJSONSerializer

- (NSString *)serializeObject:(id)object
{
    CJSONSerializer *serializer = [[CJSONSerializer alloc] init];
    NSString *res = [NSString stringWithFormat:@"{\"__type\": %@, \"value\": %@}",
                     [serializer serializeString:[NSString stringWithFormat:@"%@", [object class]]],
                     [serializer serializeString:[NSString stringWithFormat:@"%@", object]]
                     ];
    [serializer release];
    return res;
}

@end
