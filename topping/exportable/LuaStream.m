#import "LuaStream.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaValues.h"

@implementation LuaStream

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		self.type = -1;
	}
	return self;
}

-(bool)hasStream
{
    return self.type != NOSTREAM;
}

-(NSObject*)getStream
{
	if(self.type == -1)
	{
		logE("LuaStream", "Stream not set");
		return nil;
	}
	
	return self.stream_;
}

-(NSMutableData*)getData
{
	if(self.type == -1)
	{
        logE("LuaStream", "Stream not set");
		return nil;
	}
	else if(self.type == OUTPUTSTREAM)
	{
        logE("LuaStream", "Cannot get data on output stream");
		return nil;
	}
	
    if(self.data != nil)
        return [self.data mutableCopy];
    
	NSMutableData *_dataL = [NSMutableData data];
	
	uint8_t buf[1024];
	
	unsigned int len = 0;
	
	NSInputStream *is = (NSInputStream*)[self getStream];
	while([is hasBytesAvailable])
	{
		len = [is read:buf maxLength:1024];
		
		if(len)
		{
			[_dataL appendBytes:(const void *)buf length:len];
		}
	}
	
	return _dataL;
}

-(void)setStream:(NSObject*)str
{
    if(str == nil)
    {
        self.type = -1;
        self.stream_ = nil;
        return;
    }
	if([str isKindOfClass:[NSInputStream class]])
		self.type = INPUTSTREAM;
	else if([str isKindOfClass:[NSOutputStream class]])
		self.type = OUTPUTSTREAM;
    else
    {
        self.type = INPUTSTREAM;
        self.stream_ = [[NSInputStream alloc] initWithData:(NSData*)str];
        self.data = (NSData*)str;
        return;
    }
	
	self.stream_ = (NSStream*)str;
}

-(int)readOne
{
	if(self.type == OUTPUTSTREAM)
	{
        logE("LuaStream", "Tried to read output stream.");
		return -1;
	}
	
	NSInputStream *is = (NSInputStream*)self.stream_;
	uint8_t c;
	int result = [is read:&c maxLength:1];
	if(result < 0)
	{
        logE("LuaStream", "Cannot read stream");
	}
	return c;
}

-(void)read:(LuaBuffer*)bufferO :(int)offset :(int)length
{
	uint8_t *buffer = malloc(sizeof(uint8_t*) * length);
	
	NSInputStream *is = (NSInputStream*)self.stream_;
	[is setProperty:[NSNumber numberWithInt:offset] forKey:NSStreamFileCurrentOffsetKey];
	int result = [is read:buffer maxLength:length];
	if(result < 0)
	{
        logE("LuaStream", "Cannot read stream");
	}
    else
    {
        NSMutableArray *arr = [NSMutableArray array];
        for(int i = 0; i < result; i++)
        {
            [arr addObject:[NSString stringWithFormat:@"%c", buffer[i]]];
        }
        [bufferO.data removeAllObjects];
        [bufferO.data addObjectsFromArray:arr];
    }
    free(buffer);
}

-(void)writeOne:(int)oneByte
{
	if(self.type == INPUTSTREAM)
	{
        logE("LuaStream", "Tried to write input stream.");
		return;
	}
	
	NSOutputStream *os = (NSOutputStream*)self.stream_;
	uint8_t c = oneByte;
    int result = [os write:&c maxLength:1];
	if(result < 0)
	{
        logE("LuaStream", "Cannot write stream");
	}
}

-(void)write:(LuaBuffer*) bufferO :(int)offset :(int)length
{
	if(self.type == INPUTSTREAM)
	{
        logE("LuaStream", "Tried to write input stream.");
		return;
	}
	
	NSOutputStream *os = (NSOutputStream*)self.stream_;
    uint8_t *buffer = malloc(sizeof(uint8_t*) * length);
    for(int i = 0; i < length; i++)
    {
        buffer[i] = *[[bufferO.data objectAtIndex:i] cStringUsingEncoding:NSUTF8StringEncoding];
    }
	[os setProperty:[NSNumber numberWithInt:offset] forKey:NSStreamFileCurrentOffsetKey];
	int result = [os write:buffer maxLength:length];
	if(result < 0)
	{
        logE("LuaStream", "Cannot write stream");
	}
    free(buffer);
}

-(NSString*)GetId
{
	return @"LuaStream"; 
}

+ (NSString*)className
{
	return @"LuaStream";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getStream)) :@selector(getStream) :[NSObject class]	:MakeArray(nil)] forKey:@"getStream"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setStream:)) :@selector(setStream:) :nil	:MakeArray([NSObject class]C nil)] forKey:@"setStream"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(readOne)) :@selector(readOne) :[LuaInt class] :MakeArray(nil)] forKey:@"readOne"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(read:::)) :@selector(read:::) :nil :MakeArray([LuaBuffer class]C [LuaInt class]C [LuaInt class]C nil)] forKey:@"read"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(writeOne:)) :@selector(writeOne:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"writeOne"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(write:::)) :@selector(write:::) :nil :MakeArray([LuaBuffer class]C [LuaInt class]C [LuaInt class]C nil)] forKey:@"write"];
	return dict;
}

@end
