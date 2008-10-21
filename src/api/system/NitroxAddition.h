//
//  NitroxAddition.h
//  libnitrox
//
//  Created by Robert Sanders on 10/20/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NitroxAddition : NSObject {

}


+ (NSNumber *) add:(NSNumber *)num1 and:(NSNumber *)num2;

+ (NSString *) concat:(NSString *)str1 and:(NSString *)str2;

+ (id) reverse:(id)object;

@end
