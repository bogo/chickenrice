#import "BLNOwnerSetupViewController.h"
#import "BLNContactHelper.h"
#import "UIView+NSLayoutConstraint.h"

@import Contacts;
@import ContactsUI;

@interface BLNContactViewController ()

@property (nonatomic, strong) UIView *contactContainerView;
@property (nonatomic, strong) UIButton *acceptButton;

@end

@implementation BLNContactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    [self.acceptButton addTarget:self
                          action:@selector(acceptContact)
                forControlEvents:UIControlEventTouchUpInside];
    [self.acceptButton setTitle:@"Accept Person"
                       forState:UIControlStateNormal];
    [self.acceptButton setTitleColor:[UIColor blackColor]
                            forState:UIControlStateNormal];
    [self.view addSubview:self.acceptButton];
    
    self.contactContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.contactContainerView];
    
    [[BLNContactHelper sharedHelper] authorize];
    
    CNContact *contactForConfirmation = [self.contactProvider provideContactToConfirm];
    [self displayContactForConfirmation:contactForConfirmation];
}


- (void)displayContactForConfirmation:(CNContact *)contact
{
    CNContactViewController *contactViewController = [CNContactViewController viewControllerForContact:contact];
    [self containContactViewController:contactViewController];
}

- (void)containContactViewController:(CNContactViewController *)viewController
{
    [self addChildViewController:viewController];
    UIView *contactView = viewController.view;
    [self.contactContainerView addSubview:contactView];
    
    NSNumber *width = @(0.75 * CGRectGetWidth(self.view.frame));
    NSNumber *height = @(0.5 * CGRectGetHeight(self.view.frame));
    NSDictionary *metrics = NSDictionaryOfVariableBindings(width, height);
    NSDictionary *views = NSDictionaryOfVariableBindings(contactView, _contactContainerView);
    
    [self.view addConstraintsFromVisualFormatStrings:@[
                                                       @"H:|-[_contactContainerView(width)]-|",
                                                       @"V:|-[_contactContainerView(height)]|",
                                                       ]
                                             metrics:metrics
                                               views:views];
    
    [self.contactContainerView addConstraintsFromVisualFormatStrings:@[
                                                                       @"H:|-[contactView]-|",
                                                                       @"V:|-[contactView]-|",
                                                                       ]
                                                             metrics:metrics
                                                               views:views];
    
    [viewController didMoveToParentViewController:self];
}

- (void)acceptContact
{
    NSAssert(NO, @"You need to override this method in your subclass");
}

@end
