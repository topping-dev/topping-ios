#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

/*
 100    Extra Light or Ultra Light
 200    Light or Thin
 300    Book or Demi
 400    Normal or Regular
 500    Medium
 600    Semibold, Demibold
 700    Bold
 800    Black, Extra Bold or Heavy
 900    Extra Black, Fat, Poster or Ultra Black
 */

#define FONT_STYLE_NORMAL 0
#define FONT_STYLE_BOLD 1
#define FONT_STYLE_ITALIC 2

@interface LGFontData : NSObject

@property(nonatomic, retain) NSString *fontName;
@property(nonatomic) int fontStyle;
@property(nonatomic) int fontWeight;

@end

@interface LGFontReturn : NSObject

@property(nonatomic, retain) NSMutableDictionary *fontMap;

@end

@interface LGFontParser : NSObject
{
}

+(LGFontParser*) getInstance;
+(int)parseTextStyle:(NSString *)textStyleStr;
-(void)initialize;
-(LGFontReturn*) getFont:(NSString *)key;
-(LGFontReturn*) parseXML:(NSString*)path :(NSString *)filename;
-(LGFontReturn*) parseFont:(GDataXMLElement *)element;
-(NSDictionary*) getKeys; 

@property (nonatomic, retain) NSMutableDictionary *fontMap;
@property (nonatomic, retain) NSMutableDictionary *fontCacheMap;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;

@end
