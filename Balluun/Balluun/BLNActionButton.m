#import "BLNActionButton.h"

@implementation BLNActionButton

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
    self.backgroundColor = [self backgroundColorForState:self.state];
    self.layer.borderColor = [self borderColorForState:self.state].CGColor;
}

- (UIColor *)borderColorForState:(UIControlState)state
{
    return [UIColor greenColor];
}

- (UIColor *)backgroundColorForState:(UIControlState)state
{
    return [UIColor redColor];
}

@end
