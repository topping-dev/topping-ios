#import "LGNavigationView.h"
#import "LuaFunction.h"
#import "LuaViewInflator.h"
#import "LGDrawerLayout.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>

@implementation LGNavigationView

+(LGNavigationView*)create:(LuaContext*)context {
    LGNavigationView *dl = [[LGNavigationView alloc] init];
    dl.lc = context;
    return dl;
}

-(void)setupComponent:(UIView *)view {
    [super setupComponent:view];
    if(self.app_headerLayout != nil) {
        LuaViewInflator *inflator = [[LuaViewInflator alloc] init];
        self.headerView = [inflator inflate:[LuaRef withValue:self.app_headerLayout] :self];
        [self addSubview:self.headerView];
        [self componentAddMethod:self._view :self.headerView._view];
    }
    if(self.app_menu != nil) {
        NSMutableArray *arr = [[LGMenuParser getInstance] getMenu:self.app_menu];
        self.subView = [LGRecyclerView create:self.lc];
        self.subView.android_layout_width = @"match_parent";
        self.subView.android_layout_height = @"wrap_content";
        
        [self addSubview:self.subView];
        
        self.adapter = [[LGRecyclerViewAdapter alloc] initWithContext:self.lc :@""];
        self.adapter.delegate = self;
        for(LuaMenu *menu in arr) {
            if(menu.children.count > 0) {
                [self.adapter addValue:menu];
                for(LuaMenu *childMenu in menu.children)
                    [self.adapter addValue:childMenu];
            }
            else
                [self.adapter addValue:menu];
        }
    }
}

-(void)onItemSelected:(LGView *)parent :(LGView *)cell :(int)position {
    if(self.ltNavigationItemSelectListener != nil) {
        LuaMenu *menu = (LuaMenu*)[self.adapter getValue:position];
        [self.ltNavigationItemSelectListener call:menu];
    }
}

-(void)configChange {
    [self.subView._view setFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
}

-(void)componentAddMethod:(UIView *)par :(UIView *)me {
    [self.subView setAdapter:self.adapter];
    [self.subView notify];
    if([self.parent isKindOfClass:[LGDrawerLayout class]]) {
        return;
    }
    [super componentAddMethod:par :me];
}

-(LGView *)onCreateViewHolder:(LGView *)parent :(int)type :(LuaContext *)context {
    NSString *defaultLayout = @"";
    if(type == 0) {
        defaultLayout = @""
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        "<LinearLayout"
        "   xmlns:android=\"http://schemas.android.com/apk/res/android\""
        "   android:layout_width=\"match_parent\""
        "   android:layout_height=\"wrap_content\""
        "   android:orientation=\"horizontal\""
        "   android:padding=\"8dp\""
        "   android:gravity=\"center_vertical\""
        "   android:layout_margin=\"4dp\">"
        "   <ImageView"
        "       android:id=\"@+id/iv_icon\""
        "       android:layout_width=\"12dp\""
        "       android:layout_height=\"12dp\"/>"
        "   <TextView"
        "       android:id=\"@+id/tv_title\""
        "       android:layout_width=\"wrap_content\""
        "       android:layout_height=\"wrap_content\""
        "       android:layout_marginStart=\"10dp\"/>"
        "</LinearLayout>";
    }
    else {
        defaultLayout = @""
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        "<LinearLayout "
        "    xmlns:android=\"http://schemas.android.com/apk/res/android\""
        "    android:layout_width=\"match_parent\""
        "    android:layout_height=\"wrap_content\""
        "    android:orientation=\"vertical\">"
        "    <View"
        "        android:id=\"@+id/v_view\""
        "        android:layout_width=\"match_parent\""
        "        android:layout_height=\"2dp\""
        "        android:background=\"#DDDDDD\"/>"
        "    <TextView"
        "        android:id=\"@+id/tv_title\""
        "        android:layout_width=\"wrap_content\""
        "        android:layout_height=\"wrap_content\""
        "        android:layout_marginStart=\"4dp\"/>"
        "</LinearLayout>";
    }
    
    LGView *lgview = nil;
    [[LGLayoutParser getInstance] parseData:[defaultLayout dataUsingEncoding:NSUTF8StringEncoding] :parent._view :parent :self.lc.form :&lgview];
    return lgview;
}

-(void)onBindViewHolder:(LGView *)cell :(int)position {
    LuaMenu *menu = (LuaMenu*)[self.adapter getValue:position];
    if(menu.children.count > 0) {
        LGTextView *tvTitle = (LGTextView*)[cell getViewById:[LuaRef withValue:@"tv_title"]];
        if(menu.title_ != nil)
        {
            [tvTitle setTextInternal:menu.title_];
            [tvTitle setVisibility:VISIBLE];
        }
        else {
            [tvTitle setVisibility:GONE];
        }
    } else {
        LGImageView *ivImage = (LGImageView*)[cell getViewById:[LuaRef withValue:@"iv_icon"]];
        [ivImage setImageRef:menu.iconRes];
        LGTextView *tvTitle = (LGTextView*)[cell getViewById:[LuaRef withValue:@"tv_title"]];
        [tvTitle setTextInternal:menu.title_];
        UICollectionViewCell *cell = [self.adapter getCellForIndex:position];
        if(menu.parent.checkableBehavior == CheckableBehaviorSingle
           || menu.parent.checkableBehavior == CheckableBehaviorAll) {
            ((UICollectionView*)self.subView._view).allowsSelection = true;
            UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
            selectedView.backgroundColor = (UIColor*)[[LGStyleParser getInstance] getStyleValue:[sToppingEngine getAppStyle] :@"colorPrimary"];
            cell.selectedBackgroundView = selectedView;
        }
    }
    [cell resizeAndInvalidate];
}

-(int)getItemViewType:(int)position {
    LuaMenu *menu = (LuaMenu*)[self.adapter getValue:position];
    if(menu.children.count > 0) {
        return 1;
    }
    return 0;
}

-(void)setNavigationItemSelectListener:(LuaTranslator*)lt {
    self.ltNavigationItemSelectListener = lt;
}

-(void)notify {
    [self.subView notify];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGNavigationView className];
}

+ (NSString*)className
{
    return @"LGNavigationView";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    ClassMethod(create:, LGNavigationView, @[[LuaContext class]], @"create", [LGNavigationView class])
    InstanceMethodNoRet(setNavigationItemSelectListener:, @[[LuaTranslator class]], @"setNavigationItemSelectListener")
    
    return dict;
}

@end
