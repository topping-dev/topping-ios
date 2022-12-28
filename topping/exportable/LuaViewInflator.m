#import "LuaViewInflator.h"
#import "LuaFunction.h"
#import "LGLayoutParser.h"
#import "LGView.h"
#import "LuaTranslator.h"
#import "Defines.h"
#import "LuaRef.h"

@implementation LuaViewInflator

+(NSObject *) Create:(LuaContext*)lc
{
	return [[LuaViewInflator alloc] initWithContext:lc];
}

+(LuaViewInflator *)From:(LGLayoutParser*)parser {
    return [[LuaViewInflator alloc] initWithContext:[LuaForm GetActiveForm].context];
}

- (instancetype)initWithContext:(LuaContext*) context {
    self = [super init];
    if (self) {
        self.context = context;
    }
    return self;
}

-(LGView*)ParseFile:(NSString *)filename :(LGView*)parent
{
	LGView *lgview = nil;
	[[LGLayoutParser GetInstance] ParseXML:filename :[parent GetView] :parent :self.context.form :&lgview];
	return lgview;
}

-(LGView*)Inflate:(LuaRef*)ref : (LGView*)parent {
    LGView *lgview = nil;
    [[LGLayoutParser GetInstance] ParseRef:ref :[parent GetView] :parent :self.context.form :&lgview];
    return lgview;
}

-(NSString*)GetId
{
	return @"LuaViewInflator";
}

+ (NSString*)className
{
	return @"LuaViewInflator";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:)) 
										:@selector(Create:) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaContext class], nil] 
										:[LuaViewInflator class]] 
			 forKey:@"Create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(ParseFile::)) 
									   :@selector(ParseFile::) 
									   :[LGView class]
									   :MakeArray([NSString class]C [LGView class]C nil)]
			 forKey:@"ParseFile"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Inflate::))
                                       :@selector(Inflate::)
                                       :[LGView class]
                                       :MakeArray([LuaRef class]C [LGView class]C nil)]
             forKey:@"Inflate"];
	return dict;
}

@end
