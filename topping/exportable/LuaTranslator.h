#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"

static NSMutableArray* VarArgs(va_list ap, NSObject* val);
static NSMutableArray* VarArgs(va_list ap, NSObject* val)
{
	id obj;
	NSMutableArray* array = [NSMutableArray array];
	if(val == nil)
		return array;
	[array addObject:val];
	while ((obj = va_arg(ap, id))) {
		[array addObject:obj];
	}
	return array;
}

#ifndef	VarArgs2
#define VarArgs2(_last_) ({ \
va_list ap; \
va_start(ap, _last_); \
NSArray* __args = VarArgs(ap, _last_); \
va_end(ap); \
if (([__args count] == 1) && ([[__args objectAtIndex:0] isKindOfClass:[NSArray class]])) { \
__args = [__args objectAtIndex:0]; \
} \
__args; })
#endif

#ifndef VarArgs3
#define VarArgs3(ap, _last_) ({ \
NSMutableArray* __args = VarArgs(ap, _last_); \
if (([__args count] == 1) && ([[__args objectAtIndex:0] isKindOfClass:[NSArray class]])) { \
__args = [__args objectAtIndex:0]; \
} \
__args; })
#endif

typedef void (*kF)(void*, int s, NSArray*);
typedef NSObject* (*kFRet)(void*, int s, NSArray*);

/**
 * Function translator for lua.
 */
@interface LuaTranslator : NSObject<LuaClass, LuaInterface>
{
}

/*
 * Registers a lua function to underlying system.
 * @param obj Object which function will registered.
 * @param function Function name.
 */
+(NSObject*) Register:(NSObject*)obj :(NSString*)function;

-(NSObject*)Call;
-(NSObject*)CallIn:(NSObject*) val, ...;
-(NSObject*)CallInSelf:(NSObject*) s :(NSObject*) val :(va_list) valist;
-(NSObject*)Call:(NSObject*)a;
-(NSObject*)Call:(NSObject*)a :(NSObject*)b;
-(NSObject *)GetObject;
-(NSString *)GetFunction;
-(void) Set:(NSObject*) objP :(NSString*)strP;

@property (nonatomic, retain) NSObject *obj;
@property (nonatomic, retain) NSString *func;
@property (nonatomic) SEL selector, selectorOne, selectorTwo;
@property void *nobj;
@property kF kFF;
@property kFRet kFRetF;

@end
