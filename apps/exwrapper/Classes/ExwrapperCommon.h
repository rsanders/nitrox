//
//  NitroxydemoCommon.h
//  nitroxdemo
//
//  Created by Robert Sanders on 10/6/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NibwareLog.h"

#ifdef PERFORMANCE_TEST
#  undef NSLog
#  define NSLog  NullLog
#endif
