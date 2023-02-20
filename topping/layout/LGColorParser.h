#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGColorState : NSObject

-(int)getUIControlStateFlag;
-(UIColor*)getColorForState:(int)state :(UIColor*)defColor;

@property(nonatomic, retain) UIColor *color;
@property(nonatomic) float lStar;
@property(nonatomic) bool state_pressed;
@property(nonatomic) bool state_focused;
@property(nonatomic) bool state_selected;
@property(nonatomic) bool state_checkable;
@property(nonatomic) bool state_checked;
@property(nonatomic) bool state_enabled;
@property(nonatomic) bool state_window_focused;

@end

@interface LGColorParser : NSObject 
{
	NSMutableDictionary *colorMap;
}

+(LGColorParser*) getInstance;
-(void)initialize;
-(void) parseXML:(NSString *)filename;
-(void) parseXML:(int)orientation :(GDataXMLElement *)element;

-(UIColor*) parseColor:(NSString *)color;
-(UIColor*) parseColor:(NSString *)color :(int)state;
-(UIColor*) parseColorInternal:(NSString *)color;
-(LGColorState*)getColorState:(NSString*)ref;
-(UIColor*)getTextColorFromColor:(UIColor*)color;
-(NSDictionary*)getKeys;

@property (nonatomic, retain) NSMutableDictionary *colorMap;
@property (nonatomic, retain) NSMutableDictionary *colorFileMap;
@property (nonatomic, retain) NSMutableDictionary *colorFileCacheMap;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;

@end
