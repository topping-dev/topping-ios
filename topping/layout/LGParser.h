#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGLayoutParser.h"
#import "LGDrawableParser.h"
#import "LGDimensionParser.h"
#import "LGColorParser.h"
#import "LGStringParser.h"
#import "LGValueParser.h"
#import "LGStyleParser.h"
#import "LGFontParser.h"
#import "LGNavigationParser.h"
#import "LGMenuParser.h"
#import "LGIdParser.h"

@class LGParser;

static LGParser *sLGParser = nil;

typedef enum
{
    MATCH_ID_LANGUAGE = -1,
    MATCH_ID_LAYOUT_DIRECTION,
    MATCH_ID_SMALLEST_WIDTH,
    MATCH_ID_AVAILABLE_WIDTH,
    MATCH_ID_AVAILABLE_HEIGHT,
    MATCH_ID_SCREEN_SIZE,
    MATCH_ID_SCREEN_ORIENTATION,
    MATCH_ID_SCREEN_PIXEL_DENSITY,
    MATCH_ID_VERSION,
    MATCH_ID_COUNT = 9
} MATCH_ID;

#define ORIENTATION_PORTRAIT 0x1
#define ORIENTATION_LANDSCAPE 0x2

#define ORIENTATION_PORTRAIT_S @"1"
#define ORIENTATION_LANDSCAPE_S @"2"

@interface DynamicResource : NSObject
{
    int orientation;
    NSObject *data;
}

@property(nonatomic) int orientation;
@property(nonatomic, retain) NSObject *data;

@end

@interface LGParser : NSObject
{
}

+(LGParser*) getInstance;
-(void)initialize;
-(NSMutableArray *)tester:(NSArray*)directoryList :(NSString*)directoryType;
-(MATCH_ID) matcher:(MATCH_ID)count :(NSString*)toMatch :(BOOL *) result;

@property (nonatomic, retain) LGLayoutParser *pLayout;
@property (nonatomic, retain) LGDrawableParser *pDrawable;
@property (nonatomic, retain) LGDimensionParser *pDimen;
@property (nonatomic, retain) LGColorParser *pColor;
@property (nonatomic, retain) LGStringParser *pString;
@property (nonatomic, retain) LGValueParser *pValue;
@property (nonatomic, retain) LGStyleParser *pStyle;
@property (nonatomic, retain) LGFontParser *pFont;
@property (nonatomic, retain) LGNavigationParser *pNavigation;
@property (nonatomic, retain) LGMenuParser *pMenu;
@property (nonatomic, retain) LGIdParser *pId;
@property (nonatomic, retain) NSMutableArray *MatchStringStart;
@property (nonatomic, retain) NSMutableArray *MatchStringEnd;

@end
