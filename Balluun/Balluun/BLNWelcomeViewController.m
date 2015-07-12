#import "BLNWelcomeViewController.h"
#import "BLNOwnerSetupViewController.h"
#import "BLNOwnerContactProvider.h"

@interface BLNWelcomeViewController ()

@end

@implementation BLNWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    BLNOwnerSetupViewController *vc = [[BLNOwnerSetupViewController alloc] init];
    vc.contactProvider = [BLNOwnerContactProvider new];
    
    [self showViewController:vc
                      sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
