#import "LuaViewInflator.h"
#import "LuaFunction.h"
#import "LGLayoutParser.h"
#import "LGView.h"
#import "LuaTranslator.h"
#import "Defines.h"
#import "LuaRef.h"

@implementation LuaViewInflator

+(NSObject *) create:(LuaContext*)lc
{
	return [[LuaViewInflator alloc] initWithContext:lc];
}

+(LuaViewInflator *)from:(LGLayoutParser*)parser {
    return [[LuaViewInflator alloc] initWithContext:[LuaForm getActiveForm].context];
}

- (instancetype)initWithContext:(LuaContext*) context {
    self = [super init];
    if (self) {
        self.context = context;
    }
    return self;
}

-(LGView*)parseFile:(NSString *)filename :(LGView*)parent
{
	LGView *lgview = nil;
	[[LGLayoutParser getInstance] parseXML:filename :[parent getView] :parent :self.context.form :&lgview];
	return lgview;
}

-(LGView*)inflate:(LuaRef*)ref : (LGView*)parent {
    LGView *lgview = nil;
    [[LGLayoutParser getInstance] parseRef:ref :[parent getView] :parent :self.context.form :&lgview];
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaContext class], nil] 
										:[LuaViewInflator class]] 
			 forKey:@"reate"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(parseFile::)) 
									   :@selector(parseFile::) 
									   :[LGView class]
									   :MakeArray([NSString class]C [LGView class]C nil)]
			 forKey:@"parseFile"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(inflate::))
                                       :@selector(inflate::)
                                       :[LGView class]
                                       :MakeArray([LuaRef class]C [LGView class]C nil)]
             forKey:@"inflate"];
	return dict;
}

@end
