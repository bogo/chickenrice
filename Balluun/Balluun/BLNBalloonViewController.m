#import "BLNBalloonViewController.h"
#import "BLNManager.h"
#import "BLNAlertState.h"
#import "BLNActionButton.h"
#import "UIView+NSLayoutConstraint.h"

@import MapKit;

@interface BLNBalloonViewController () <BLNManagerObserver>

@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) BLNActionButton *defconButton;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) MKMapView *mapView;

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
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    [self.view addSubview:self.mapView];
    
    self.maskView = [[UIView alloc] initWithFrame:self.view.frame];
    [self setupMapView];
    [self.view addSubview:self.maskView];

    self.promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.levelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self setupLevelLabel];
    [self.view addSubview:self.promptLabel];
    [self.view addSubview:self.levelLabel];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_mapView, _maskView, _promptLabel, _levelLabel);
    
    [self.view addConstraintsFromVisualFormatStrings:@[
                                                       @"H:|-[_mapView]-|",
                                                       @"V:|-[_mapView]|",
                                                       @"H:|-[_maskView]-|",
                                                       @"V:|-[_maskView]|",
                                                       @"H:|-[_promptLabel]-|",
                                                       @"H:|-[_levelLabel]-|",
                                                       @"V:|-[_promptLabel]-[_levelLabel]"
                                                       ]
                                             metrics:nil
                                               views:views];
    
    self.defconButton = [[BLNActionButton alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
    [self setupDefconButton];
    [self.view addSubview:self.defconButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    BLNAlertState alertState = [BLNManager sharedInstance].currentAlertState;
    [self configureMapWithAlertState:alertState];
    [self configureLevelLabelWithAlertState:alertState];
    [self configureDefconButtonWithAlertState:alertState];
}

#pragma mark - UI Setup
- (void)setupLevelLabel
{
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    self.promptLabel.text = @"Your current safety status is:";
    
    self.levelLabel.textAlignment = NSTextAlignmentCenter;
    self.levelLabel.font = [UIFont boldSystemFontOfSize:72.0];
}

- (void)configureLevelLabelWithAlertState:(BLNAlertState)alertState
{
    self.levelLabel.text = [[BLNAlertStateHelper stringFromAlertState:alertState] uppercaseString];
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

- (void)setupMapView
{
    self.maskView.backgroundColor = [UIColor whiteColor];
    self.maskView.alpha = 0.7;
}

- (void)configureMapWithAlertState:(BLNAlertState)alertState
{
    switch (alertState) {
        case BLNAlertStateGreen: {
            break;
        }
        case BLNAlertStateOrange: {
            break;
        }
        case BLNAlertStateRed: {
            break;
        }
        case BLNAlertStateDEFCON: {
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
    [self configureMapWithAlertState:alertState];
    [self configureLevelLabelWithAlertState:alertState];
    [self configureDefconButtonWithAlertState:alertState];
}

@end
