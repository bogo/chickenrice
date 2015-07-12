#import "BLNOwnerSetupViewController.h"
#import "BLNTrustedFriendsSetupViewController.h"
#import "BLNTrustedFriendsContactProvider.h"
#import "BLNContactHelper.h"

@import Contacts;
@import ContactsUI;

@implementation BLNOwnerSetupViewController

- (void)acceptContact
{
    BLNTrustedFriendsSetupViewController *viewController = [[BLNTrustedFriendsSetupViewController alloc] initWithOwnerContact:[BLNContactHelper sharedHelper].deviceOwner];
    viewController.contactProvider = [BLNTrustedFriendsContactProvider new];
    
    [self showViewController:viewController
                      sender:self];
}

@end
