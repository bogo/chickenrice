#import "BLNOwnerSetupViewController.h"
#import "BLNContactHelper.h"
#import "UIView+NSLayoutConstraint.h"
#import "BLNActionButton.h"
#import "UIColor+Balluun.h"
#import "UIFont+Lato.h"

@import QuartzCore;
@import Contacts;
@import ContactsUI;

@interface BLNContactViewController ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *contactContainerView;
@property (nonatomic, strong) BLNActionButton *acceptButton;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *bodyLabel;

@end

@implementation BLNContactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor bln_backgroundColor];
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.contentView];
    
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.headerLabel.font = [UIFont latoFontOfSize:28.0];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.textColor = [UIColor bln_textColor];
    self.headerLabel.shadowColor = [UIColor whiteColor];
    self.headerLabel.shadowOffset = CGSizeMake(0, 1);

    [self.contentView addSubview:self.headerLabel];
    
    self.bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.bodyLabel.font = [UIFont latoLightFontOfSize:15.0];
    self.bodyLabel.textAlignment = NSTextAlignmentCenter;
    self.bodyLabel.textColor = [UIColor bln_textColor];
    self.bodyLabel.shadowColor = [UIColor whiteColor];
    self.bodyLabel.shadowOffset = CGSizeMake(0, 1);
    self.bodyLabel.numberOfLines = 0;
    [self.contentView addSubview:self.bodyLabel];
    
    self.acceptButton = [[BLNActionButton alloc] initWithFrame:CGRectZero];
    [self.acceptButton addTarget:self
                          action:@selector(acceptContact)
                forControlEvents:UIControlEventTouchUpInside];
    [self.acceptButton setTitle:@"Accept Person"
                       forState:UIControlStateNormal];
    [self.contentView addSubview:self.acceptButton];
    
    self.contactContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contactContainerView.layer.masksToBounds = NO;
    self.contactContainerView.layer.cornerRadius = 8; // if you like rounded corners
//    self.contactContainerView.layer.shadowOffset = CGSizeMake(-15, 20);
    self.contactContainerView.layer.shadowRadius = 8;
    self.contactContainerView.layer.shadowOpacity = 0.5;
    self.contactContainerView.layer.shadowColor = [UIColor bln_shadowColor].CGColor;
    [self.contentView addSubview:self.contactContainerView];
    
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
    NSNumber *margin = @((CGRectGetWidth(self.view.frame) - width.floatValue)/2);
    NSNumber *spacer = @15;
    NSNumber *buttonHeight = @65;
    NSDictionary *metrics = NSDictionaryOfVariableBindings(width, height, margin, buttonHeight, spacer);
    NSDictionary *views = NSDictionaryOfVariableBindings(contactView, _contactContainerView, _acceptButton, _contentView, _headerLabel, _bodyLabel);
    
    [self.view addConstraintsFromVisualFormatStrings:@[
                                                       @"H:|-(margin)-[_contentView(width)]-(margin)-|",
                                                       @"V:|[_contentView]|",
                                                       ]
                                             metrics:metrics
                                               views:views];
    
    [self.contentView addConstraintsFromVisualFormatStrings:@[
                                                              @"H:|[_contactContainerView]|",
                                                              @"H:|[_acceptButton]|",
                                                              @"H:|[_headerLabel]|",
                                                              @"H:|[_bodyLabel]|",
                                                              @"V:[_headerLabel]-(spacer)-[_bodyLabel]-(spacer)-[_acceptButton(buttonHeight)]-(spacer)-[_contactContainerView(height)]|",
                                                              ]
                                                    metrics:metrics
                                                      views:views];
    
    [self.contactContainerView addConstraintsFromVisualFormatStrings:@[
                                                                       @"H:|[contactView]|",
                                                                       @"V:|[contactView]|",
                                                                       ]
                                                             metrics:metrics
                                                               views:views];
    
    [viewController didMoveToParentViewController:self];
}

- (void)acceptContact
{
    NSAssert(NO, @"You need to override this method in your subclass");
}

- (NSString *)headerText
{
    return self.headerLabel.text;
}

- (void)setHeaderText:(NSString *)headerText
{
    self.headerLabel.text = headerText;
}

- (NSString *)bodyText
{
    return self.bodyLabel.text;
}

- (void)setBodyText:(NSString *)bodyText
{
    self.bodyLabel.text = bodyText;
}

@end
