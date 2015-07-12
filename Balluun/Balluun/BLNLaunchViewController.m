#import "BLNLaunchViewController.h"
#import "BLNManager.h"
#import "BLNWelcomeViewController.h"
#import "BLNBalloonViewController.h"

@interface BLNLaunchViewController ()
@property (nonatomic, strong) UIViewController *rootViewController;
@end

@implementation BLNLaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    switch ([BLNManager sharedInstance].loginState) {
        case BLNLoginStateLoggedIn:
        {
            [self enterBalloonFlow];
            break;
        }
            
        case BLNLoginStateLoggedOut:
        {
            [self enterWelcomeFlow];
            break;
        }
    }
}

- (void)enterBalloonFlow
{
    self.rootViewController = [BLNBalloonViewController new];
    [self.navigationController pushViewController:self.rootViewController
                                         animated:NO];
}

- (void)enterWelcomeFlow
{
    self.rootViewController = [BLNWelcomeViewController new];
    [self.navigationController pushViewController:self.rootViewController
                                         animated:NO];
}

@end
