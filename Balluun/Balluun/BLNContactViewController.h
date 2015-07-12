#import "BLNContactProvider.h"
@import UIKit;

/**
 * A view controller to handle contact-related confirmation procedures.
 */
@interface BLNContactViewController : UIViewController

/**
 * This provider needs to be set on the initialization of subclass.
 */
@property (nonatomic, strong) id<BLNContactProvider> contactProvider;

/**
 * @warning This asserts in parent class. You need to subclass.
 */
- (void)acceptContact;

@end
