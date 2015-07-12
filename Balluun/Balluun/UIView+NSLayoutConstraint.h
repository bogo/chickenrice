@import UIKit;

@interface UIView (NSLayoutConstraint)

- (void)addConstraintsFromVisualFormatStrings:(NSArray *)strings
                                      metrics:(NSDictionary *)metrics
                                        views:(NSDictionary *)views;

@end
