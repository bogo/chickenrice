#import "BLNBalloonViewController.h"
#import "BLNManager.h"
#import "BLNAlertState.h"

@interface BLNBalloonViewController () <BLNManagerObserver>

@property (nonatomic, strong) UILabel *levelLabel;

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
    [self setupLabel];
    [self configureLevelLabelWithAlertState:[BLNManager sharedInstance].alertState];
    [self.view addSubview:self.levelLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"Welcome to the balloon view!");
}

#pragma mark - UI Setup
- (void)setupLabel
{
    self.levelLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)configureLevelLabelWithAlertState:(BLNAlertState)alertState
{
    self.levelLabel.text = [BLNAlertStateHelper stringFromAlertState:alertState];
    self.levelLabel.textColor = [BLNAlertStateHelper colorFromAlertState:alertState];
}

#pragma mark - BLNManagerObserver
- (void)manager:(BLNManager *)manager changedAlertStateTo:(BLNAlertState)alertState
{
    [self configureLevelLabelWithAlertState:alertState];
}

@end
