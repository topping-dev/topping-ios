#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaBuffer.h"

#define NOSTREAM -1
#define INPUTSTREAM 0
#define OUTPUTSTREAM 1

/**
 * Lua stream interface.
 * This class is used to manupulate streams.
 */
@interface LuaStream : NSObject <LuaClass, LuaInterface>
{
	int type;
	NSStream *stream;
    NSData *data;
}

-(bool)HasStream;
/**
 * Get stream.
 * @return InputStream or OutputStream value. 
 */
-(NSObject*)GetStream;
/**
 * Get data
 * @return table in lua
 */
-(NSMutableData*)GetData;
/**
 * Set stream.
 * @param stream InputStream or OutputStream value.
 */
-(void)SetStream:(NSObject*)str;
/**
 * Reads a single byte from this stream and returns it as an integer in the range from 0 to 255. Returns -1 if the end of the stream has been reached. Blocks until one byte has been read, the end of the source stream is detected or an exception is thrown.
 * @return integer value of byte.
 */
-(int)ReadOne;
/**
 * Reads at most length bytes from this stream and stores them in the byte array b starting at offset.
 * @param bufferO buffer object.
 * @param offset offset to start.
 * @param length length to read.
 */
-(void)Read:(LuaBuffer*)bufferO :(int)offset :(int)length;
/**
 * Writes a single byte to this stream. Only the least significant byte of the integer oneByte is written to the stream.
 * @param oneByte byte value.
 */
-(void)WriteOne:(int)oneByte;
/**
 * Writes count bytes from the byte array buffer starting at position offset to this stream.
 * @param bufferO buffer object.
 * @param offset offset to start.
 * @param length length to write.
 */
-(void)Write:(LuaBuffer*) bufferO :(int)offset :(int)length;

@property(nonatomic) int type;
@property(nonatomic, retain) NSStream *stream;
@property(nonatomic, retain) NSData *data;

@end
