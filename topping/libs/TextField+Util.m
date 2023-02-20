#import "TextField+Util.h"
#import "LGValueParser.h"
#import "LGColorParser.h"
#import "LGDimensionParser.h"
#import "LGFontParser.h"

@implementation UITextField (Util)

-(int)getFontDescriptor:(int) textStyle {
    int descriptor = 0;
    if(textStyle & FONT_STYLE_BOLD)
        descriptor |= UIFontDescriptorTraitBold;
    if(textStyle & FONT_STYLE_ITALIC)
        descriptor |= UIFontDescriptorTraitItalic;
    return descriptor;
}

-(void)setTextAppearance:(NSString *)style {
    NSDictionary* dictionary = (NSDictionary*)[[LGValueParser getInstance] getValue:style];
    
    NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
    if([dictionary objectForKey:@"android:textColorHighlight"] != nil) {
        //Not supported
    }
    if([dictionary objectForKey:@"android:textColor"] != nil) {
        UIColor *color = [[LGColorParser getInstance] parseColor:[dictionary objectForKey:@"android:textColor"]];
        [attributeDictionary setObject:color forKey:NSForegroundColorAttributeName];
    }
    if([dictionary objectForKey:@"android:textColorLink"] != nil) {
        //Not supported
    }
    if([dictionary objectForKey:@"android:typeFace"] != nil) {
        //Not supported
    }
    if([dictionary objectForKey:@"android:fontFamily"] != nil) {
        LGFontReturn *lfr = [[LGFontParser getInstance] getFont:[dictionary objectForKey:@"android:fontFamily"]];
        int textStyle = FONT_STYLE_NORMAL;
        if([dictionary objectForKey:@"android:textStyle"] != nil) {
            NSString *textStyleStr = [dictionary objectForKey:@"android:textStyle"];
            textStyle = [LGFontParser parseTextStyle:textStyleStr];
        }
        if(lfr != nil) {
            LGFontData *fontData = [lfr.fontMap objectForKey:
                                    [NSNumber numberWithInt:textStyle]];
            if(fontData != nil) {
                self.font = [UIFont fontWithName:fontData.fontName size:self.font.pointSize];
            }
        }
    } else if([dictionary objectForKey:@"android:textStyle"] != nil) {
        NSString *textStyleStr = [dictionary objectForKey:@"android:textStyle"];
        int textStyle = [LGFontParser parseTextStyle:textStyleStr];
        int descriptor = [self getFontDescriptor:textStyle];
        if(descriptor != 0) {
            self.font = [UIFont fontWithDescriptor:[[self.font fontDescriptor] fontDescriptorWithSymbolicTraits:descriptor] size:self.font.pointSize];
        }
        
    }
    if([dictionary objectForKey:@"android:fontWeight"] != nil) {
        //TODO:
    }
    if([dictionary objectForKey:@"android:textSize"] != nil) {
        self.font = [self.font fontWithSize:[[LGDimensionParser getInstance] getDimension:[dictionary objectForKey:@"android:textSize"]]];
    }
    
    //TODO:Add others?
    if(attributeDictionary.count > 0) {
        self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:attributeDictionary];
    }
}

-(void)setHintTextAppearance:(NSString *)style {
    NSDictionary* dictionary = (NSDictionary*)[[LGValueParser getInstance] getValue:style];
    
    NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
    if([dictionary objectForKey:@"android:textColorHint"] != nil) {
        UIColor *color = [[LGColorParser getInstance] parseColor:[dictionary objectForKey:@"android:textColorHint"]];
        [attributeDictionary setObject:color forKey:NSForegroundColorAttributeName];
    }
    
    if(attributeDictionary.count > 0) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:attributeDictionary];
    }
}

@end

@implementation UITextView (Util)

-(int)getTextStyle:(NSString *)text {
    NSArray *arr = [text componentsSeparatedByString:@"|"];
    int textStyle = FONT_STYLE_NORMAL;
    for(NSString *comp in arr) {
        NSString *trimmed = [comp stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        if([trimmed isEqualToString:@"bold"]) {
            textStyle |= FONT_STYLE_BOLD;
        } else if([trimmed isEqualToString:@"italic"]) {
            textStyle |= FONT_STYLE_ITALIC;
        }
    }
    return textStyle;
}

-(int)getFontDescriptor:(int) textStyle {
    int descriptor = 0;
    if(textStyle & FONT_STYLE_BOLD)
        descriptor |= UIFontDescriptorTraitBold;
    if(textStyle & FONT_STYLE_ITALIC)
        descriptor |= UIFontDescriptorTraitItalic;
    return descriptor;
}

-(void)setTextAppearance:(NSString *)style {
    NSDictionary* dictionary = (NSDictionary*)[[LGValueParser getInstance] getValue:style];
    
    NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
    if([dictionary objectForKey:@"android:textColorHighlight"] != nil) {
        //Not supported
    }
    if([dictionary objectForKey:@"android:textColor"] != nil) {
        UIColor *color = [[LGColorParser getInstance] parseColor:[dictionary objectForKey:@"android:textColor"]];
        [attributeDictionary setObject:color forKey:NSForegroundColorAttributeName];
    }
    if([dictionary objectForKey:@"android:textColorLink"] != nil) {
        //Not supported
    }
    if([dictionary objectForKey:@"android:typeFace"] != nil) {
        //Not supported
    }
    if([dictionary objectForKey:@"android:fontFamily"] != nil) {
        LGFontReturn *lfr = [[LGFontParser getInstance] getFont:[dictionary objectForKey:@"android:fontFamily"]];
        int textStyle = FONT_STYLE_NORMAL;
        if([dictionary objectForKey:@"android:textStyle"] != nil) {
            NSString *textStyleStr = [dictionary objectForKey:@"android:textStyle"];
            textStyle = [self getTextStyle:textStyleStr];
        }
        if(lfr != nil) {
            LGFontData *fontData = [lfr.fontMap objectForKey:
                                    [NSNumber numberWithInt:textStyle]];
            if(fontData != nil) {
                self.font = [UIFont fontWithName:fontData.fontName size:self.font.pointSize];
            }
        }
    } else if([dictionary objectForKey:@"android:textStyle"] != nil) {
        NSString *textStyleStr = [dictionary objectForKey:@"android:textStyle"];
        int textStyle = [self getTextStyle:textStyleStr];
        int descriptor = [self getFontDescriptor:textStyle];
        if(descriptor != 0) {
            self.font = [UIFont fontWithDescriptor:[[self.font fontDescriptor] fontDescriptorWithSymbolicTraits:descriptor] size:self.font.pointSize];
        }
        
    }
    if([dictionary objectForKey:@"android:fontWeight"] != nil) {
        //TODO:
    }
    if([dictionary objectForKey:@"android:textSize"] != nil) {
        self.font = [self.font fontWithSize:[[LGDimensionParser getInstance] getDimension:[dictionary objectForKey:@"android:textSize"]]];
    }
    
    //TODO:Add others?
    if(attributeDictionary.count > 0) {
        self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:attributeDictionary];
    }
}

@end

@implementation UILabel (Util)

-(int)getTextStyle:(NSString *)text {
    NSArray *arr = [text componentsSeparatedByString:@"|"];
    int textStyle = FONT_STYLE_NORMAL;
    for(NSString *comp in arr) {
        NSString *trimmed = [comp stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        if([trimmed isEqualToString:@"bold"]) {
            textStyle |= FONT_STYLE_BOLD;
        } else if([trimmed isEqualToString:@"italic"]) {
            textStyle |= FONT_STYLE_ITALIC;
        }
    }
    return textStyle;
}

-(int)getFontDescriptor:(int) textStyle {
    int descriptor = 0;
    if(textStyle & FONT_STYLE_BOLD)
        descriptor |= UIFontDescriptorTraitBold;
    if(textStyle & FONT_STYLE_ITALIC)
        descriptor |= UIFontDescriptorTraitItalic;
    return descriptor;
}

-(void)setTextAppearance:(NSString *)style {
    NSDictionary* dictionary = (NSDictionary*)[[LGValueParser getInstance] getValue:style];
    
    NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
    if([dictionary objectForKey:@"android:textColorHighlight"] != nil) {
        //Not supported
    }
    if([dictionary objectForKey:@"android:textColor"] != nil) {
        UIColor *color = [[LGColorParser getInstance] parseColor:[dictionary objectForKey:@"android:textColor"]];
        [attributeDictionary setObject:color forKey:NSForegroundColorAttributeName];
    }
    if([dictionary objectForKey:@"android:textColorLink"] != nil) {
        //Not supported
    }
    if([dictionary objectForKey:@"android:typeFace"] != nil) {
        //Not supported
    }
    if([dictionary objectForKey:@"android:fontFamily"] != nil) {
        LGFontReturn *lfr = [[LGFontParser getInstance] getFont:[dictionary objectForKey:@"android:fontFamily"]];
        int textStyle = FONT_STYLE_NORMAL;
        if([dictionary objectForKey:@"android:textStyle"] != nil) {
            NSString *textStyleStr = [dictionary objectForKey:@"android:textStyle"];
            textStyle = [self getTextStyle:textStyleStr];
        }
        if(lfr != nil) {
            LGFontData *fontData = [lfr.fontMap objectForKey:
                                    [NSNumber numberWithInt:textStyle]];
            if(fontData != nil) {
                self.font = [UIFont fontWithName:fontData.fontName size:self.font.pointSize];
            }
        }
    } else if([dictionary objectForKey:@"android:textStyle"] != nil) {
        NSString *textStyleStr = [dictionary objectForKey:@"android:textStyle"];
        int textStyle = [self getTextStyle:textStyleStr];
        int descriptor = [self getFontDescriptor:textStyle];
        if(descriptor != 0) {
            self.font = [UIFont fontWithDescriptor:[[self.font fontDescriptor] fontDescriptorWithSymbolicTraits:descriptor] size:self.font.pointSize];
        }
        
    }
    if([dictionary objectForKey:@"android:fontWeight"] != nil) {
        //TODO:
    }
    if([dictionary objectForKey:@"android:textSize"] != nil) {
        self.font = [self.font fontWithSize:[[LGDimensionParser getInstance] getDimension:[dictionary objectForKey:@"android:textSize"]]];
    }
    
    //TODO:Add others?
    if(attributeDictionary.count > 0) {
        self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:attributeDictionary];
    }
}

@end

