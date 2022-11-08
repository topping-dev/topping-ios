#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define C ,
//#define MakeArray(V) (V == nil) ? [[NSArray alloc] init] : [[NSArray alloc] initWithObjects:V]
#define MakeArray(V) [[NSArray alloc] initWithObjects:V]
#define InstanceMethod(SEL, RET, ARGS, KEY) [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SEL)) :@selector(SEL) :[RET class] :ARGS] forKey:KEY];
#define ClassMethod(SEL, RET, ARGS, KEY) [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(SEL)) :@selector(SEL) :[RET class] :ARGS] forKey:KEY];
#define InstanceMethodNoRet(SEL, ARGS, KEY) [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SEL)) :@selector(SEL) :nil :ARGS] forKey:KEY];
#define ClassMethodNoRet(SEL, ARGS, KEY) [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(SEL)) :@selector(SEL) :nil :ARGS] forKey:KEY];
#define InstanceMethodNoArg(SEL, RET, KEY) [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SEL)) :@selector(SEL) :[RET class] :[[NSArray alloc] initWithObjects:nil]] forKey:KEY];
#define ClassMethodNoArg(SEL, RET, KEY) [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(SEL)) :@selector(SEL) :[RET class] :[[NSArray alloc] initWithObjects:nil]] forKey:KEY];
#define InstanceMethodNoRetNoArg(SEL, KEY) [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SEL)) :@selector(SEL) :nil :[[NSArray alloc] initWithObjects:nil]] forKey:KEY];
#define ClassMethodNoRetNoArg(SEL, KEY) [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(SEL)) :@selector(SEL) :nil :[[NSArray alloc] initWithObjects:nil]] forKey:KEY];

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
