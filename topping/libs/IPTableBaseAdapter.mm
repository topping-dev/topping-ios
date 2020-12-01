#import "IPTableBaseAdapter.h"
#import "ToppingEngine.h"
#import "LGLayoutParser.h"


@implementation IPTableBaseAdapter

@synthesize filename;

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LGView *lgview;
	UIView *view = [[LGLayoutParser GetInstance] ParseXML:filename :nil :nil :nil :&lgview];
	if(view == nil)
		return nil;
	
	static NSString *CellIdentifier = filename;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell addSubview:view];
    }
	else 
	{
		for (UIView *subview in [cell subviews]) 
		{
			[subview removeFromSuperview];
		}
		[cell addSubview:view];
	}
	
    [LuaForm OnFormEvent:self :FORM_EVENT_CREATE :nil :0, nil];
    
    return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//TODO:do this
    return 0;
}

@end
