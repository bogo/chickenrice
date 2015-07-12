#import "BLNTrustedFriendsSetupViewController.h"
#import "BLNBalloonViewController.H"
#import "BLNManager.h"

@import Contacts;

@interface BLNTrustedFriendsSetupViewController ()

@property (nonatomic, strong) CNContact *ownerContact;

@end

@implementation BLNTrustedFriendsSetupViewController

- (instancetype)initWithOwnerContact:(CNContact *)ownerContact
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _ownerContact = ownerContact;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.headerText = @"Who do you trust?";
    self.bodyText = @"Based on your contact entry, we picked a person we think you trust the most! Make this contact your Trusted Friend by tapping below.";

}

- (void)acceptContact
{
    [[BLNManager sharedInstance] login];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
