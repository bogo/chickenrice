#import "BLNActionButton.h"
#import "UIColor+Balluun.h"
#import "UIFont+Lato.h"
@import QuartzCore;

@implementation BLNActionButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    
    [self applyStyle];
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self applyStyle];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self applyStyle];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self applyStyle];
}

- (void)applyStyle
{
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius = 4.0;
    self.layer.borderColor = [self borderColorForState:self.state].CGColor;

    self.backgroundColor = [self backgroundColorForState:self.state];
    self.titleLabel.font = [UIFont latoFontOfSize:16.0];
    [self setTitleColor:[UIColor bln_backgroundColor] forState:UIControlStateNormal];
}

- (UIColor *)borderColorForState:(UIControlState)state
{
    return [UIColor colorWithRed:0.9059 green:0.2980 blue:0.2353 alpha:1.0];
}

- (UIColor *)backgroundColorForState:(UIControlState)state
{
    return [UIColor bln_redColor];
}

@end
