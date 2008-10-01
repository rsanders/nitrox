//
//  NitroxHTTPUtils.h
//  nitroxy1
//
//  Created by Robert Sanders on 9/30/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NitroxHTTPUtils : NSObject {

}

+ (NSString *) stripLeadingPathElement:(NSString *)path;
+ (NSString *) getLeadingPathElement:(NSString *)path;
+ (NSString *) stripLeadingSlash:(NSString *)path;

@end
