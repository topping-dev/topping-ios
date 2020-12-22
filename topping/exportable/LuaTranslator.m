#import "LuaTranslator.h"
#import "ToppingEngine.h"
#import "LuaFunction.h"

@implementation LuaTranslator

@synthesize obj, func;

+(NSObject*) Register:(NSObject *)obj :(NSString *)function
{
	LuaTranslator *lt = [[LuaTranslator alloc] init];
	lt.func = function;
	lt.obj = obj;
    lt.selector = @selector(Call:);
    lt.selectorTwo = @selector(Call::);
	return lt;
}

-(NSObject*) Call:(NSObject *)a
{
    return [self CallIn:self.obj, nil];
}

-(NSObject*) Call:(NSObject *)a :(NSObject *)b
{
	return [self CallIn:self.obj, nil];
}

-(NSObject*) CallIn:(NSObject *) val, ...
{
    if(self.nobj != NULL)
    {
        if(self.kFF != NULL)
        {
            self.kFF(self.nobj, VarArgs2(val));
            return nil;
        }
        else if(self.kFRetF != NULL)
        {
            return (__bridge NSObject *)(self.kFRetF(self.nobj, VarArgs2(val)));
        }
        else
            return [sToppingEngine OnNativeEventArgs:self.obj :[((NSNumber*)self.nobj) intValue] :VarArgs2(val)];
    }
	return [sToppingEngine OnGuiEventArgs:obj :func :VarArgs2(val)];
}

-(NSObject*) CallInSelf:(NSObject *)s :(NSObject *)val :(va_list)valist
{
    NSMutableArray *args = VarArgs3(valist, val);
    if(self.nobj != NULL)
    {
        if(self.kFF != NULL)
        {
            self.kFF(self.nobj, args);
            return nil;
        }
        else if(self.kFRetF != NULL)
        {
            return (__bridge NSObject *)(self.kFRetF(self.nobj, args));
        }
        else
            return [sToppingEngine OnNativeEventArgs:s :[((NSNumber*)self.nobj) intValue] :args];
    }
    return [sToppingEngine OnGuiEventArgs:s :func :args];
}

-(NSObject *)GetObject
{
	return obj;
}

-(NSString *)GetFunction
{
	return func;
}

-(void) Set:(NSObject*) objP :(NSString*)funcP
{
	obj = objP;
	func = funcP;
}

-(NSString*)GetId
{
	return @"LuaTranslator"; 
}

+ (NSString*)className
{
	return @"LuaTranslator";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Register::)) 
										:@selector(Register::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSObject class], [NSString class], nil] 
										:[LuaTranslator class]] 
										forKey:@"Register"];
	return dict;
}

@end
