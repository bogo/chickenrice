#import "UIView+NSLayoutConstraint.h"

@implementation UIView (NSLayoutConstraint)

- (void)addConstraintsFromVisualFormatStrings:(NSArray *)strings
                                      metrics:(NSDictionary *)metrics
                                        views:(NSDictionary *)views
{
    for (UIView *view in views.allValues) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSMutableArray<NSLayoutConstraint *> *constraints = @[ ].mutableCopy;
    for (NSString *formatString in strings) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:formatString
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:views]];
    }
    [self addConstraints:constraints];
}

@end
