#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"

@interface VarArgsConvertor : NSObject

+(NSMutableArray*)VarArgs:(va_list)ap :(NSObject*)val;

@end

#ifndef	VarArgs2
#define VarArgs2(_last_) ({ \
va_list ap; \
va_start(ap, _last_); \
NSArray* __args = [VarArgsConvertor VarArgs:ap :_last_]; \
va_end(ap); \
if (([__args count] == 1) && ([[__args objectAtIndex:0] isKindOfClass:[NSArray class]])) { \
__args = [__args objectAtIndex:0]; \
} \
__args; })
#endif

#ifndef VarArgs3
#define VarArgs3(ap, _last_) ({ \
NSMutableArray* __args = [VarArgsConvertor VarArgs:ap :_last_]; \
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
+(NSObject*)register:(NSObject*)obj :(NSString*)function;

-(NSObject*)call;
-(NSObject*)callIn:(NSObject*) val, ...;
-(NSObject*)callInSelf:(NSObject*) s :(NSObject*) val :(va_list) valist;
-(NSObject*)call:(NSObject*)a;
-(NSObject*)call:(NSObject*)a :(NSObject*)b;
-(NSObject*)getObject;
-(NSString*)getFunction;
-(void)set:(NSObject*) objP :(NSString*)strP;

@property (nonatomic, retain) NSObject *obj;
@property (nonatomic, retain) NSString *func;
@property (nonatomic) SEL selector, selectorOne, selectorTwo;
@property void *nobj;
@property kF kFF;
@property kFRet kFRetF;

@end
