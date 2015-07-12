#import "BLNOwnerSetupViewController.h"
#import "BLNTrustedFriendsSetupViewController.h"
#import "BLNTrustedFriendsContactProvider.h"
#import "BLNContactHelper.h"

@import Contacts;
@import ContactsUI;

@implementation BLNOwnerSetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.headerText = @"Is that you?";
    self.bodyText = @"Based on your iPhone's name, we think this is your contact. If that's so, press button below to continue!";
}

- (void)acceptContact
{
    BLNTrustedFriendsSetupViewController *viewController = [[BLNTrustedFriendsSetupViewController alloc] initWithOwnerContact:[BLNContactHelper sharedHelper].deviceOwner];
    viewController.contactProvider = [BLNTrustedFriendsContactProvider new];
    
    [self showViewController:viewController
                      sender:self];
}

@end
