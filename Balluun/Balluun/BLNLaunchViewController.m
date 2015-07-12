#import "BLNLaunchViewController.h"
#import "BLNWelcomeViewController.h"

@interface BLNLaunchViewController ()
@property (nonatomic, strong) UIViewController *rootViewController;
@end

@implementation BLNLaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rootViewController = [BLNWelcomeViewController new];
    [self pushViewController:self.rootViewController
                    animated:NO];
}

@end
