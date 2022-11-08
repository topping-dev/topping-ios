#import "LuaFunction.h"
#import <objc/runtime.h>


@implementation LuaFunction

+(LuaFunction*)CreateC:(bool)manP :(Method) methodP :(SEL)selP :(Class)returnsP :(NSArray *)argArrayP :(Class)classOfMethodP
{
	LuaFunction *lf = [[LuaFunction alloc] init];
	lf->manual = manP;
	lf->m = methodP;
	lf->classOfMethod = classOfMethodP;
	lf->selector = selP;
	lf->returns = returnsP;
	lf->argumentArray = [argArrayP copy];
	return lf;
}

+(LuaFunction*)Create:(bool)manP :(Method) methodP :(SEL)selP :(Class)returnsP :(NSArray *)argArrayP
{
	LuaFunction *lf = [[LuaFunction alloc] init];
	lf->manual = manP;
	lf->m = methodP;
	lf->classOfMethod = NULL;
	lf->selector = selP;
	lf->returns = returnsP;
	lf->argumentArray = [argArrayP copy];
	return lf;
}

+(LuaFunction*)CreateC:(Method) methodP :(SEL)selP :(Class)returnsP :(NSArray *)argArrayP :(Class)classOfMethodP
{
	LuaFunction *lf = [[LuaFunction alloc] init];
	lf->manual = true;
	lf->m = methodP;
	lf->classOfMethod = classOfMethodP;
	lf->selector = selP;
	lf->returns = returnsP;	
	lf->argumentArray = [argArrayP copy];
	return lf;
}

+(LuaFunction*)Create:(Method) methodP :(SEL)selP :(Class)returnsP :(NSArray *)argArrayP
{
	LuaFunction *lf = [[LuaFunction alloc] init];
	lf->manual = true;
	lf->m = methodP;
	lf->classOfMethod = NULL;	
	lf->selector = selP;
	lf->returns = returnsP;	
	lf->argumentArray = [argArrayP copy];
	return lf;
}


+(LuaFunction*)CreateC:(Method) methodP :(SEL)selP :(Class)returnsP :(Class)classOfMethodP
{
	LuaFunction *lf = [[LuaFunction alloc] init];
	lf->manual = true;
	lf->m = methodP;
	lf->classOfMethod = classOfMethodP;
	lf->selector = selP;
	lf->returns = returnsP;	
	lf->argumentArray = nil;
	return lf;
}

+(LuaFunction*)Create:(Method) methodP :(SEL)selP :(Class)returnsP
{
	LuaFunction *lf = [[LuaFunction alloc] init];
	lf->manual = true;
	lf->m = methodP;
	lf->classOfMethod = NULL;
	lf->selector = selP;
	lf->returns = returnsP;	
	lf->argumentArray = nil;
	return lf;
}

-(NSString *) description
{
	return [NSString stringWithFormat:@"<LuaFunction> %@, %@", NSStringFromSelector(method_getName(m)), classOfMethod];
}

@end
