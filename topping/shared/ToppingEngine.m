#import "ToppingEngine.h"
#import "LuaInterface.h"
#import "LuaTranslator.h"
#import "LuaValues.h"

#include "LuaCPlusPlusHelper.h"

#import "LuaContext.h"
#import "lstate.h"
#import "lobject.h"
#import "lualib.h"
#import "lua.h"
#import "lauxlib.h"
#import "compat-5.2.h"

#import "Lunar.h"

#import "Defines.h"

#import "LuaViewInflator.h"

#import "LuaDefines.h"
#import "LuaNativeObject.h"
#import "LuaObjectStore.h"

#import "LuaBuffer.h"
#import "LuaColor.h"
#import "LuaDatabase.h"
#import "LuaDate.h"
#import "LuaDialog.h"
#import "LuaHttpClient.h"
#import "LuaJSON.h"
#import "LuaPoint.h"
#import "LuaRect.h"
#import "LuaResource.h"
#import "LuaStream.h"
#import "LuaToast.h"
#import "LuaStore.h"
#import "LuaRef.h"
#import "LuaThread.h"
#import "LuaLog.h"
#import "LuaNativeCall.h"

#import "LGParser.h"

#import "LGAbsListView.h"
#import "LGAdapterView.h"
#import "LGAutoCompleteTextView.h"
#import "LGButton.h"
#import "LGCheckBox.h"
#import "LGComboBox.h"
#import "LGCompoundButton.h"
#import "LGConstraintLayout.h"
#import "LGDatePicker.h"
#import "LGEditText.h"
#import "LGLinearLayout.h"
#import "LGListView.h"
#import "LGProgressBar.h"
#import "LGRadioButton.h"
#import "LGRadioGroup.h"
#import "LGScrollView.h"
#import "LGHorizontalScrollView.h"
#import "LGTextView.h"
#import "LGView.h"
#import "LGRecyclerView.h"
#import "LGRecyclerViewAdapter.h"
#import "LGToolbar.h"
#import "LGFragmentContainerView.h"
#import "LuaNavHostFragment.h"
#import "LGBottomNavigationView.h"
#import "LGNavigationView.h"
#import "LGTextInputEditText.h"

#import "LuaForm.h"
#import "LuaFragment.h"

#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>

@implementation ToppingEngine

@synthesize scriptsRoot, primaryLoad, forceLoad, uiRoot, mainUI, mainForm, appStyle;

static NSMutableArray *plugins;
static NSMutableArray *viewPlugins;

+(void)addLuaPlugin:(Class) plugin
{
    if(plugins == nil)
        plugins = [NSMutableArray array];
    if(viewPlugins == nil)
        viewPlugins = [NSMutableArray array];
    [plugins addObject:plugin];
    if([plugin isKindOfClass:[LGView class]])
    {
        [viewPlugins addObject:plugin];
    }
}

+(NSArray*)getViewPlugins
{
    return viewPlugins;
}

+(void)report: (lua_State *) L
{
    const char * msg = lua_tostring(L,-1);
    if(msg != NULL) {
        NSString *str = [NSString stringWithCString:msg encoding:NSUTF8StringEncoding];
        str = REPLACE(str, [[NSBundle mainBundle] bundlePath], @"");
        NSLog(@"ToppingEngine Lua Error: %@", str);
#ifdef DEBUG
        [LuaDialog messageBoxInternal:nil :@"error" :str];
#endif
    }
}

-(void)startupDownload
{
	lu = lua_open();
	
	GuiBindingMap = [[NSMutableDictionary alloc] init];
	TagMap = [[NSMutableDictionary alloc] init];
	
	[self loadScriptsDownload];
}

int handleLuaError(lua_State* L) {
    const char * msg = lua_tostring(L, -1);
    luaL_traceback(L, L, msg, 2);
    lua_remove(L, -2); // Remove error/"msg" from stack.
    return 1; // Traceback is returned.
}

int lua_mypcall( lua_State* L, int nargs, int nret ) {
  /* calculate stack position for message handler */
  int hpos = lua_gettop( L ) - nargs;
  int ret = 0;
  /* push custom error message handler */
  lua_pushcfunction( L, handleLuaError );
  /* move it before function and arguments */
  lua_insert( L, hpos );
  /* call lua_pcall function with custom handler */
  ret = lua_pcall( L, nargs, nret, hpos );
  /* remove custom error message handler from stack */
  lua_remove( L, hpos );
  /* pass return value of lua_pcall */
  return ret;
}

-(void)loadScriptsDownload
{
	luaL_openlibs(lu);
	[self registerCoreFunctions];
	[self registerGlobals];
	NSFileManager *fm = [NSFileManager defaultManager];	
	NSString  *scriptPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/LuaScripts/"];
	NSBundle *bund = [NSBundle mainBundle];
	if(![fm fileExistsAtPath:scriptPath])
		[fm createDirectoryAtPath:scriptPath attributes:nil];
	
	NSArray *paths = [bund pathsForResourcesOfType:@"lua" inDirectory:nil];
	for(NSString *myStr in paths)
	{
		NSArray *parts = [myStr componentsSeparatedByString:@"/"];
		NSString *filename = [parts objectAtIndex:[parts count]-1];
		NSString *writeTo = [scriptPath stringByAppendingPathComponent:filename];
		if(![fm fileExistsAtPath:writeTo])
		{
			NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:myStr];
			NSData *dat = [f readDataToEndOfFile];
			[dat writeToFile:writeTo atomically:YES];
		}
	}
	
	paths = [fm directoryContentsAtPath:scriptPath];	
	for(NSString *myStr in paths)
	{
		NSString *readTo = [scriptPath stringByAppendingPathComponent:myStr];
		NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:readTo];
		NSData *dat = [f readDataToEndOfFile];
		NSDictionary *attrs = [fm attributesOfItemAtPath:readTo error:NULL];
		unsigned long long fSize = [attrs fileSize];
		const char *fileName = [myStr cStringUsingEncoding:NSASCIIStringEncoding];
		const char *byt = (const char *)[dat bytes];
		if(luaL_loadbuffer(lu, byt, fSize, fileName) != 0)
		{
			NSLog(@"LUAEngine: \033[22;31m loading %@ failed.(could not load)", myStr);
			[ToppingEngine report: lu];
		}
		else
		{
			if(lua_pcall(lu, 0, 0, 0) != 0)
			{
				NSLog(@"LUAEngine: \033[22;31m loading %@ failed.(could not load)", myStr);
				[ToppingEngine report: lu];
			}
		}
		
		[f closeFile];
	}
}

-(void)startup
{
	lu = lua_open();
	
	GuiBindingMap = [[NSMutableDictionary alloc] init];
	TagMap = [[NSMutableDictionary alloc] init];
	
	[self loadScripts];
}

-(void)loadScripts
{
	luaL_openlibs(lu);
	[self registerCoreFunctions];
	[self registerGlobals];
	
	NSFileManager *fm = [NSFileManager defaultManager];	
	//NSString  *scriptPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/LuaScripts/"];
	NSBundle *bund = [NSBundle mainBundle];
	/*if(![fm fileExistsAtPath:scriptPath])
		[fm createDirectoryAtPath:scriptPath attributes:nil];*/
	
	NSString *path = [bund pathForResource:@"defines" ofType:@"lua"];
	NSLog(@"%@", path);
	NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:path];
	NSData *dat = [f readDataToEndOfFile];
	NSDictionary *attrs = [fm attributesOfItemAtPath:path error:NULL];
	unsigned long long fSize = [attrs fileSize];
	const char *fileName = [path cStringUsingEncoding:NSASCIIStringEncoding];
	const char *byt = (const char *)[dat bytes];
	if(luaL_loadbuffer(lu, byt, fSize, fileName) != 0)
	{
		NSLog(@"LUAEngine: loading %@ failed.(could not load)", path);
		[ToppingEngine report: lu];
	}
	else
	{
		if(lua_pcall(lu, 0, 0, 0) != 0)
		{
			NSLog(@"LUAEngine: loading %@ failed.(could not load)", path);
			[ToppingEngine report: lu];
		}
	}
	
	[f closeFile];
	
	
	self.scriptsRoot = @"scripts";
	lua_getglobal(lu, "ScriptsRoot");
	if(lua_isstring(lu, -1) == 0)
		NSLog(@"LuaEngine: ScriptsRoot must be string");
	else
		self.scriptsRoot = lua_tonsstring(lua_tostring(lu, -1));
	lua_pop(lu, 1);
	
	self.primaryLoad = 1;
	lua_getglobal(lu, "PrimaryLoad");
	if(lua_isnumber(lu, -1) == 0)
		NSLog(@"LuaEngine: PrimaryLoad must be number");
	else
		self.primaryLoad = lua_tointeger(lu, -1);
	lua_pop(lu, 1);
	
	self.forceLoad = 0;
	lua_getglobal(lu, "ForceLoad");
	if(lua_isnumber(lu, -1) == 0)
		NSLog(@"LuaEngine: ForceLoad must be number");
	else
		self.forceLoad = lua_tonumber(lu, -1);
	lua_pop(lu, 1);
	
	self.uiRoot = @"ui";
	lua_getglobal(lu, "UIRoot");
	if(lua_isstring(lu, -1) == 0)
		NSLog(@"LuaEngine: UIRoot must be string");
	else
		self.uiRoot = lua_tonsstring(lua_tostring(lu, -1));
	lua_pop(lu, 1);
	
	self.mainUI = @"main.xml";
	lua_getglobal(lu, "MainUI");
	if(lua_isstring(lu, -1) == 0)
		NSLog(@"LuaEngine: MainUI must be string");
	else
		self.mainUI = lua_tonsstring(lua_tostring(lu, -1));
	lua_pop(lu, 1);
	
	self.mainForm = @"Main";
	lua_getglobal(lu, "MainForm");
	if(lua_isstring(lu, -1) == 0)
		NSLog(@"LuaEngine: MainForm must be string");
	else
		self.mainForm = lua_tonsstring(lua_tostring(lu, -1));
	lua_pop(lu, 1);
    
    self.appStyle = @"Theme.AppCompat.Light";
    lua_getglobal(lu, "AppStyle");
    if(lua_isstring(lu, -1) == 0)
        NSLog(@"LuaEngine: AppStyle must be string");
    else
        self.appStyle = lua_tonsstring(lua_tostring(lu, -1));
    lua_pop(lu, 1);
	
	[[LGParser getInstance] initialize];
    
    [LuaRef resourceLoader];
	
	[self startupDefines];
	/*
	
	NSFileManager *fm = [[NSFileManager alloc] init];
	NSBundle *bund = [NSBundle mainBundle];
	NSArray *paths = [bund pathsForResourcesOfType:@"lua" inDirectory:nil];
	for(NSString *myStr in paths)
	{
		NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:myStr];
		NSData *dat = [f readDataToEndOfFile];
		NSDictionary *attrs = [fm attributesOfItemAtPath:myStr error:NULL];
		unsigned long long fSize = [attrs fileSize];
		const char *fileName = [myStr cStringUsingEncoding:NSASCIIStringEncoding];
		const char *byt = (const char *)[dat bytes];
		if(luaL_loadbuffer(lu, byt, fSize, fileName) != 0)
		{
			NSLog(@"LUAEngine: \033[22;31m loading %s failed.(could not load)", myStr);
			[ToppingEngine report: lu];
		}
		else
		{
			if(lua_pcall(lu, 0, 0, 0) != 0)
			{
				NSLog(@"LUAEngine: \033[22;31m loading %s failed.(could not load)", myStr);
				[ToppingEngine report: lu];
			}
		}

		[f closeFile];
		NSLog(@"%s", myStr);
	}
	[fm dealloc];*/
}

-(void)startupDefines
{
	NSFileManager *fm = [NSFileManager defaultManager];	

	switch (primaryLoad) 
	{
		case EXTERNAL_DATA:
		case INTERNAL_DATA:
		{
			//Scripts
			{
				NSString  *scriptPath = [NSHomeDirectory() stringByAppendingPathComponent:APPEND(@"Documents/", self.scriptsRoot)];
				NSBundle *bund = [NSBundle mainBundle];
				if(![fm fileExistsAtPath:scriptPath])
					[fm createDirectoryAtPath:scriptPath attributes:nil];
				
				NSArray *paths = [bund pathsForResourcesOfType:@"lua" inDirectory:self.scriptsRoot];
				for(NSString *myStr in paths)
				{
					NSArray *parts = [myStr componentsSeparatedByString:@"/"];
					NSString *filename = [parts objectAtIndex:[parts count]-1];
					if(COMPARE(filename, @"defines.lua")
					   || COMPARE(filename, @"debugger.lua")
					   || COMPARE(filename, @"debugintrospection.lua")
					   || COMPARE(filename, @"ltn12.lua")
					   || COMPARE(filename, @"mime.lua")
					   || COMPARE(filename, @"ftp.lua")
					   || COMPARE(filename, @"http.lua")
					   || COMPARE(filename, @"smtp.lua")
					   || COMPARE(filename, @"tp.lua")
					   || COMPARE(filename, @"url.lua")
					   || COMPARE(filename, @"socket.lua"))
						continue;
					NSString *writeTo = [scriptPath stringByAppendingPathComponent:filename];
					if(![fm fileExistsAtPath:writeTo] || self.forceLoad > 0)
					{
						if([fm fileExistsAtPath:writeTo])
							[fm removeItemAtPath:writeTo error:nil];
						
						NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:myStr];
						NSData *dat = [f readDataToEndOfFile];
						[dat writeToFile:writeTo atomically:YES];
					}
				}
				
				NSArray *bundlePaths = paths;
				paths = [fm directoryContentsAtPath:scriptPath];	
				for(NSString *myStr in paths)
				{
					BOOL found = NO;
					for(NSString *bundlePath in bundlePaths)
					{
						NSString *fname = [bundlePath lastPathComponent];
						if(COMPARE(myStr, fname))
						{
							found = YES;
							break;
						}
					}
					if(!found)
					{
						[fm removeItemAtPath:myStr error:nil];
						continue;
					}
                    lua_pushcfunction(lu, handleLuaError);
					if(luaL_loadfile(lu, [myStr cStringUsingEncoding:NSASCIIStringEncoding]) != 0)
					{
						NSLog(@"LUAEngine: loading %@ failed.(could not load)", myStr);
						[ToppingEngine report: lu];
                        lua_pop(lu, 1);
					}
					else
					{
						if(lua_pcall(lu, 0, 0, -2) != 0) //-2 error func
						{
							NSLog(@"LUAEngine: loading %@ failed.(could not load)", myStr);
							[ToppingEngine report: lu];
                            lua_pop(lu, 1); //pop traceback
						}
					}
                    lua_pop(lu, 1); //pop handleLuaError
					
					//[f closeFile];
				}
			}
			
			//UI
			{
				NSString  *scriptPath = [NSHomeDirectory() stringByAppendingPathComponent:APPEND(@"Documents/", self.uiRoot)];
				NSBundle *bund = [NSBundle mainBundle];
				if(![fm fileExistsAtPath:scriptPath])
					[fm createDirectoryAtPath:scriptPath attributes:nil];
				
				NSArray *paths = [bund pathsForResourcesOfType:@"xml" inDirectory:@"ui"];
				for(NSString *myStr in paths)
				{
					/*if(!CONTAINS(myStr, uiRoot))
						continue;*/
					NSArray *parts = [myStr componentsSeparatedByString:@"/"];
					NSString *filename = [parts objectAtIndex:[parts count]-1];
					NSString *writeTo = [scriptPath stringByAppendingPathComponent:filename];
					if(![fm fileExistsAtPath:writeTo] || self.forceLoad > 0)
					{
						if([fm fileExistsAtPath:writeTo])
							[fm removeItemAtPath:writeTo error:nil];
						
						NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:myStr];
						NSData *dat = [f readDataToEndOfFile];
						[dat writeToFile:writeTo atomically:YES];
					}
				}
			}
		}break;
		case RESOURCE_DATA:
		default:
		{
			NSBundle *bund = [NSBundle mainBundle];
#if TARGET_OS_MACCATALYST
            NSString *pathToSearch = [bund resourcePath];
#else
            NSString *pathToSearch = [bund bundlePath];
#endif
			//Scripts
			{
				//NSArray *paths = [bund pathsForResourcesOfType:@"lua" inDirectory:nil];
                NSArray *paths = recursivePathsForResourceOfType(@"lua", pathToSearch);
				for(NSString *myStr in paths)
				{	
					NSString *filename = myStr;
					if(ENDS_WITH(filename, @"defines.lua")
					   || ENDS_WITH(filename, @"debugger.lua")
					   || ENDS_WITH(filename, @"debugintrospection.lua")
					   || ENDS_WITH(filename, @"ltn12.lua")
					   || ENDS_WITH(filename, @"mime.lua")
					   || ENDS_WITH(filename, @"ftp.lua")
					   || ENDS_WITH(filename, @"http.lua")
					   || ENDS_WITH(filename, @"smtp.lua")
					   || ENDS_WITH(filename, @"tp.lua")
					   || ENDS_WITH(filename, @"url.lua")
					   || ENDS_WITH(filename, @"socket.lua"))
						continue;
					NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:myStr];
					NSData *dat = [f readDataToEndOfFile];
					NSDictionary *attrs = [fm attributesOfItemAtPath:myStr error:NULL];
					unsigned long long fSize = [attrs fileSize];
					const char *fileName = [[myStr lastPathComponent] cStringUsingEncoding:NSASCIIStringEncoding];
					const char *byt = (const char *)[dat bytes];
                    lua_pushcfunction(lu, handleLuaError);
					if(luaL_loadbuffer(lu, byt, fSize, fileName) != 0)
					{
						NSLog(@"LUAEngine: loading '%@' failed.(could not load)", filename);
						[ToppingEngine report: lu];
                        lua_pop(lu, 1);
					}
					else
					{
						if(lua_pcall(lu, 0, 0, -2) != 0)
						{
                            NSLog(@"LUAEngine: loading '%@' failed.(could not load)", filename);
							[ToppingEngine report: lu];
                            lua_pop(lu, 1);
                        }
                        else
                        {
                            NSLog(@"LuaEngine: Loaded %@", filename);
                        }
					}
                    lua_pop(lu, 1);
					
					[f closeFile];
				}
			}
			
			//UI
			{
			}
		}break;
	}
}

-(void)restart
{
	NSLog(@"LuaEngine: Restarting Engine.\r\n");
	[self unload];
	lu = lua_open();
	[self loadScripts];
	NSLog(@"LuaEngine: Done restarting engine.");
}

-(void)unload
{
	lua_close(lu);
	{
		[GuiBindingMap removeAllObjects];
		[TagMap removeAllObjects];
	}
}

-(bool)beginCall:(NSString *)func
{
	const char * sFuncName = [func cStringUsingEncoding:NSASCIIStringEncoding];
	char * copy = strdup(sFuncName);
	char * token = strtok(copy,".:");
	bool colon = false;
	if (strpbrk(sFuncName,".:") == NULL )
		lua_getglobal(lu,sFuncName);
	else
	{
		lua_getglobal(lu, "_G"); //start out with the global table.
		int top = 1;
		while (token != NULL)
		{
			lua_getfield(lu, -1, token); //get the (hopefully) table/func
			NSString *NStoken = [NSString stringWithCString:token encoding:NSASCIIStringEncoding];
			NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:NStoken];
			NSRange range = [func rangeOfCharacterFromSet:charSet];
			if (range.location != NSNotFound && range.location-1 > 1) //if it isn't the first token
			{				
				if([NStoken characterAtIndex:range.location-1] == '.') //if it was a .
					colon = false;
				else if([NStoken characterAtIndex:range.location-1] == ':')
					colon = true;
			}
			else //if it IS the first token, we're OK to remove the "_G" from the stack
				colon = false;
			
			if (lua_isfunction(lu,-1) && !lua_iscfunction(lu,-1)) //if it's a Lua function
			{
				lua_replace(lu,top);
				if (colon)
				{
					lua_pushvalue(lu, -1); //make the table the first arg
					lua_replace(lu,top+1);
					lua_settop(lu,top+1);
				}
				else
					lua_settop(lu,top);
				break; //we don't need anything else
			}
			else if(lua_istable(lu,-1) )
				token = strtok(NULL,".:");
		}
	}
	return colon;
}

-(bool)executeCall:(uint8)params :(uint8)res
{
	bool ret = true;
	if(lua_pcall(lu,params,res,0) )
	{
		[ToppingEngine report: lu];
		ret = false;
	}
	return ret;	
}

-(void)endCall:(uint8)res
{
	for(int i = res; i > 0; i--)
	{
		if(!lua_isnone(lu,res))
			lua_remove(lu,res);
	}
}

-(void)callFunction:(NSString *)FunctionName :(int)ref
{
	int top = lua_gettop(lu);
	int args = 0;
	const char * sFuncName = [FunctionName cStringUsingEncoding:NSASCIIStringEncoding]; //for convenience of string funcs
	char * copy = strdup(sFuncName);
	char * token = strtok(copy, ".:"); //we should strtok on the copy
	bool colon = false; //whether we should keep or remove the previous table
	if (strpbrk(sFuncName,".:") == NULL)
		lua_getglobal(lu,sFuncName);
	else
	{
		lua_getglobal(lu, "_G"); //start out with the global table.
		while (token != NULL)
		{
			lua_getfield(lu, -1, token); //get the (hopefully) table/func
			NSString *NStoken = [NSString stringWithCString:token encoding:NSASCIIStringEncoding];
			NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:NStoken];
			NSRange range = [FunctionName rangeOfCharacterFromSet:charSet];
			if (range.location != NSNotFound && range.location-1 > 1) //if it isn't the first token
			{				
				if([NStoken characterAtIndex:range.location-1] == '.') //if it was a .
					colon = false;
				else if([NStoken characterAtIndex:range.location-1] == ':')
					colon = true;
			}
			else //if it IS the first token, we're OK to remove the "_G" from the stack
				colon = false;
			
			if (lua_isfunction(lu,-1) && !lua_iscfunction(lu,-1)) //if it's a Lua function
			{
				if (colon)
				{
					lua_pushvalue(lu, -2); //make the table the first arg
					lua_remove(lu, -3); //remove the thing we copied from (just to keep stack nice)
					++args;
				}
				else
				{
					lua_remove(lu, -2);
				}
				break; //we don't need anything else
			}
			else if (lua_istable(lu,-1))
			{
				token = strtok(NULL, ".:");
			}
		}
	}
	lua_rawgeti(lu, LUA_REGISTRYINDEX, ref);
	lua_State * M = lua_tothread(lu, -1); //repeats, args
	int thread = lua_gettop(lu);
	int repeats = luaL_checkinteger(M, 1); //repeats, args
	int nargs = lua_gettop(M)-1;
	if (nargs != 0) //if we HAVE args...
	{
		for (int i = 2; i <= nargs+1; i++)
		{
			lua_pushvalue(M,i);
		}
		lua_xmove(M, lu, nargs);
	}
	if (--repeats == 0) //free stuff, then
	{
		//free((void*)FuncName);
		luaL_unref(lu, LUA_REGISTRYINDEX, ref);
	}
	else
	{
		lua_remove(M, 1); //args
		lua_pushinteger(M, repeats); //args, repeats
		lua_insert(M, 1); //repeats, args
	}
	lua_remove(lu, thread); //now we can remove the thread object
	int r = lua_pcall(lu,nargs+args,0,0);
	if (r)
		[ToppingEngine report: lu];
	
	free((void*)copy);
	lua_settop(lu,top);
}

- (BOOL) isBoolNumber:(NSNumber *)num
{
   CFTypeID boolID = CFBooleanGetTypeID(); // the type ID of CFBoolean
   CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(num)); // the type ID of num
   return numID == boolID;
}

-(void)fillVariable:(NSObject*)val
{
	if(val == nil || val == NULL || (&val) == 0x1)
	{
		[self pushNil];
		return;
	}
	if([val isKindOfClass:[NSNumber class]])
	{
		NSNumber* num = (NSNumber*)val;
		if([self isBoolNumber:num])
			[self pushBool:[num boolValue]];
		else if(!strcmp([num objCType], @encode(unsigned char)))
			[self pushInt:[num unsignedCharValue]];
		else if(!strcmp([num objCType], @encode(char)))
		{
			char c = [num charValue];
			char *cP = &c;
			[self pushString:[NSString  stringWithCString:cP encoding:NSUTF8StringEncoding]];
		}		
		else if(!strcmp([num objCType], @encode(int)))
			[self pushInt:[num intValue]];
		else if(!strcmp([num objCType], @encode(unsigned int)))
			[self pushUInt:[num unsignedIntValue]];
		else if(!strcmp([num objCType], @encode(long)))
			[self pushLong:[num longValue]];
		else if(!strcmp([num objCType], @encode(unsigned long)))
			[self pushLong:[num unsignedLongValue]];
		else if(!strcmp([num objCType], @encode(long long)))
			[self pushDouble:[num longLongValue]];
		else if(!strcmp([num objCType], @encode(unsigned long long)))
			[self pushDouble:[num unsignedLongLongValue]];	 
		else if(!strcmp([num objCType], @encode(float)))
			[self pushFloat:[num floatValue]];
		else if(!strcmp([num objCType], @encode(double)))
			[self pushDouble:[num doubleValue]];
	}
	else if([val isKindOfClass:[NSString class]])
		[self pushString:(NSString*)val];
	else if([val isKindOfClass:[NSMutableDictionary class]])
		[self pushTable:(NSMutableDictionary*)val];
	else
		[Lunar push:lu :val :true];
}

-(void)registerTag:(const char*)nibC :(int)tag :(const char *)strTag
{
	NSString *nib = [NSString stringWithCString:nibC encoding:NSASCIIStringEncoding];
	if([TagMap objectForKey:nib] != nil)
		[[TagMap objectForKey:nib] setObject:[NSString stringWithCString:strTag encoding:NSASCIIStringEncoding] forKey:[NSNumber numberWithInt:tag]];
	else
	{
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		[dict setObject:[NSString stringWithCString:strTag encoding:NSASCIIStringEncoding] forKey:[NSNumber numberWithInt:tag]];
		[TagMap setObject:dict forKey:nib];
	}
	//[TagMap setObject:[NSString stringWithCString:strTag encoding:NSASCIIStringEncoding] forKey:[NSNumber numberWithInt:tag]];
}

-(NSString *)getTag:(NSString*)nib :(int)tag
{
	return [[TagMap objectForKey:nib] objectForKey:[NSNumber numberWithInt:tag]];
}

-(NSObject*)OnGuiEventResult
{
    NSObject *retVal = nil;
    StkId valTest = lu->top;
    if(lua_isnoneornil(lu, -1))
        retVal = nil;
    else if(lua_isboolean(lu, -1))
        retVal = [NSNumber numberWithBool:(lua_toboolean(lu, -1) == 1) ? YES : NO];
    else if(lua_type(lu, -1) == LUA_TNUMBER)
        retVal = [NSNumber numberWithDouble:lua_tonumber(lu, -1)];
    else if(lua_isstring(lu, -1) > 0)
        retVal = [NSString stringWithCString:lua_tostring(lu, -1) encoding:NSUTF8StringEncoding];
    else
    {
        void **ptr = (void**)lua_touserdata(lu, -1);
        if(ptr != NULL)
        {
            NSObject *o = *ptr;
            retVal = o;
        }
        else if(valTest->tt == 6)
        {
            retVal = nil;
        }
        else
        {
            //Table
            const void *o = lua_topointer(lu, -1);
            if(o == NULL)
                return 0;
            Table *ot = (Table*)o;
            NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
            int size = sizenode(ot);
            for(int i = 0; i < size; i++)
            {
                Node *node = gnode(ot, i);
                TValue *key = key2tval(node);
                NSObject *keyObject = nil;
                switch(ttype(key))
                {
                    case LUA_TNIL:
                        break;
                    case LUA_TSTRING:
                    {
                        keyObject = [NSString stringWithCString:getStr(key) encoding:NSUTF8StringEncoding];
                    }break;
                    case LUA_TNUMBER:
                        keyObject = [NSNumber numberWithDouble:nvalue(key)];
                        break;
                    default:
                        break;
                }
                
                const TValue *val = luaH_get(ot, key);
                NSObject *valObject = nil;
                switch(ttype(val))
                {
                    case LUA_TNIL:
                        break;
                    case LUA_TSTRING:
                    {
                        valObject = [NSString stringWithCString:getStr((TValue*)val) encoding:NSUTF8StringEncoding];
                    }break;
                    case LUA_TNUMBER:
                        valObject = [NSNumber numberWithDouble:nvalue(val)];
                        break;
                    case LUA_TTABLE:
                        valObject = [Lunar parseTable:(TValue*)val];
                        break;
                    case LUA_TUSERDATA:
                    {
                        void **ptr = rawUValue((TValue*)val);
                        valObject = *ptr;
                        if(valObject != NULL)
                        {
                            /*if(valObject.getClass().getName().startsWith("com.Resto.ScriptingEngine.LuaObject"))
                             {
                             Object objA = ((LuaObject<?>)valObject).obj;
                             if(objA == null)
                             {
                             Log.e("Lunar Push", "Cannot get lua object property static thunk");
                             return 0;
                             }
                             
                             valObject = objA;
                             }*/
                        }
                    }break;
                    case LUA_TLIGHTUSERDATA:
                    {
                        void **ptr = (void**)pvalue(val);
                        valObject = *ptr;
                        if(valObject != NULL)
                        {
                            /*if(valObject.getClass().getName().startsWith("com.Resto.ScriptingEngine.LuaObject"))
                             {
                             Object objA = ((LuaObject<?>)valObject).obj;
                             if(objA == null)
                             {
                             Log.e("Lunar Push", "Cannot get lua object property static thunk");
                             return 0;
                             }
                             
                             valObject = objA;
                             }*/
                        }
                    }break;
                }
                [map setObject:valObject forKey:keyObject];
            }
            retVal = map;
        }
    }
    
    if(lu->top > valTest)
        lua_pop(lu, 1);
    return retVal;
}

-(NSObject*)onNativeEventArgs:(NSObject *)pGui :(int)ref :(NSArray *)Args
{
    /*if(table == nil)
        return nil;
    
    Table *t = (Table*)table;
    
    //m_Lock.Acquire();
    lua_pushlightuserdata(lu, table);
    lua_gettable(lu, -1);*/
    /*lua_gettable(lu, LUA_GLOBALSINDEX);
    if(lua_isnil(lu,-1))
    {
        NSLog(@"Tried to call invalid LUA function from LuaEngine!\n");
        //m_Lock.Release();
        return nil;
    }*/
    
    lua_rawgeti(lu, LUA_REGISTRYINDEX, ref);
    
    [Lunar push:lu :pGui :false];
    int i = 0;
    for(NSObject* type in Args)
    {
        [self fillVariable :type];
        i++;
    }
    
    int r = lua_mypcall(lu, i+1, LUA_MULTRET);
    if(r)
    {
        [ToppingEngine report: lu];
        return nil;
    }
    
    return [self OnGuiEventResult];
}

-(NSObject*)onGuiEventArgs:(NSObject *)pGui :(NSString *)FunctionName :(NSArray *)Args
{
	if(FunctionName == nil)
		return nil;
    
#ifdef DEBUG
    NSLog(@"Calling %@", FunctionName);
#endif
	
	//m_Lock.Acquire();
	lua_pushstring(lu, [FunctionName cStringUsingEncoding:NSASCIIStringEncoding]);
	lua_gettable(lu, LUA_GLOBALSINDEX);
	if(lua_isnil(lu,-1))
	{
		NSLog(@"Tried to call invalid LUA function '%@' from LuaEngine!\n", FunctionName);
		//m_Lock.Release();
		return nil;
	}
	
	[Lunar push:lu :pGui :false];
	int i = 0;
	for(NSObject* type in Args)
	{
		[self fillVariable :type];
		i++;
	}
	
#if DEBUG
    lua_getglobal(lu, "debug");
    lua_getfield(lu, -1, "traceback");
    lua_remove(lu, -2);
    int errorIndex = -(i+1)-2;
    lua_insert(lu, errorIndex);
	int r = lua_pcall(lu, i+1, LUA_MULTRET, errorIndex);
#else
    int r = lua_pcall(lu,i+1,LUA_MULTRET,0);
#endif
	if(r)
    {
		[ToppingEngine report: lu];
        return nil;
    }
    
    return [self OnGuiEventResult];
}

int RegisterTag(lua_State *L)
{
    const char *nib = luaL_checkstring(L, 1);
    int tag = luaL_checkint(L, 2);
    const char *strTag = luaL_checkstring(L, 3);
    
    [sToppingEngine registerTag:nib :tag :strTag];
    
    return 0;
}

-(void)registerCoreFunctions
{
	lua_register(lu, "RegisterTag", RegisterTag);
	
	[Lunar register:lu :[LuaTranslator class]];
	
	[Lunar register:lu :[LuaContext class]];
	
	[Lunar register:lu :[LuaViewInflator class]];
	[Lunar register:lu :[LGAbsListView class]];
	[Lunar register:lu :[LGAdapterView class]];
	[Lunar register:lu :[LGAutoCompleteTextView class]];
    [Lunar register:lu :[LGBottomNavigationView class]];
	[Lunar register:lu :[LGButton class]];
	[Lunar register:lu :[LGCheckBox class]];
	[Lunar register:lu :[LGComboBox class]];
	[Lunar register:lu :[LGCompoundButton class]];
    [Lunar register:lu :[LGConstraintLayout class]];
    [Lunar register:lu :[LGConstraintBarrier class]];
    [Lunar register:lu :[LGConstraintCarousel class]];
    [Lunar register:lu :[LGConstraintCircularFlow class]];
    [Lunar register:lu :[LGConstraintFlow class]];
    [Lunar register:lu :[LGConstraintLayout class]];
    [Lunar register:lu :[LGConstraintLayout class]];
    [Lunar register:lu :[LGConstraintLayout class]];
    [Lunar register:lu :[LGConstraintLayout class]];
	[Lunar register:lu :[LGDatePicker class]];
    [Lunar register:lu :[LGDrawerLayout class]];
	[Lunar register:lu :[LGEditText class]];
    [Lunar register:lu :[LGFragmentContainerView class]];
    [Lunar register:lu :[LGFragmentStateAdapter class]];
	[Lunar register:lu :[LGFrameLayout class]];
    [Lunar register:lu :[LGImageView class]];
	[Lunar register:lu :[LGLinearLayout class]];
	[Lunar register:lu :[LGListView class]];
    [Lunar register:lu :[LGNavigationView class]];
	[Lunar register:lu :[LGProgressBar class]];
	[Lunar register:lu :[LGRadioButton class]];
	[Lunar register:lu :[LGRadioGroup class]];
    [Lunar register:lu :[LGRelativeLayout class]];
	[Lunar register:lu :[LGScrollView class]];
    [Lunar register:lu :[LGHorizontalScrollView class]];
    [Lunar register:lu :[LGTabLayout class]];
    [Lunar register:lu :[LGTextInputLayout class]];
    [Lunar register:lu :[LGTextInputEditText class]];
	[Lunar register:lu :[LGTextView class]];
	[Lunar register:lu :[LGView class]];
    [Lunar register:lu :[LGViewGroup class]];
    [Lunar register:lu :[LGViewPager class]];
    [Lunar register:lu :[LGRecyclerView class]];
    [Lunar register:lu :[LGRecyclerViewAdapter class]];
    [Lunar register:lu :[LGToolbar class]];
    [Lunar register:lu :[LGWebView class]];
	
	[Lunar register:lu :[LuaDefines class]];
	[Lunar register:lu :[LuaNativeObject class]];
	[Lunar register:lu :[LuaObjectStore class]];
    
    [Lunar register:lu :[LuaBuffer class]];
    [Lunar register:lu :[LuaBundle class]];
    [Lunar register:lu :[LuaColor class]];
	[Lunar register:lu :[LuaDatabase class]];
    [Lunar register:lu :[LuaDate class]];
    [Lunar register:lu :[LuaDialog class]];
    [Lunar register:lu :[LuaEvent class]];
   	[Lunar register:lu :[LuaForm class]];
    [Lunar register:lu :[LuaFormIntent class]];
    [Lunar register:lu :[LuaFragment class]];
   	[Lunar register:lu :[LuaHttpClient class]];
    [Lunar register:lu :[LuaJob class]];
	[Lunar register:lu :[LuaJSONObject class]];
	[Lunar register:lu :[LuaJSONArray class]];
    [Lunar register:lu :[LuaLog class]];
    [Lunar register:lu :[LuaMenu class]];
    [Lunar register:lu :[LuaNativeCall class]];
    [Lunar register:lu :[LuaPoint class]];
    [Lunar register:lu :[LuaRect class]];
    [Lunar register:lu :[LuaRef class]];
	[Lunar register:lu :[LuaResource class]];
    [Lunar register:lu :[LuaStore class]];
	[Lunar register:lu :[LuaStream class]];
    [Lunar register:lu :[LuaTab class]];
    [Lunar register:lu :[LuaThread class]];
	[Lunar register:lu :[LuaToast class]];
    
    [Lunar register:lu :[LuaAppBarConfiguration class]];
    [Lunar register:lu :[LuaCoroutineScope class]];
    [Lunar register:lu :[LuaDispatchers class]];
    [Lunar register:lu :[FragmentManager class]];
    [Lunar register:lu :[LuaLifecycle class]];
    [Lunar register:lu :[LuaLifecycleObserver class]];
    [Lunar register:lu :[LuaLifecycleOwner class]];
    [Lunar register:lu :[LuaLiveData class]];
    [Lunar register:lu :[LuaMutableLiveData class]];
    [Lunar register:lu :[LuaNavController class]];
    [Lunar register:lu :[NavigationUI class]];
    [Lunar register:lu :[NavOptions class]];
    [Lunar register:lu :[LuaNavHostFragment class]];
    [Lunar register:lu :[LuaViewModel class]];
    [Lunar register:lu :[LuaViewModelProvider class]];
    
    if(plugins != nil)
    {
        for(Class cls in plugins)
            [Lunar register:lu :cls];
    }
}

-(void)registerGlobals
{
#if TARGET_OS_MACCATALYST
    lua_pushstring(lu, "iOS");
#else
    lua_pushstring(lu, "iOS");
#endif
    lua_setglobal(lu, "OS_TYPE");

    lua_pushstring(lu, [[UIDevice currentDevice].systemVersion cStringUsingEncoding:NSUTF8StringEncoding]);
    lua_setglobal(lu, "OS_VERSION");
    
    lua_pushboolean(lu, [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    lua_setglobal(lu, "IS_TABLET");
}

-(lua_State *)getLuaState
{
	return lu;
}

-(void)pushBool:(bool)val
{
	if(val) 
		lua_pushboolean(lu,1);
	else 
		lua_pushboolean(lu,0);
}

-(void)pushNil
{
	lua_pushnil(lu);
}

-(void)pushInt:(int32)val
{
	lua_pushinteger(lu,val);
}

-(void)pushUInt:(uint32)val
{
	lua_pushnumber(lu,val);
}
			 
-(void)pushLong:(long)val
{
	lua_pushnumber(lu, val);
}

-(void)pushFloat:(float)val
{
	lua_pushnumber(lu, val);
}

-(void)pushDouble:(double)val
{
	lua_pushnumber(lu, val);
}

-(void)pushString:(NSString *)val
{
	lua_pushstring(lu, [val cStringUsingEncoding:NSUTF8StringEncoding]);
}

-(void)pushTable:(NSMutableDictionary *)val
{
	lua_lock(lu);
	BOOL created = false;
	if(!created)
	{
		created = true;
		lua_createtable(lu, 0, (int)[val count]);
	}
	for(NSObject* key in val) {
		NSObject* value = [val objectForKey:key];
		if(value != nil)
		{
			if([value class] == [LuaBool class]
			   || [value class] == [LuaChar class]
			   || [value class] == [LuaShort class]
			   || [value class] == [LuaInt class])
			{
				[self pushInt:[((NSNumber*)value) intValue]];
			}
			else if([value class] == [LuaLong class])
			{
				[self pushLong:[((NSNumber*)value) longValue]];
			}
			else if([value class] == [LuaFloat class]
					|| [value class] == [LuaDouble class])
			{
				[self pushDouble:[((NSNumber*)value) doubleValue]];
			}
			else if([value class] == [NSString class])
			{
				[self pushString:((NSString*)value)];
			}
			else if([value class] == [NSMutableDictionary class])
			{
				[self pushTable:((NSMutableDictionary*)value)];
			}
			else 
			{
				[Lunar push:lu :value :FALSE];
			}
		}		
		
		const char *ckey;
		if([key isKindOfClass:[NSNumber class]])
			ckey = [[((NSNumber*)key) stringValue] cStringUsingEncoding:NSUTF8StringEncoding];
		else
			ckey = [((NSString*)key) cStringUsingEncoding:NSUTF8StringEncoding];
		lua_setfield(lu, -2, ckey);
		//Lua.lua_pushstring(L, String.valueOf(entry.getKey()));
		/*
		 * To put values into the table, we first push the index, then the
		 * value, and then call lua_rawset() with the index of the table in the
		 * stack. Let's see why it's -3: In Lua, the value -1 always refers to
		 * the top of the stack. When you create the table with lua_newtable(),
		 * the table gets pushed into the top of the stack. When you push the
		 * index and then the cell value, the stack looks like:
		 *
		 * <- [stack bottom] -- table, index, value [top]
		 *
		 * So the -1 will refer to the cell value, thus -3 is used to refer to
		 * the table itself. Note that lua_rawset() pops the two last elements
		 * of the stack, so that after it has been called, the table is at the
		 * top of the stack.
		 */
		//Lua.lua_rawset(L, -3);
	}
	//Lua.sethvalue(L, obj, x)
	//Lua.luaH_new(L, narray, nhash)
	//Lua.setbvalue(L.top, (b != 0) ? 1 : 0); // ensure that true is 1
	//Lua.api_incr_top(L);
	lua_unlock(lu);
}

-(NSString *)getScriptsRoot
{
	return self.scriptsRoot;
}

-(int)getPrimaryLoad
{
	return self.primaryLoad;
}

-(NSString *)getUIRoot
{
	return self.uiRoot;
}

-(NSString *)getMainUI
{
	return self.mainUI;
}

-(NSString *)getMainForm
{
	return self.mainForm;
}

-(NSString *)getAppStyle
{
    return self.appStyle;
}

@end
