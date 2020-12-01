#import "LuaCPlusPlusHelper.h"

#include "lapi.h"
#include "ldebug.h"
#include "ldo.h"
#include "lfunc.h"
#include "lgc.h"
#include "lmem.h"
#include "lobject.h"
#include "lstate.h"
#include "lstring.h"
#include "ltable.h"
#include "ltm.h"
#include "lundump.h"
#include "lvm.h"

LUA_API const char *GetStr(TValue *val)
{
	return getstr(val);
}

LUA_API void* RawUValue(StkId val)
{
	return (rawuvalue(val) + 1);
}