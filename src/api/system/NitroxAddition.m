//
//  NitroxAddition.m
//  libnitrox
//
//  Created by Robert Sanders on 10/20/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxAddition.h"

@protocol NitroxReversible
- (id) reverse;
@end

@implementation NitroxAddition


#pragma mark test methods

+ (NSNumber *) add:(NSNumber *)num1 and:(NSNumber *)num2
{
    return [NSNumber numberWithDouble:([num1 doubleValue] + [num2 doubleValue])];
}

+ (double) addInt:(int)num1 and:(double)num2
{
    return (num1 + num2);
}

+ (NSString *) concat:(NSString *)str1 and:(NSString *)str2
{
    return [str1 stringByAppendingString:str2];
}

+ (id) reverse:(id)object
{
    if ([object respondsToSelector:@selector(reverse)]) {
        return [(id<NitroxReversible>)object reverse];
    }
    else if ([object isKindOfClass:[NSString class]]) {
        NSString *src = object;
        NSMutableString *dest = [[[NSMutableString alloc] initWithCapacity:[src length]] autorelease];
        
        for (int i = [src length]-1; i >= 0; i--) {
            [dest appendString:[src substringWithRange:NSMakeRange(i, 1)]];
        }
        
        return dest;
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSArray *src = object;
        NSMutableArray *dest = [[[NSMutableArray alloc] init] autorelease];
        id elt;
        for (elt in [src reverseObjectEnumerator]) {
            [dest addObject:elt];
        }
        return dest;
    } else {
        return object;
    }
}



@end
