#import "UIColor+Balluun.h"

@implementation UIColor (Balluun)

+ (UIColor *)bln_greenColor
{
    return [UIColor colorWithRed:39/255.0
                           green:174/255.0
                            blue:96/255.0
                           alpha:1.0];
}

+ (UIColor *)bln_orangeColor
{
    return [UIColor colorWithRed:211/255.0
                           green:84/255.0
                            blue:0/255.0
                           alpha:1.0];
}

+ (UIColor *)bln_redColor
{
    return [UIColor colorWithRed:192/255.0
                           green:57/255.0
                            blue:43/255.0
                           alpha:1.0];
}

+ (UIColor *)bln_defconColor
{
    return [UIColor bln_redColor];
}

+ (UIColor *)bln_buttonColor
{
    return [UIColor darkGrayColor];
}

+ (UIColor *)bln_textColor
{
    return [UIColor colorWithRed:44/255.0
                           green:62/255.0
                            blue:80/255.0
                           alpha:1.0];
}

+ (UIColor *)bln_backgroundColor
{
    return [UIColor colorWithRed:236/255.0
                           green:240/255.0
                            blue:241/255.0
                           alpha:1.0];
}

@end
