#import "LuaStream.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaValues.h"

@implementation LuaStream

@synthesize type, stream;

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		type = -1;
	}
	return self;
}

-(bool)HasStream
{
    return self.type != NOSTREAM;
}

-(NSObject*)GetStream
{
	if(self.type == -1)
	{
		Loge("LuaStream", "Stream not set");
		return nil;
	}
	
	return self.stream;
}

-(NSMutableData*)GetData
{
	if(self.type == -1)
	{
		Loge("LuaStream", "Stream not set");
		return nil;
	}
	else if(self.type == OUTPUTSTREAM)
	{
		Loge("LuaStream", "Cannot get data on output stream");
		return nil;
	}
	
    if(self.data != nil)
        return [self.data mutableCopy];
    
	NSMutableData *_dataL = [NSMutableData data];
	
	uint8_t buf[1024];
	
	unsigned int len = 0;
	
	NSInputStream *is = (NSInputStream*)[self GetStream];
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

-(void)SetStream:(NSObject*)str
{
    if(str == nil)
    {
        self.type = -1;
        self.stream = nil;
        return;
    }
	if([str isKindOfClass:[NSInputStream class]])
		self.type = INPUTSTREAM;
	else if([str isKindOfClass:[NSOutputStream class]])
		self.type = OUTPUTSTREAM;
    else
    {
        self.type = INPUTSTREAM;
        self.stream = [[NSInputStream alloc] initWithData:(NSData*)str];
        self.data = (NSData*)str;
        return;
    }
	
	self.stream = (NSStream*)str;
}

-(int)ReadOne
{
	if(self.type == OUTPUTSTREAM)
	{
		Loge("LuaStream", "Tried to read output stream.");
		return -1;
	}
	
	NSInputStream *is = (NSInputStream*)self.stream;
	uint8_t c;
	int result = [is read:&c maxLength:1];
	if(result < 0)
	{
		Loge("LuaStream", "Cannot read stream");
	}
	return c;
}

-(void)Read:(LuaBuffer*)bufferO :(int)offset :(int)length
{
	uint8_t *buffer = malloc(sizeof(uint8_t*) * length);
	
	NSInputStream *is = (NSInputStream*)self.stream;
	[is setProperty:[NSNumber numberWithInt:offset] forKey:NSStreamFileCurrentOffsetKey];
	int result = [is read:buffer maxLength:length];
	if(result < 0)
	{
		Loge("LuaStream", "Cannot read stream");
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

-(void)WriteOne:(int)oneByte
{
	if(type == INPUTSTREAM)
	{
		Loge("LuaStream", "Tried to write input stream.");
		return;
	}
	
	NSOutputStream *os = (NSOutputStream*)self.stream;
	uint8_t c = oneByte;
    int result = [os write:&c maxLength:1];
	if(result < 0)
	{
		Loge("LuaStream", "Cannot write stream");
	}
}

-(void)Write:(LuaBuffer*) bufferO :(int)offset :(int)length
{
	if(type == INPUTSTREAM)
	{
		Loge("LuaStream", "Tried to write input stream.");
		return;
	}
	
	NSOutputStream *os = (NSOutputStream*)self.stream;
    uint8_t *buffer = malloc(sizeof(uint8_t*) * length);
    for(int i = 0; i < length; i++)
    {
        buffer[i] = *[[bufferO.data objectAtIndex:i] cStringUsingEncoding:NSUTF8StringEncoding];
    }
	[os setProperty:[NSNumber numberWithInt:offset] forKey:NSStreamFileCurrentOffsetKey];
	int result = [os write:buffer maxLength:length];
	if(result < 0)
	{
		Loge("LuaStream", "Cannot write stream");
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
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetStream)) :@selector(GetStream) :[NSObject class]	:MakeArray(nil)] forKey:@"GetStream"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetStream:)) :@selector(SetStream:) :nil	:MakeArray([NSObject class]C nil)] forKey:@"SetStream"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(ReadOne)) :@selector(ReadOne) :[LuaInt class] :MakeArray(nil)] forKey:@"ReadOne"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Read:::)) :@selector(Read:::) :nil :MakeArray([LuaBuffer class]C [LuaInt class]C [LuaInt class]C nil)] forKey:@"Read"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(WriteOne:)) :@selector(WriteOne:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"WriteOne"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Write:::)) :@selector(Write:::) :nil :MakeArray([LuaBuffer class]C [LuaInt class]C [LuaInt class]C nil)] forKey:@"Write"];
	return dict;
}

@end
