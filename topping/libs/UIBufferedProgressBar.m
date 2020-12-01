#import "UIBufferedProgressBar.h"


@implementation UIBufferedProgressBar

@synthesize fillOffsetX, fillOffsetTopY, fillOffsetBottomY, useCustom, backgroundImage, progressImage, secondaryProgressImage, indeterminate, indeterminateBehaviour, indeterminateDuration, progressValue, secondaryProgress, progressSecondValue, progressMax;

- (id) init
{
    self = [super initWithProgressViewStyle:UIProgressViewStyleDefault];
    if (self != nil)
    {
        fillOffsetX = 1;
        fillOffsetTopY = 1;
        fillOffsetBottomY = 3;
        useCustom = NO;
        progressValue = 0;
        progressSecondValue = 0;
        progressMax = 100;
        indeterminate = NO;
        indeterminateBehaviour = INDETERMINATE_BEHAVIOUR_CYCLE;
        indeterminateDuration = 100;
        indeterminateCounter = 0;
        indeterminateMoveRight = YES;
    }
    return self;
}

-(void)SetBackgroundImage:(NSString *)str
{
    CGSize backgroundStretchPoints = {4, 9}, fillStretchPoints = {3, 8};
    self.backgroundImage = [[UIImage imageNamed:str] stretchableImageWithLeftCapWidth:backgroundStretchPoints.width
                                                                                  topCapHeight:backgroundStretchPoints.height];
}

-(void)SetProgressImage:(NSString *)str
{
    CGSize backgroundStretchPoints = {4, 9}, fillStretchPoints = {3, 8};
    self.progressImage = [[UIImage imageNamed:str] stretchableImageWithLeftCapWidth:backgroundStretchPoints.width
                                                                       topCapHeight:backgroundStretchPoints.height];
}

-(void)SetSecondaryProgressImage:(NSString *)str
{
    CGSize backgroundStretchPoints = {4, 9}, fillStretchPoints = {3, 8};
    self.secondaryProgressImage = [[UIImage imageNamed:str] stretchableImageWithLeftCapWidth:backgroundStretchPoints.width
                                                                    topCapHeight:backgroundStretchPoints.height];
}

-(void) setIndeterminate:(BOOL)value
{
    indeterminate = YES;
    self.useCustom = YES;
}

-(void)setProgressValue:(int)value
{
    progressValue = value;
    self.progress = ((double)self.progressValue) / ((double)self.progressMax);
    if(self.progress > 1.0)
        self.progress = 1.0;
    else if(self.progress < 1.0)
        self.progress = 0;
}

-(void)setProgressSecondValue:(int)value
{
    progressSecondValue = value;
    self.secondaryProgress = ((double)self.progressSecondValue) / ((double)self.progressMax);
    if(self.secondaryProgress > 1.0)
        self.secondaryProgress = 1.0;
    else if(self.secondaryProgress < 1.0)
        self.secondaryProgress = 0;
}

-(void)setProgressMax:(int)value
{
    progressMax = value;
    self.progress = ((double)self.progressValue) / ((double)self.progressMax);
    if(self.progress > 1.0)
        self.progress = 1.0;
    else if(self.progress < 1.0)
        self.progress = 0;
}

- (void)drawRect:(CGRect)rect
{
    if(useCustom)
    {
        // Draw the background in the current rect
        [self.backgroundImage drawInRect:rect];
        
        // Compute the max width in pixels for the fill.  Max width being how
        // wide the fill should be at 100% progress.
        NSInteger maxWidth = rect.size.width - (2 * fillOffsetX);
        
        double time = [[NSDate date] timeIntervalSince1970];
        if(indeterminate && time > indeterminateCounter)
        {
            indeterminateCounter = time + indeterminateDuration;
            if(self.progress == 1.0)
            {
                if(indeterminateBehaviour == INDETERMINATE_BEHAVIOUR_CYCLE)
                    indeterminateMoveRight = NO;
                else
                    self.progress = 0;
            }
            if(self.progress == 0)
                indeterminateMoveRight = YES;
            if(indeterminateMoveRight)
                self.progressValue++;
            else
                self.progressValue--;
        }
        
        if(self.secondaryProgressImage != nil)
        {
            // Compute the width for the current progress value, 0.0 - 1.0 corresponding
            // to 0% and 100% respectively.
            NSInteger curWidth = floor(secondaryProgress * maxWidth);
            
            // Create the rectangle for our fill image accounting for the position offsets,
            // 1 in the X direction and 1, 3 on the top and bottom for the Y.
            CGRect fillRect = CGRectMake(rect.origin.x + fillOffsetX,
                                         rect.origin.y + fillOffsetTopY,
                                         curWidth,
                                         rect.size.height - fillOffsetBottomY);
            
            // Draw the fill
            [secondaryProgressImage drawInRect:fillRect];
        }
        
        // Compute the width for the current progress value, 0.0 - 1.0 corresponding
        // to 0% and 100% respectively.
        NSInteger curWidth = floor([self progress] * maxWidth);
        
        // Create the rectangle for our fill image accounting for the position offsets,
        // 1 in the X direction and 1, 3 on the top and bottom for the Y.
        CGRect fillRect = CGRectMake(rect.origin.x + fillOffsetX,
                                     rect.origin.y + fillOffsetTopY,
                                     curWidth,
                                     rect.size.height - fillOffsetBottomY);
        
        // Draw the fill
        [progressImage drawInRect:fillRect];
    }
    else
        [super drawRect:rect];
}

@end
