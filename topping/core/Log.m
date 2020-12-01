#import "Log.h"


@implementation Log

+(void)Backtrace
{
	if([[NSThread class] respondsToSelector:@selector(callStackSymbols)])
	{
		NSLog(@"%@",[NSThread callStackSymbols]);
	}
	else
	{
		void *addr[2];
		int nframes = backtrace(addr, sizeof(addr)/sizeof(*addr));
		char **syms = backtrace_symbols(addr, nframes);
		if(syms != NULL)
		{
			for(int i = 0; i < nframes; i++)
			{
				NSLog(@"%s", syms[i]);
			}
			free(syms);
		}
/*		if (nframes > 1) {
			char **syms = backtrace_symbols(addr, nframes);
			NSLog(@"%s: caller: %s", __func__, syms[1]);
			free(syms);
		} else {
			NSLog(@"%s: *** Failed to generate backtrace.", __func__);
		}*/
	}	
}

+(void)d:(NSString *)tag :(NSString *)message
{
}

+(void)e:(NSString *)tag :(NSString *)message
{
	[Log Backtrace];
	NSLog(@"%@:%@",tag, message);
}

@end
