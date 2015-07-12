#import "InterfaceController.h"
#import "BLNAlertState.h"
#import "BLNDirectReport.h"

@interface InterfaceController()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *cancelButton;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *subtitleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *alertButton;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInterface) name:BLNDirectReportStateChangedNotification object:nil];

    [self updateUserInterface];
}

- (void)updateUserInterface
{
    [self updateUserInterfaceWithState:[[BLNDirectReport sharedInstance] currentAlertState]];
}

- (void)updateUserInterfaceWithState:(BLNAlertState)state
{
    [self animateWithDuration:0.33 animations:^{
        [self.cancelButton setAlpha:(state == BLNAlertStateDEFCON) ? 1.0 : 0.0];
    }];

    [self.titleLabel setText:[NSString stringWithFormat:@"%i", [[BLNDirectReport sharedInstance] currentLocationScore]]];

    NSString *subtitleString = @"Safe";
    UIColor *color = [BLNAlertStateHelper colorFromAlertState:[[BLNDirectReport sharedInstance] currentLocationScore]];
    if (state >= BLNAlertStateDEFCON)
    {
        color = [BLNAlertStateHelper colorFromAlertState:BLNAlertStateDEFCON];
        subtitleString = @"Tracking";
    }
    else
    {
        if ([[BLNDirectReport sharedInstance] currentLocationScore] > BLNAlertStateGreen)
        {
            subtitleString = @"Activate";
        }
    }
    [self.alertButton setBackgroundColor:color];
    [self.subtitleLabel setText:subtitleString];
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)alertButtonTapped
{
    [[BLNDirectReport sharedInstance] startDefconState];
    [self updateUserInterfaceWithState:BLNAlertStateDEFCON];
    
}

- (IBAction)cancelButtonTapped
{
    [[BLNDirectReport sharedInstance] stopDefconState];
    [self updateUserInterfaceWithState:BLNAlertStateGreen];
}

@end



