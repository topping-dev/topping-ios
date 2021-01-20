#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define GETID \
if(self.lua_id != nil) \
    return self.lua_id; \
if(self.android_id != nil) \
    return self.android_id; \
if(self.android_tag != nil) \
    return self.android_tag; 


#define GETLUAID \
if(self.lua_id != nil) \
    return self.lua_id;

@class LuaTranslator;

@protocol LuaInterface
@required
-(NSString *)GetId;
@end
