#ifndef Common_h
#define Common_h

#import <Foundation/Foundation.h>

#define UIColorFromARGB(a, r, g, b) [UIColor \
    colorWithRed:((float)r/255.0f) \
    green:((float)g/255.0f) \
    blue:((float)b/255.0f) \
    alpha:((float)a/255.0f)]

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define RADIUS_OF_EARTH_KM 6371
#define RADIUS_OF_EARTH_M 6371000

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

//
//  Common.h
//  RestoIphone
//
//  Created by ed Ka on 12/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

typedef int64_t int64;
typedef int32_t int32;
typedef int16_t int16;
typedef int8_t int8;
typedef uint64_t uint64;
typedef uint32_t uint32;
typedef uint16_t uint16;
typedef uint8_t uint8;
typedef uint32_t DWORD;

#import "Singleton.h"


#endif /* Common_h */
