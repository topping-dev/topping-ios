#import "ToppingEngine.h"
#import "LG.h"
#import "LGListView.h"
#import "LGAdapterView.h"
#import "Defines.h"


@implementation LGAdapterView

-(NSObject *)getObject:(NSIndexPath*)indexPath
{
	NSObject *obj = nil;
	if(self.sections == nil)
		obj = [self.values objectAtIndex:indexPath.row];
	else 
	{
		int count = 0;
		for(NSString *key in self.sections)
		{
			if(count == indexPath.section)
			{
				LGAdapterView *view = [self.sections objectForKey:key];
				obj = [view getObject:indexPath];
				break;
			}
			count++;
		}
	}
	return obj;
}

-(int)getCount
{
	if(self.values != nil)
		return [self.values count];
	return 0;
}

-(int)getTotalHeight:(int)start
{
	int value = start;
	if(self.sections == nil)
	{
		for(NSObject *key in self.views)
		{
			NSObject *obj = [self.views objectForKey:key];
			value += [((LGView*)obj) getContentH];
		}
	}
	else 
	{
		for(NSString *key in self.sections)
		{
			LGAdapterView *view = [self.sections objectForKey:key];
			value = [view getTotalHeight:value];
		}
	}
	return value;
}

-(int)getTotalWidth:(int)start
{
	int value = start;
	if(self.sections == nil)
	{
		for(NSObject *key in self.views)
		{
			NSObject *obj = [self.views objectForKey:key];
			value += [((LGView*)obj) getContentW];
		}
	}
	else 
	{
		for(NSString *key in self.sections)
		{
			LGAdapterView *view = [self.sections objectForKey:key];
			value = [view getTotalWidth:value];
		}
	}
	return value;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.views == nil)
    {
        self.views = [[NSMutableDictionary alloc] init];
        self.cells = [[NSMutableDictionary alloc] init];
    }
    
	UITableViewCell* cell = [self.cells objectForKey:indexPath];
    
    if(cell == nil)
    {
        cell = [self generateCell:indexPath];
    }
	return cell;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	if(self.sections != nil)
		return [self.sections count];
	return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(self.sections != nil)
	{
		int count = 0;
		for(NSString *key in self.sections)
		{
			if(count == section)
			{
				LGAdapterView *view = [self.sections objectForKey:key];
				return [view getCount];
			}
			count++;
		}
	}
	return [self getCount];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.views == nil)
	{
		self.views = [[NSMutableDictionary alloc] init];
		self.cells = [[NSMutableDictionary alloc] init];
	}
	
	UITableViewCell *cell = [self.cells objectForKey:indexPath];
	if(cell == nil)
	{
        cell = [self generateCell:indexPath];
	}
	
	LGView *lgview = (LGView*)[self.views objectForKey:indexPath];
	if(lgview != nil)
        return [lgview getCalculatedHeight];
	else
		return 0;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	/*if(headers == nil)
		return @"";
	NSString *head = [headers objectForKey:[NSNumber numberWithInt:section]];
	if(head != nil)
		return head;*/
	return @"";
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	/*if(section != 0)
		return nil;
	return nil;*/
	return nil;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	/*if(section != 1)
		return nil;
	return nil;*/
	return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.ltItemSelected != nil)
	{
        LGView *detail = [self.views objectForKey:indexPath];
        if(detail == nil)
        {
            detail = [[LGView alloc] init];
        }
                                                //Detail View
		[self.ltItemSelected callIn:self.parent,       detail, [NSNumber numberWithInt:(indexPath.section + 1 * indexPath.row)], [self getObject:indexPath], nil];
	}
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
	/*if(characters != nil)
		return characters;
	
    return [[[NSArray alloc] init] autorelease];*/
	return nil;
}

-(NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return index;
}

-(UITableViewCell *)generateCell:(NSIndexPath*)indexPath
{
    static NSString *MyIdentifier = self.lua_id;
    
    UITableViewCell *cell;
        
    /*cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
    {*/
        /*[[NSBundle mainBundle] loadNibNamed:@"FriendsViewTableCell" owner:self options:nil];
         cell = uiTableViewCell;
         self.uiTableViewCell = nil;*/
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier];
    //}

    /*for(UIView *v in [cell subviews])
    {
        [v removeFromSuperview];
    }*/
    NSObject *obj = [self getObject:indexPath];

    LGView *lview = (LGView*)[self.ltOnAdapterView callIn:self.parent, [NSNumber numberWithInt:(indexPath.section + 1 * indexPath.row)], obj, nil, self.lc, nil];
    
    //Fix the cell height problem if match parent occured
    //We are trying to find the biggest height in wrap_content views
    //then we are going to set height to that
    if((COMPARE(lview.android_layout_height, @"fill_parent")
        || COMPARE(lview.android_layout_height, @"match_parent")))
    {
        /*int biggestHeight = 0;
        for(LGView *w in lview.subviews)
        {
            if((!COMPARE(w.layout_height, @"fill_parent")
                && !COMPARE(w.layout_height, @"match_parent")))
            {
                if(w.dHeight > biggestHeight)
                    biggestHeight = w.dHeight;
            }
        }
        
        lview.dHeight = biggestHeight;*/
        lview.dHeight = 0;
        CGRect lastFrame = [lview getView].frame;
        [[lview getView] setFrame:CGRectMake(lastFrame.origin.x, lastFrame.origin.y, lastFrame.size.width, lview.dHeight)];
    }
    
    [lview addSelfToParent:cell.contentView :nil];
    //[lgview._view setFrame:CGRectMake(lgview._view.frame.origin.x, lgview._view.frame.origin.y, 80, lgview._view.frame.size.height)];
    //[cell setFrame:lgview._view.frame];
    [self.views setObject:lview forKey:indexPath];
    [self.cells setObject:cell forKey:indexPath];
    
    return cell;
}

+(LGAdapterView*)create:(LuaContext *)context :(NSString*)lid
{
	LGAdapterView *view = [[LGAdapterView alloc] init];
    view.lua_id = lid;
    view.lc = context;
	return view;
}

-(LGAdapterView*)addSection:(NSString *)header :(NSString*) idV
{
	if(self.sections == nil)
		self.sections = [[NSMutableDictionary alloc] init];
	
	if(self.headers == nil)
		self.headers = [[NSMutableDictionary alloc] init];
	
	LGAdapterView *view = [[LGAdapterView alloc] init];
	view.lua_id = idV;
	[self.sections setObject:view forKey:header];
	[self.headers setObject:header forKey:idV];
	
	return view;
}

-(void)removeSection:(NSString*) header
{
	if(self.sections != nil)
		[self.sections removeObjectForKey:header];
	
	if(self.headers != nil)
	{
		NSString *keyToRemove = nil;
		for(NSString *key in self.headers)
		{
			NSString *headerIn = [self.headers objectForKey:key];
			
			if([header compare:headerIn] == 0)
			{
				keyToRemove = key;
				break;
			}
		}
		
		if(keyToRemove != nil)
			[self.headers removeObjectForKey:keyToRemove];
	}
}

-(void)addValue:(NSObject *)value
{
	if(self.values == nil)
		self.values = [NSMutableArray array];
    
    [self.values addObject:value];
}

-(void)removeValue:(NSObject*)value
{
	if(self.values == nil)
		return;
	
	[self.values removeObject:value];
}

-(void)clear
{
    if(self.values == nil)
        return;
    
    [self.values removeAllObjects];
}

-(void)setOnAdapterView:(LuaTranslator *)lt
{
    self.ltOnAdapterView =  lt;
}

-(void)setOnItemSelected:(LuaTranslator *)lt
{
    self.ltItemSelected = lt;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    return [LGAdapterView className];
}

+ (NSString*)className
{
    return @"LGAdapterView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create::)) 
										:@selector(create::) 
										:[LGAdapterView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGAdapterView class]] 
			 forKey:@"create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(addSection::)) :@selector(addSection::) :[LGAdapterView class] :MakeArray([NSString class]C [NSString class]C nil)] forKey:@"addSection"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(removeSection:)) :@selector(removeSection:) :nil :MakeArray([NSString class]C nil)] forKey:@"removeSection"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(addValue:)) :@selector(addValue:) :nil :MakeArray([NSObject class]C nil)] forKey:@"addValue"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(removeValue:)) :@selector(removeValue:) :nil :MakeArray([NSObject class]C nil)] forKey:@"removeValue"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(clear)) :@selector(clear) :nil :MakeArray(nil)] forKey:@"clear"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnItemSelected:)) :@selector(setOnItemSelected:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnItemSelected"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnAdapterView:)) :@selector(setOnAdapterView:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnAdapterView"];
	return dict;
}

@end
