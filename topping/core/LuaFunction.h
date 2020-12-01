#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define C ,
#define MakeArray(V) [[NSArray alloc] initWithObjects:V]

@interface LuaFunction : NSObject 
{
@public
	bool manual;
	Method m;
	SEL selector;
	NSString *luaName;
	Class returns;
	NSArray *argumentArray;
	Class classOfMethod;
    void *object;
}

@property(nonatomic, strong) Class classOfMethod;

+(LuaFunction*) CreateC:(bool)manP :(Method)methodP :(SEL)selP :(Class)returnsP :(NSArray*)argArrayP :(Class)classOfMethodP;
+(LuaFunction*) Create:(bool)manP :(Method) methodP :(SEL)selP :(Class)returnsP :(NSArray*)argArrayP;
+(LuaFunction*) CreateC:(Method)methodP :(SEL)selP :(Class)returnsP :(NSArray*)argArrayP :(Class)classOfMethodP;
+(LuaFunction*) Create:(Method)methodP :(SEL)selP :(Class)returnsP :(NSArray*)argArrayP;
+(LuaFunction*) CreateC:(Method)methodP :(SEL)selP :(Class)returnsP :(Class)classOfMethodP;
+(LuaFunction*) Create:(Method)methodP :(SEL)selP :(Class)returnsP;

@end
