#import "BLNBalloonViewController.h"
#import "BLNManager.h"
#import "BLNAlertState.h"
#import "BLNActionButton.h"

@interface BLNBalloonViewController () <BLNManagerObserver>

@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) BLNActionButton *defconButton;

@end

@implementation BLNBalloonViewController

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }

    [[BLNManager sharedInstance] addObserver:self];

    return self;
}

- (void)dealloc
{
    [[BLNManager sharedInstance] removeObserver:self];
}

- (void)viewDidLoad
{
    self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self setupLevelLabel];
    [self.view addSubview:self.levelLabel];
    
    self.defconButton = [[BLNActionButton alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
    [self setupDefconButton];
    [self.view addSubview:self.defconButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    BLNAlertState alertState = [BLNManager sharedInstance].currentAlertState;
    [self configureLevelLabelWithAlertState:alertState];
    [self configureDefconButtonWithAlertState:alertState];
}

#pragma mark - UI Setup
- (void)setupLevelLabel
{
    self.levelLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)configureLevelLabelWithAlertState:(BLNAlertState)alertState
{
    self.levelLabel.text = [BLNAlertStateHelper stringFromAlertState:alertState];
    self.levelLabel.textColor = [BLNAlertStateHelper colorFromAlertState:alertState];
}

- (void)setupDefconButton
{
    [self.defconButton setTitle:@"Enter Defcon"
                       forState:UIControlStateNormal];
    [self.defconButton setTitle:@"Leave Defcon"
                       forState:UIControlStateSelected];
    
    [self.defconButton addTarget:self
                          action:@selector(toggleDefcon)
                forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureDefconButtonWithAlertState:(BLNAlertState)alertState
{
    switch (alertState) {
        case BLNAlertStateGreen:
        case BLNAlertStateOrange:
        case BLNAlertStateRed: {
            self.defconButton.selected = NO;
            break;
        }
        case BLNAlertStateDEFCON: {
            self.defconButton.selected = YES;
            break;
        }
    }
}

#pragma mark - DEFCON

- (void)toggleDefcon
{
    switch ([BLNManager sharedInstance].currentAlertState) {
        case BLNAlertStateGreen:
        case BLNAlertStateOrange:
        case BLNAlertStateRed: {
            [[BLNManager sharedInstance] startDefconState];
            break;
        }
        case BLNAlertStateDEFCON: {
            [[BLNManager sharedInstance] stopDefconState];
            break;
        }
    }
}

#pragma mark - BLNManagerObserver
- (void)manager:(BLNManager *)manager changedAlertStateTo:(BLNAlertState)alertState
{
    [self configureLevelLabelWithAlertState:alertState];
    [self configureDefconButtonWithAlertState:alertState];
}

@end
