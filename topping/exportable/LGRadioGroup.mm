#import "LGRadioGroup.h"
#import "LuaFunction.h"
#import "LuaTranslator.h"
#import "Defines.h"

@implementation LGRadioGroup

-(UIView*)createComponent
{
	/*UIView *myView = [[UIView alloc] init];
	myView.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return myView;*/
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
	segmentedControl.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
	return segmentedControl;
	//segmentedControl.selectedSegmentIndex = 1;	
}

//Lua
+(LGRadioGroup*)create:(LuaContext *)context
{
	LGRadioGroup *lst = [[LGRadioGroup alloc] init];
    lst.lc = context;
	[lst initProperties];
	return lst;
}

-(void)setOnCheckedChangedListener:(LuaTranslator*) lt
{
    self.ltOnCheckedChanged = lt;
    UISegmentedControl *sc = (UISegmentedControl*)self._view;
    [sc addTarget:lt action:lt.selector forControlEvents:UIControlEventValueChanged];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGRadioGroup className];
}

+ (NSString*)className
{
	return @"LGRadioGroup";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
										:@selector(create:) 
										:[LGRadioGroup class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGRadioGroup class]] 
			 forKey:@"create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnCheckedChangedListener:)) :@selector(setOnCheckedChangedListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnCheckedChangedListener"];
	return dict;
}

@end
