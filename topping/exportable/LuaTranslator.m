#import "LuaTranslator.h"
#import "ToppingEngine.h"
#import "LuaFunction.h"

@implementation LuaTranslator

@synthesize obj, func;

+(NSObject*) register:(NSObject *)obj :(NSString *)function
{
	LuaTranslator *lt = [[LuaTranslator alloc] init];
	lt.func = function;
	lt.obj = obj;
	return lt;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selector = @selector(call);
        self.selectorOne = @selector(call:);
        self.selectorTwo = @selector(call::);
    }
    return self;
}

-(NSObject*) call
{
    return [self callIn:nil];
}

-(NSObject*) call:(NSObject *)a
{
    return [self callIn:a, nil];
}

-(NSObject*) call:(NSObject *)a :(NSObject *)b
{
	return [self callIn:a, b, nil];
}

-(NSObject*) callIn:(NSObject *) val, ...
{
    if(self.nobj != NULL)
    {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:VarArgs2(val)];
        if(self.obj != nil)
           [arr insertObject:self.obj atIndex:0];
        if(self.kFF != NULL)
        {
            self.kFF(self.nobj, 0, arr);
            return nil;
        }
        else if(self.kFRetF != NULL)
        {
            return self.kFRetF(self.nobj, 0, arr);
        }
        else
            return [sToppingEngine onNativeEventArgs:self.obj :[((NSNumber*)self.nobj) intValue] :VarArgs2(val)];
    }
	return [sToppingEngine onGuiEventArgs:self.obj :func :VarArgs2(val)];
}

-(NSObject*) callInSelf:(NSObject *)s :(NSObject *)val :(va_list)valist
{
    NSMutableArray *args = VarArgs3(valist, val);
    if(self.nobj != NULL)
    {
        if(self.kFF != NULL)
        {
            [args insertObject:s atIndex:0];
            self.kFF(self.nobj, 1, args);
            return nil;
        }
        else if(self.kFRetF != NULL)
        {
            [args insertObject:s atIndex:0];
            NSObject *ret = self.kFRetF(self.nobj, 1, args);
            return ret;
        }
        else
            return [sToppingEngine onNativeEventArgs:s :[((NSNumber*)self.nobj) intValue] :args];
    }
    return [sToppingEngine onGuiEventArgs:s :func :args];
}

-(NSObject *)getObject
{
	return obj;
}

-(NSString *)getFunction
{
	return func;
}

-(void) set:(NSObject*) objP :(NSString*)funcP
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(register::)) 
										:@selector(register::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSObject class], [NSString class], nil] 
										:[LuaTranslator class]] 
										forKey:@"register"];
	return dict;
}

@end
