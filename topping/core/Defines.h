//#import "KeyboardHelper.h"
#import "Log.h"
#import "ToppingEngine.h"

#define SET_SEPERATOR_COLOR(V) [V setSeparatorColor:[UIColor darkGrayColor]]

//#define SUPPORT_LOW_RES_KURAN
//#define DEFINE_SUB_CATEGORIES

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad
#define IS_IPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define IS_GREATER_THAN_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )

#ifndef CLAMP
#define CLAMP(min,x,max) (x < min ? min : (x > max ? max : x))
#endif

#define APPEND(S, A) [S stringByAppendingString:A]
#define SAPPEND(S, A) S = [S stringByAppendingString:A]
#define REPLACE(S, A, B) [S stringByReplacingOccurrencesOfString:A withString:B]
#define SREPLACE(S, A, B) S = [S stringByReplacingOccurrencesOfString:A withString:B]
#define CONVERTFLOAT(S) REPLACE(S, @".", @",")
#define SCONVERTFLOAT(S) SREPLACE(S, @".", @",")
#define SPLIT(S, V) [S componentsSeparatedByString:V]
#define CONTAINS(S, V) (S != nil && [S rangeOfString:V].location != NSNotFound)
#define TO_LOWER(S) [S lowercaseString]
#define TO_HIGHER(S) [S capitalizedString]
#define ISEMPTY(S) (S != nil && [S compare:@""] == 0)
#define ISNULLOREMPTY(S) (S == nil || [S compare:@""] == 0)
#define COMPARE(S, T) (S != nil && [S compare:T] == 0)
#define SUBSTRING(S, ST, ED) [S substringWithRange:NSMakeRange(ST, (ED - ST))]
#define SUBSTRING_L(S, ST, ED) [S substringWithRange:NSMakeRange(ST, ED)]
#define STARTS_WITH(S, T) [S hasPrefix:T]
#define ENDS_WITH(S, T) [S hasSuffix:T]

#define ITOS(P) [NSString stringWithFormat:@"%d", P]
#define LTOS(P) [NSString stringWithFormat:@"%ld", P]
#define LLTOS(P) [NSString stringWithFormat:@"%lld", P]
#define ULTOS(P) [NSString stringWithFormat:@"%lu", P]
#define FTOS(P) [NSString stringWithFormat:@"%f", P]
#define DTOS(P) [NSString stringWithFormat:@"%lf", P]
#define BTOS(P) P ? @"1" : @"0"
#define BTOI(P) P ? 1 : 0

#define STOL(P) [P longLongValue]
#define STOI(P) [P intValue]
#define STOB(P) [P intValue] == 1 ? true : false
#define SSTOB(P) [P isEqualToString:@"true"]
#define STOF(P) [P floatValue]
#define STOD(P) [P doubleValue]

#define ITOB(P) P == 1 ? true : false

#define IS_IOS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IOS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IS_IOS_10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IS_IOS_11_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)

#define APP_DELEGATE() ((QosheAppDelegate*)[[UIApplication sharedApplication] delegate])

#define TO_JSON(OBJ, TO) \
{ \
NSData *jsonData = [NSJSONSerialization dataWithJSONObject:OBJ options:0 error:nil]; \
TO = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]; \
}

#define FROM_JSON_DICT(STR, TO) \
{ \
NSData *objectData = [STR dataUsingEncoding:NSUTF8StringEncoding]; \
TO = [NSJSONSerialization JSONObjectWithData:objectData \
options:NSJSONReadingMutableContainers \
error:nil]; \
}

#define FROM_JSON(STR, CLAZZ, TO) \
{ \
NSData *objectData = [STR dataUsingEncoding:NSUTF8StringEncoding]; \
NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData \
                                                     options:NSJSONReadingMutableContainers \
                                                       error:nil]; \
TO = [[CLAZZ alloc] initWithDictionary:json]; \
}

static NSString* GETINVARIANTSTRING(NSString* str);
static NSString* GETINVARIANTSTRING(NSString* str)
{
    NSMutableString *strRet = [NSMutableString string];
	unichar c;
	for(int i = 0; i < [str length]; i++)
	{
		c = [str characterAtIndex:i];
		switch (c) 
		{
			case 0xE2:
			case 0xC2:
				c = 'a';
				break;
				
			case 0x131:
			case 'I':
			case 0x130:
			case 0xEE:
			case 0xCE:
				c = 'i';
				break;
				
			case 0x11F:
			case 0x11E:
				c = 'g';
				break;
				
			case 0x15F:
			case 0x15E:
				c = 's';
				break;
				
			case 0xFC:
			case 0xDC:
			case 0xFB:
			case 0xDB:
				c = 'u';
				break;
				
			case 0xE7:
			case 0xC7:
				c = 'c';
				break;
				
			case 0xF6:
			case 0xD6:
			case 0xF4:
			case 0xD4:
				c = 'o';
				break;
		}
		
		[strRet appendString:[NSString stringWithCharacters:&c length:1]];
	}
	
	return [NSString stringWithString:strRet];
}

static NSString* FUAPPEND(NSString *str, NSString* what,...);
static NSString* FUAPPEND(NSString *str, NSString* what,...)
{
	va_list p;
	va_start(p, what);
	NSString* who;
	NSString *retVal = [str copy];
	SAPPEND(retVal, what);
	while((who = va_arg(p,NSString*)) != NULL)
		SAPPEND(retVal, who);
	
	va_end(p);
	return retVal;
}

static NSData* GetResourceAssetSd(NSString *path, NSString *name, NSString **url);
static NSData* GetResourceAssetSd(NSString *path, NSString *name, NSString **url)
{
	NSArray *arr = SPLIT(name, @".");
	if([arr count] < 2)
		return nil;
	NSString* resourcePath = [[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]];
	if(url != nil)
		*url = [resourcePath copy];
	if(resourcePath != nil)
		return [NSData dataWithContentsOfFile:resourcePath];
	else 
	{
		NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
		NSString *resourcePathDirectory = [basePath stringByAppendingPathComponent:path];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:resourcePathDirectory])
			[fileManager createDirectoryAtPath:resourcePathDirectory withIntermediateDirectories:YES attributes:nil error:nil];
		NSString *resourceFile = [resourcePathDirectory stringByAppendingPathComponent:name];
		if(url != nil)
			*url = [resourceFile copy];
		if([fileManager fileExistsAtPath:resourceFile])
			return [NSData dataWithContentsOfFile:resourceFile];
	}
	
	return nil;
}

static NSData* GetResourceSdAsset(NSString *path, NSString *name, NSString **url);
static NSData* GetResourceSdAsset(NSString *path, NSString *name, NSString **url)
{
	NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
	NSString *resourcePathDirectory = [basePath stringByAppendingPathComponent:path];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:resourcePathDirectory])
		[fileManager createDirectoryAtPath:resourcePathDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	NSString *resourceFile = [resourcePathDirectory stringByAppendingPathComponent:name];
	if(url != nil)
		*url = [resourceFile copy];
	if([fileManager fileExistsAtPath:resourceFile])
		return [NSData dataWithContentsOfFile:resourceFile];
	else
	{
		NSArray *arr = SPLIT(name, @".");
		if([arr count] < 2)
			return nil;
        NSBundle *bund = [NSBundle mainBundle];
        NSString *bundlePath = [bund bundlePath];
        NSString *internalPath = SUBSTRING(path, bundlePath.length, path.length);
		NSString* resourcePath = [[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1] inDirectory:internalPath];
		if(url != nil)
			*url = [resourcePath copy];
		if(resourcePath != nil)
			return [NSData dataWithContentsOfFile:resourcePath];
	}
	
	return nil;
}

static NSData* GetResourceAsset(NSString *path, NSString *name, NSString **url);
static NSData* GetResourceAsset(NSString *path, NSString *name, NSString **url)
{
	NSArray *arr = SPLIT(name, @".");
	if([arr count] < 2)
		return nil;
    NSBundle *bund = [NSBundle mainBundle];
    NSString *bundlePath = [bund bundlePath];
    NSString *internalPath = SUBSTRING(path, bundlePath.length, path.length);
	NSString* resourcePath = [[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1] inDirectory:internalPath];
	if(url != nil)
		*url = [resourcePath copy];
	if(resourcePath != nil)
		return [NSData dataWithContentsOfFile:resourcePath];
	
	return nil;
}

static NSData* GetResourceSd(NSString *path, NSString *name, NSString **url);
static NSData* GetResourceSd(NSString *path, NSString *name, NSString **url)
{
	NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
	NSString *resourcePathDirectory = [basePath stringByAppendingPathComponent:path];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:resourcePathDirectory])
		[fileManager createDirectoryAtPath:resourcePathDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	NSString *resourceFile = [resourcePathDirectory stringByAppendingPathComponent:name];
	if(url != nil)
		*url = [resourceFile copy];
	if([fileManager fileExistsAtPath:resourceFile])
		return [NSData dataWithContentsOfFile:resourceFile];
	
	return nil;
}

static NSData* GetResource(NSString *path, NSString *name, NSString **url);
static NSData* GetResource(NSString *path, NSString *name, NSString **url)
{
	int primaryLoad = [sToppingEngine GetPrimaryLoad];
	switch (primaryLoad)
	{
		case INTERNAL_DATA:
		case EXTERNAL_DATA:
		{
			return GetResourceSdAsset(path, name, url);
		}
		case RESOURCE_DATA:
		default:
		{
			return GetResourceAsset(path, name, url);
		}
	}
}

static bool IsIPad();
static bool IsIPad()
{
#ifdef UI_USER_INTERFACE_IDIOM
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif
	return NO;
};

static bool HasRetinaDisplay();
static bool HasRetinaDisplay()
{
	if([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
		return YES;
	return NO;
}

enum DOWNLOAD_TYPE
{
	RAW,
	ZIP
};

static double DegreeToRadianMod(double angle, bool mod);
static double DegreeToRadianMod(double angle, bool mod)
{
	if(mod)
	{
		while(angle < 0)
			angle += 360;
	}
	return M_PI * angle / 180.0; 
}

static double RadianToDegreeMod(double radian, bool mod);
static double RadianToDegreeMod(double radian, bool mod)
{
	if(mod)
	{
		while(radian < 0)
			radian += (2*M_PI);
	}
	return 180.0 * radian / M_PI;
}

static double DegreeToRadian(double angle);
static double DegreeToRadian(double angle)
{
	return DegreeToRadianMod(angle, true);
}

static double RadianToDegree(double radian);
static double RadianToDegree(double radian)
{
	return RadianToDegreeMod(radian, true);
}

static UIImage* ImageWithColor(UIColor *color);
static UIImage* ImageWithColor(UIColor *color)
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static NSArray* recursivePathsForResourceOfType(NSString *type, NSString *directoryPath);
static NSArray* recursivePathsForResourceOfType(NSString *type, NSString *directoryPath)
{
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    
    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    
    NSString *filePath;
    
    while ((filePath = [enumerator nextObject]) != nil){
        
        // If we have the right type of file, add it to the list
        // Make sure to prepend the directory path
        if([[filePath pathExtension] isEqualToString:type]){
            [filePaths addObject:[directoryPath stringByAppendingPathComponent:filePath]];
        }
    }
    
    return filePaths;
}

#define DEFINE_VALIDATE_EMAIL(V, S) \
{ \
NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";  \
NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; \
\
V = [emailTest evaluateWithObject:S]; \
}

#define LOCAL_CATEGORIES

#define DEFINE_MAIN_DELEGATE_SELECTOR(S, A) \
if(IS_IPHONE) \
{ \
AppDelegate_iPhone *adp = ((AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate]); \
[adp S A]; \
} \
else \
{ \
AppDelegate_iPad *adp = ((AppDelegate_iPad*)[[UIApplication sharedApplication] delegate]); \
[adp S A]; \
}

#define DEFINE_MAIN_DELEGATE_SELECTOR_NOARG(S) \
if(IS_IPHONE) \
{ \
AppDelegate_iPhone *adp = ((AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate]); \
[adp S]; \
} \
else \
{ \
AppDelegate_iPad *adp = ((AppDelegate_iPad*)[[UIApplication sharedApplication] delegate]); \
[adp S]; \
}

#define ADDCOMBODATA(A, S, I) \
{ \
Data *a = [[[Data alloc] init] autorelease]; \
a.name = @S; \
a.tag = [NSNumber numberWithInt:I]; \
[A addObject:a]; \
}

#define HANDLEERROR(I, S) \
NSString *errorString = @""; \
switch (I) { \
case 1: \
errorString = @"Parolalar eşleşmiyor."; \
break; \
case 2: \
errorString = @"Veri hatası."; \
break; \
case 3: \
errorString = @"Sunucu hatası."; \
break; \
case 4: \
errorString = @"Bu e-posta adresi kullanımdadır."; \
break; \
case 5: \
errorString = @"Lütfen resim dosyası ekleyin."; \
break; \
case 6: \
errorString = @"E-posta veya parola hatalı."; \
break; \
case 7: \
errorString = @"Üyelik için yaş sınırı 12'dir."; \
break; \
case 8: \
errorString = @"Geçersiz istek."; \
break; \
case 9: \
errorString = @"Bu işlemi gerçekleştirme yetkiniz yok."; \
break; \
case 10: \
errorString = @"Aradığınız kriterlere uygun kayıt bulunamadı."; \
break; \
case 11: \
errorString = @"Hatalı giriş."; \
break; \
case 12: \
errorString = @"Parola en az 6 haneli olmalıdır."; \
break; \
case 13: \
errorString = @"Girmiş olduğunuz parola mevcut parolanızla eşleşmiyor."; \
break; \
case 14: \
errorString = @"Bu kişi zaten arkadaş listenizde bulunuyor."; \
break; \
case 15: \
errorString = @"Facebook uygulamasına gerekli yetkiler verilmemiş."; \
break; \
case 16: \
errorString = S; \
break; \
case 17: \
errorString = @"Bir fırsatı sadece bir defa paylaşabilirsiniz."; \
break; \
case 18: \
errorString = @"Kendinizi arkadaş olarak ekleyemezsiniz."; \
break; \
case 19: \
errorString = @"Sistemde kayıtlı böyle bir kullanıcı bulunamadı."; \
break; \
case 20: \
errorString = @"Sistemde kayıtlı böyle bir mekan bulunamadı."; \
break; \
case 21: \
errorString = @"Üyeliğiniz henüz etkinleştirilmemiş. Lütfen e-postanıza gönderilmiş olan bağlantıyı kullanarak üyeliğinizi tamamlayın."; \
break; \
case 22: \
errorString = @"Geçersiz bir e-posta adresi girdiniz."; \
break; \
case 47: \
errorString = @"Bu işlemi gerçekleştirebilmek için giriş yapmanız gerekiyor."; \
break; \
default: \
errorString = @"Uygulama hatası."; \
break; \
} \
UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorString \
message:nil \
delegate:nil \
cancelButtonTitle:@"Tamam" \
otherButtonTitles:nil]; \
[alertView autorelease]; \
[alertView show];

//Error and point
#define HANDLE_GENERAL_ERROR(dict) \
int errorG = [[dict objectForKey:@"error"] intValue]; \
NSString *errG = [dict objectForKey:@"err"]; \
if(errorG != 0) \
{ \
HIDE_INDICATOR \
HANDLEERROR(errorG, errG); \
return; \
}

#define HANDLE_GENERAL_ERROR_NO_INDICATOR(dict) \
int errorG = [[dict objectForKey:@"error"] intValue]; \
NSString *errG = [dict objectForKey:@"err"]; \
if(errorG != 0) \
{ \
HANDLEERROR(errorG, errG); \
return; \
}

#define HANDLE_ERROR_AND_POINTS(result) \
int error = [[result objectForKey:@"error"] intValue]; \
NSString *err = [result objectForKey:@"err"]; \
int p = [[result objectForKey:@"p"] intValue]; \
int dp = [[result objectForKey:@"dp"] intValue]; \
p = 0; \
if(error != 0) \
{ \
HIDE_INDICATOR \
HANDLEERROR(error, err); \
return; \
} \
else if(p != 0) \
{ \
if(dp == 0) \
{ \
CustomAlertView *av = [[[CustomAlertView alloc] \
initWithImage:[UIImage imageNamed:@"pointball.png"] \
text:@"15" \
backgroundMaskImage:[UIImage imageNamed:@"behind_alert_view.png"] \
font:nil \
textColor:nil \
offsetX:0 \
offsetY:-5.0f] autorelease]; \
[av show]; \
float val = ([LoginInfo GetInstance].points * 100) / [LoginInfo GetInstance].perc; \
[[LoginInfo GetInstance] setPoints:[LoginInfo GetInstance].points + p]; \
[[LoginInfo GetInstance] setPerc:(([LoginInfo GetInstance].points * 100) / val)]; \
[[[[UIToast makeText:NSLocalizedString(@"Puan Kazandınız", @"")] setGravity:UIToastGravityTop] setDuration:UIToastDurationNormal] show]; \
DEFINE_UPDATE_POINTS \
} \
else \
{ \
CustomAlertView *av = [[[CustomAlertView alloc] \
initWithImage:[UIImage imageNamed:@"pointball.png"] \
text:@"15" \
backgroundMaskImage:[UIImage imageNamed:@"behind_alert_view.png"] \
font:nil \
textColor:nil \
offsetX:0 \
offsetY:-5.0f] autorelease]; \
[av show]; \
[[[[UIToast makeText:NSLocalizedString(@"Üye olan her arkadaşınız için aşağıdaki puanı kazanacaksınız.", @"")] setGravity:UIToastGravityTop] setDuration:5000] show]; \
} \
} \

#define HANDLE_ERROR_AND_POINTS_NO_INDICATOR(result) \
int error = [[result objectForKey:@"error"] intValue]; \
NSString *err = [result objectForKey:@"err"]; \
int p = [[result objectForKey:@"p"] intValue]; \
int dp = [[result objectForKey:@"dp"] intValue]; \
p = 0; \
if(error != 0) \
{ \
HANDLEERROR(error, err); \
return; \
} \
else if(p != 0) \
{ \
if(dp == 0) \
{ \
CustomAlertView *av = [[[CustomAlertView alloc] \
initWithImage:[UIImage imageNamed:@"pointball.png"] \
text:@"15" \
backgroundMaskImage:[UIImage imageNamed:@"behind_alert_view.png"] \
font:nil \
textColor:nil \
offsetX:0 \
offsetY:-5.0f] autorelease]; \
[av show]; \
float val = ([LoginInfo GetInstance].points * 100) / [LoginInfo GetInstance].perc; \
[[LoginInfo GetInstance] setPoints:[LoginInfo GetInstance].points + p]; \
[[LoginInfo GetInstance] setPerc:(([LoginInfo GetInstance].points * 100) / val)]; \
[[[[UIToast makeText:NSLocalizedString(@"Puan Kazandınız", @"")] setGravity:UIToastGravityTop] setDuration:UIToastDurationNormal] show]; \
DEFINE_UPDATE_POINTS \
} \
else \
{ \
CustomAlertView *av = [[[CustomAlertView alloc] \
initWithImage:[UIImage imageNamed:@"pointball.png"] \
text:@"15" \
backgroundMaskImage:[UIImage imageNamed:@"behind_alert_view.png"] \
font:nil \
textColor:nil \
offsetX:0 \
offsetY:-5.0f] autorelease]; \
[av show]; \
[[[[UIToast makeText:NSLocalizedString(@"Üye olan her arkadaşınız için aşağıdaki puanı kazanacaksınız.", @"")] setGravity:UIToastGravityTop] setDuration:5000] show]; \
} \
}

//ComboBox
#define COMBOMASK(S) ((UIActivityIndicatorView *)S.leftView)

//Indicator
#define SHOW_INDICATOR \
if(IS_IPHONE) \
{ \
AppDelegate_iPhone *adp = ((AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate]); \
[adp.window bringSubviewToFront:adp.uiAav]; \
[adp.uiAav startAnimating]; \
[adp.window bringSubviewToFront:adp.uiAlertText]; \
[adp.uiAlertText setHidden:NO]; \
adp.indicatorCount++; \
if(adp.indicatorTimer != nil) \
{ \
[adp.indicatorTimer invalidate]; \
adp.indicatorTimer = nil; \
} \
\
adp.indicatorTimer = [NSTimer timerWithTimeInterval:30 target:adp selector:adp.indicatorSelector userInfo:nil repeats:NO]; \
[[NSRunLoop currentRunLoop] addTimer:adp.indicatorTimer forMode:NSDefaultRunLoopMode]; \
} \
else \
{ \
AppDelegate_iPad *adp = ((AppDelegate_iPad*)[[UIApplication sharedApplication] delegate]); \
[adp.window bringSubviewToFront:adp.uiAav]; \
[adp.uiAav startAnimating]; \
[adp.window bringSubviewToFront:adp.uiAlertText]; \
[adp.uiAlertText setHidden:NO]; \
adp.indicatorCount++; \
if(adp.indicatorTimer != nil) \
{ \
[adp.indicatorTimer invalidate]; \
adp.indicatorTimer = nil; \
} \
\
adp.indicatorTimer = [NSTimer timerWithTimeInterval:30 target:adp selector:adp.indicatorSelector userInfo:nil repeats:NO]; \
[[NSRunLoop currentRunLoop] addTimer:adp.indicatorTimer forMode:NSDefaultRunLoopMode]; \
}

#define HIDE_INDICATOR \
if(IS_IPHONE) \
{ \
AppDelegate_iPhone *adp = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate]; \
adp.indicatorCount--; \
if(adp.indicatorCount <= 0 && [adp.uiAav isAnimating]) \
{ \
adp.indicatorCount = 0; \
[adp.uiAav stopAnimating]; \
[adp.uiAlertText setHidden:YES]; \
if(adp.indicatorTimer != nil) \
{ \
[adp.indicatorTimer invalidate]; \
adp.indicatorTimer = nil; \
} \
} \
} \
else \
{ \
AppDelegate_iPad *adp = (AppDelegate_iPad *)[[UIApplication sharedApplication] delegate]; \
adp.indicatorCount--; \
if(adp.indicatorCount <= 0 && [adp.uiAav isAnimating]) \
{ \
adp.indicatorCount = 0; \
[adp.uiAav stopAnimating]; \
[adp.uiAlertText setHidden:YES]; \
if(adp.indicatorTimer != nil) \
{ \
[adp.indicatorTimer invalidate]; \
adp.indicatorTimer = nil; \
} \
} \
} \

//make view ready
#define LOGO @"logo38.png"

#define DEFINE_SET_BACKGROUND_PATTERN(PAT) self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:PAT]]

#define DEFINE_VIEW_WITH_LOGO_WITHOUT_BUTTON(V, L) \
V.uiNavigationController = uiNavigationController; \
UIImage *image = [UIImage imageNamed:L]; \
UIImageView *imageView = [[UIImageView alloc] initWithImage:image];	\
V.navigationItem.titleView = imageView; 

#define DEFINE_VIEW_WITH_LOGO(V, L, SEARCH, ADD) \
V.uiNavigationController = uiNavigationController; \
UIImage *image = [UIImage imageNamed:L]; \
UIImageView *imageView = [[UIImageView alloc] initWithImage:image]; \
V.navigationItem.titleView = imageView; \
UIBarButtonItem	*bbi = [[UIBarButtonItem alloc] init]; \
NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"UIBarButtonRightView" owner:self options:nil]; \
UIView *view = [arr objectAtIndex:0]; \
UIButton *but = (UIButton *) [view viewWithTag:1]; \
UIButton *searchButton = (UIButton*)[view viewWithTag:2]; \
if(SEARCH) \
[searchButton addTarget:self action:@selector(SearchButtonClicked) forControlEvents:UIControlEventTouchUpInside]; \
else \
searchButton.hidden = YES; \
if(ADD) \
[but addTarget:self action:@selector(AddDealButtonClicked) forControlEvents:UIControlEventTouchUpInside]; \
else \
but.hidden = YES; \
[bbi setCustomView:view]; \
V.navigationItem.rightBarButtonItem = bbi; \

#define DEFINE_SELF_WITH_LOGO(L, SEARCH, ADD) \
UIImage *image = [UIImage imageNamed:LOGO]; \
UIImageView *imageView = [[UIImageView alloc] initWithImage:image];	\
self.navigationItem.titleView = imageView; \
UIBarButtonItem	*bbi = [[UIBarButtonItem alloc] init]; \
NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"UIBarButtonRightView" owner:self options:nil]; \
UIView *view = [arr objectAtIndex:0]; \
UIButton *but = (UIButton *) [view viewWithTag:1]; \
UIButton *searchButton = (UIButton*)[view viewWithTag:2]; \
if(SEARCH) \
[searchButton addTarget:self action:@selector(SearchButtonClicked) forControlEvents:UIControlEventTouchUpInside]; \
else \
searchButton.hidden = YES; \
if(ADD) \
[but addTarget:self action:@selector(AddDealButtonClicked) forControlEvents:UIControlEventTouchUpInside]; \
else \
but.hidden = YES; \
[bbi setCustomView:view]; \
self.navigationItem.rightBarButtonItem = bbi; \


#define DEFINE_ONLY_LOGO(V, L) \
UIImage *image = [UIImage imageNamed:L]; \
UIImageView *imageView = [[UIImageView alloc] initWithImage:image];	\
V.navigationItem.titleView = imageView;

#define DEFINE_UPDATE_POINTS \
/*UIButton *pointButton = (UIButton*)[self.navigationItem.rightBarButtonItem.customView viewWithTag:1]; \
NSString *pointTitle = ITOS([LoginInfo GetInstance].points); \
[pointButton setTitle:pointTitle forState:UIControlStateNormal]; \
[pointButton setTitle:pointTitle forState:UIControlStateSelected]; \
UIProgressView *progress = (UIProgressView*) [self.navigationItem.rightBarButtonItem.customView viewWithTag:2]; \
[progress setProgress:([LoginInfo GetInstance].perc / 100.0f)];*/

#define DEFINE_CHECK_LOGIN(HIDE) \
if(![[LoginInfo GetInstance] CheckLoginSync]) \
{ \
if(self.uiLoginController == nil) \
{ \
LoginViewController *registerController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil]; \
self.uiLoginController = registerController; \
self.uiLoginController.uiNavigationController = uiNavigationController; \
self.uiLoginController.hide = HIDE; \
[registerController release]; \
} \
\
[uiNavigationController pushViewController:uiLoginController animated:YES]; \
return; \
}

//Database
#define DEFINE_DB_GET_CONNECTION(CONN) \
DatabaseHelper *db = [[DatabaseHelper alloc] init]; \
[db CheckAndCreateDatabase]; \
CONN = [db Open];

#define DEFINE_DB_RELEASE_CONNECTION(CONN) \
[db Close:CONN]; \
[db release];

//Preferences Part
#define DEFINE_UPDATE_PREFERENCE(NAME, VALUE) \
{ \
DatabaseHelper *db = [[DatabaseHelper alloc] init]; \
[db CheckAndCreateDatabase]; \
sqlite3* conn = [db Open]; \
NSString *queryDelete = APPEND(@"DELETE FROM PREFERENCES WHERE NAME = '", APPEND(NAME, @"'")); \
sqlite3_stmt *stmt = [db Query:conn :[queryDelete cStringUsingEncoding:NSUTF8StringEncoding]]; \
[db Step:stmt]; \
[db Finalize:stmt]; \
NSString *queryInsert = APPEND(@"INSERT INTO PREFERENCES VALUES('", APPEND(NAME, APPEND(@"', '", APPEND(VALUE, @"')")))); \
stmt = [db Query:conn :[queryInsert cStringUsingEncoding:NSUTF8StringEncoding]]; \
[db Step:stmt]; \
[db Finalize:stmt]; \
[db Close:conn]; \
[db release]; \
}

#define DEFINE_UPDATE_PREFERENCE_CONN(CONN, NAME, VALUE) \
{ \
NSString *queryDelete = APPEND(@"DELETE FROM PREFERENCES WHERE NAME = '", APPEND(NAME, @"'")); \
sqlite3_stmt *stmt = [db Query:CONN :[queryDelete cStringUsingEncoding:NSUTF8StringEncoding]]; \
[db Step:stmt]; \
[db Finalize:stmt]; \
NSString *queryInsert = APPEND(@"INSERT INTO PREFERENCES VALUES('", APPEND(NAME, APPEND(@"', '", APPEND(VALUE, @"')")))); \
stmt = [db Query:CONN :[queryInsert cStringUsingEncoding:NSUTF8StringEncoding]]; \
[db Step:stmt]; \
[db Finalize:stmt]; \
}

#define DEFINE_GET_PREFERENCE(V, NAME, DEFVAL) \
{ \
DatabaseHelper *db = [[DatabaseHelper alloc] init]; \
[db CheckAndCreateDatabase]; \
sqlite3* conn = [db Open]; \
NSString *queryDelete = APPEND(@"SELECT * FROM PREFERENCES WHERE NAME = '", APPEND(NAME, @"'")); \
sqlite3_stmt *stmt = [db Query:conn :[queryDelete cStringUsingEncoding:NSUTF8StringEncoding]]; \
BOOL error = NO; \
if([db Read:stmt]) \
V = [db GetString:stmt :1]; \
else \
error = YES; \
[db Finalize:stmt]; \
if(error) \
{ \
[db Query:conn :[FUAPPEND(@"INSERT INTO PREFERENCES VALUES('", NAME, @"', '", DEFVAL, @"')", NULL) cStringUsingEncoding:NSUTF8StringEncoding]]; \
[db Step:stmt]; \
[db Finalize:stmt]; \
V = DEFVAL; \
} \
[db Close:conn]; \
[db release]; \
}

#define DEFINE_GET_PREFERENCE_CONN(CONN, V, NAME, DEFVAL) \
{ \
NSString *queryDelete = APPEND(@"SELECT * FROM PREFERENCES WHERE NAME = '", APPEND(NAME, @"'")); \
sqlite3_stmt *stmt = [db Query:CONN :[queryDelete cStringUsingEncoding:NSUTF8StringEncoding]]; \
BOOL error = NO; \
if([db Read:stmt]) \
V = [db GetString:stmt :1]; \
else \
error = YES; \
[db Finalize:stmt]; \
if(error) \
{ \
[db Query:CONN :[FUAPPEND(@"INSERT INTO PREFERENCES VALUES('", NAME, @"', '", DEFVAL, @"')", NULL) cStringUsingEncoding:NSUTF8StringEncoding]]; \
[db Step:stmt]; \
[db Finalize:stmt]; \
V = DEFVAL; \
} \
}

//Arabic part
//#define DEFINE_ARABIC_FONT @"Scheherazade-AAT"
//#define DEFINE_ARABIC_FONT @"Shaikh Hamdullah Basic"
#define DEFINE_ARABIC_FONT @"Lateef-AAT"

#define DEFINE_ARABIC_FONT_FOR_LABEL(L) L.font = [UIFont fontWithName:DEFINE_ARABIC_FONT size:L.font.pointSize];

#define DEFINE_ARABIC_GET_FONT(S) [UIFont fontWithName:DEFINE_ARABIC_FONT size:S]

#define DEFINE_ABOUT_TEXT @"Alangoya Bilgi Teknolojileri olarak genç ve dinamik bir ekiple çıktığımız bu yolda, sizlere en iyi ve en güvenilir hizmeti vermek amacıyla sağlam adımlarla yürüyoruz. Sürekli gelişen bilgi ve iletişim teknolojileri alanında değişimi yakalamayı ve imkanları müşteri ve iş ortaklarımız için fırsata çevirmeyi hedefliyoruz. Bu kapsamda öncelikle yazılım alanında en güncel teknolojiler kullanılarak geliştirilen kurumsal ve mobil uygulamalar olmak üzere, bilişim hizmetlerinizin devamlılığı ve güvenliği için sağladığımız danışmanlık hizmetleri ile de size işinizde destek oluyoruz. Bilgi teknolojilerine verdiğimiz önemi ve uzmanlığımızı sizinle paylaşmak ve birlikte hizmetlerimizi daha ileriye taşımak adına dünya lideri çözüm ortakları ile yaptığımız işbirliğini sürekli geliştirmekten ve bu gelişimi hizmet olarak sizlere sunmaktan mutluluk duyarız. www.alangoya.com"

#define LUA_COPY_STRING(S) [[NSString alloc] initWithString:S];

#define TOO(V) ((NSObject *)V)

#define TONS(S) [NSString stringWithCString:S encoding:NSUTF8StringEncoding]

#define ADDDICTTODICT(D, OD) \
{ \
NSDictionary *otherDict = OD; \
for(NSString *key in otherDict) \
{ \
	[D setObject:[otherDict objectForKey:key] forKey:key]; \
} \
} 
