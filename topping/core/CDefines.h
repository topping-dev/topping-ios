#ifndef CDEFINES_H
#define CDEFINES_H

#include "stdio.h"

FILE *GetResourceAssetSdF(const char *filename, const char *mode);
FILE *GetResourceSdAssetF(const char *filename, const char *mode);
FILE *GetResourceAssetF(const char *filename, const char *mode);
FILE *lua_ifopen(const char *filename, const char *mode);

#endif
