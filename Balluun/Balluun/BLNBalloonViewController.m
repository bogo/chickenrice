#import "BLNBalloonViewController.h"
#import "BLNManager.h"
#import "BLNAlertState.h"
#import "BLNActionButton.h"
#import "UIView+NSLayoutConstraint.h"
#import "UIFont+Lato.h"
#import "UIColor+Balluun.h"

@import MapKit;

@interface BLNBalloonViewController () <BLNManagerObserver>

@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UILabel *biometricLabel;
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
    self.view.backgroundColor = [UIColor bln_backgroundColor];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    [self.view addSubview:self.mapView];
    
    self.maskView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setupMapView];
    [self.view addSubview:self.maskView];

    self.promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.levelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self setupLevelLabel];
    [self.view addSubview:self.promptLabel];
    [self.view addSubview:self.levelLabel];
    
    self.biometricLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self setupBiometricLabel];
    [self.view addSubview:self.biometricLabel];
    
    self.defconButton = [[BLNActionButton alloc] initWithFrame:CGRectZero];
    [self setupDefconButton];
    [self.view addSubview:self.defconButton];

    NSDictionary *views = NSDictionaryOfVariableBindings(_mapView, _maskView, _promptLabel, _levelLabel, _defconButton, _biometricLabel);
    
    [self.view addConstraintsFromVisualFormatStrings:@[
                                                       @"H:|[_mapView]|",
                                                       @"H:|[_maskView]|",
                                                       @"H:|[_promptLabel]|",
                                                       @"H:|[_levelLabel]|",
                                                       @"V:|[_mapView]|",
                                                       @"V:|[_maskView]|",
                                                       @"V:|-(100)-[_promptLabel]-[_levelLabel]",
                                                       @"H:|-[_defconButton]-|",
                                                       @"H:|-[_biometricLabel]-|",
                                                       @"V:[_biometricLabel]-[_defconButton(65)]-(100)-|",
                                                       ]
                                             metrics:nil
                                               views:views];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    BLNAlertState alertState = [BLNManager sharedInstance].currentLocationScore;
    [self configureMapWithAlertState:alertState];
    [self configureLevelLabelWithAlertState:alertState];
    [self configureDefconButtonWithAlertState:alertState];
    [self configureBiometricLabelWithAlertState:alertState];
}

#pragma mark - UI Setup
- (void)setupLevelLabel
{
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    self.promptLabel.font = [UIFont latoLightFontOfSize:18.0];
    self.promptLabel.textColor = [UIColor bln_textColor];
    self.promptLabel.text = @"Your current safety status is:";
    self.promptLabel.shadowColor = [UIColor whiteColor];
    self.promptLabel.shadowOffset = CGSizeMake(0, 1);
    
    self.levelLabel.textAlignment = NSTextAlignmentCenter;
    self.levelLabel.font = [UIFont latoFontOfSize:64.0];
    self.levelLabel.shadowColor = [UIColor whiteColor];
    self.levelLabel.shadowOffset = CGSizeMake(0, 1);
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
            self.defconButton.alpha = 1.0;
            self.defconButton.selected = NO;
            break;
        }

        case BLNAlertStateDEFCON: {
            self.defconButton.selected = YES;
            break;
        }

        case BLNAlertStatePanicked: {
            self.defconButton.selected = YES;
            self.defconButton.alpha = 0.0;
            break;
        }
    }
}

- (void)setupMapView
{
    self.mapView.alpha = 0.8;
    self.maskView.alpha = 0.05;
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
        case BLNAlertStatePanicked: {
            break;
        }
        case BLNAlertStateDEFCON: {
            break;
        }
    }
    self.maskView.backgroundColor = [BLNAlertStateHelper colorFromAlertState:alertState];
    self.mapView.tintColor = [BLNAlertStateHelper colorFromAlertState:alertState];
}

- (void)setupBiometricLabel
{
    self.biometricLabel.textAlignment = NSTextAlignmentCenter;
    self.biometricLabel.font = [UIFont latoFontOfSize:16.0];
    self.biometricLabel.textColor = [UIColor bln_textColor];
    self.biometricLabel.shadowColor = [UIColor whiteColor];
    self.biometricLabel.shadowOffset = CGSizeMake(0, 1);
}

- (void)configureBiometricLabelWithAlertState:(BLNAlertState)alertState
{
    switch (alertState) {
        case BLNAlertStateGreen:
        case BLNAlertStateOrange:
        case BLNAlertStateRed: {
            self.biometricLabel.alpha = 0.0;
            break;
        }
        case BLNAlertStateDEFCON:
        case BLNAlertStatePanicked: {
            self.biometricLabel.alpha = 1.0;
            self.biometricLabel.text = [NSString stringWithFormat:@"%@'s heart rate is %ld bpm", [BLNManager sharedInstance].name, (long)[BLNManager sharedInstance].currentHeartRate.integerValue];
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
        case BLNAlertStatePanicked: {
            break;
        }
    }
}

#pragma mark - BLNManagerObserver
- (void)manager:(BLNManager *)manager changedAlertStateTo:(BLNAlertState)alertState
{
    if (alertState == BLNAlertStateGreen) {
        alertState = manager.currentLocationScore;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureMapWithAlertState:alertState];
        [self configureLevelLabelWithAlertState:alertState];
        [self configureDefconButtonWithAlertState:alertState];
        [self configureBiometricLabelWithAlertState:alertState];
    });
}

- (void)manager:(BLNManager *)manager changedBPMTo:(double)bpm
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureBiometricLabelWithAlertState:manager.currentAlertState];
    });
}

- (void)manager:(BLNManager *)manager changedLocationStateTo:(BLNAlertState)alertState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureMapWithAlertState:alertState];
        [self configureLevelLabelWithAlertState:alertState];
        [self configureDefconButtonWithAlertState:alertState];
        [self configureBiometricLabelWithAlertState:alertState];
    });
}

@end
