//
//  TimerViewController.m
//  Werewolf
//
//  Created by Lauren Lee on 4/28/14.
//  Copyright (c) 2014 Lauren Lee. All rights reserved.
//

#import "TimerViewController.h"

@interface TimerViewController () <TTCounterLabelDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *clearLabel;

@property (weak, nonatomic) IBOutlet UIButton *plusOneMinButton;
@property (weak, nonatomic) IBOutlet UIButton *minusOneMinButton;
@property (weak, nonatomic) IBOutlet UIButton *readyToKillButton;

@end

@implementation TimerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapToStartPause = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTimerStartPause)];
    tapToStartPause.numberOfTapsRequired = 1;

    [_clearLabel.layer setBorderColor:[UIColor blackColor].CGColor];
    [_clearLabel.layer setBorderWidth:1.0];
    _clearLabel.userInteractionEnabled = YES;
    [_clearLabel addGestureRecognizer:tapToStartPause];
    
//    [_counterLabel setFrame:CGRectMake(_clearLabel.frame.origin.x, _clearLabel.frame.origin.y + 20, _counterLabel.frame.size.width, _counterLabel.frame.size.height)];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupCounter];
    
    _titleLabel.text = [NSString stringWithFormat:@"Day %d", _game.currentRound];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
}

- (void)setupCounter
{
    _counterLabel.countDirection = kCountDirectionDown;
    [_counterLabel setStartValue:600000];
}

#pragma mark - Button Methods

- (void)toggleTimerStartPause
{
    if ([_counterLabel isRunning]) {
        [_counterLabel stop];
    }
    else {
        [_counterLabel start];
    }
}

- (IBAction)addMinute:(id)sender {
    unsigned long long newTime = _counterLabel.currentValue + 60000;
    [_counterLabel setStartValue:newTime];
}

- (IBAction)subtractMinute:(id)sender {
    unsigned long long newTime = _counterLabel.currentValue - 60000;
    if (newTime <= 0) {
        [_counterLabel setStartValue:0];
    }
    else {
        [_counterLabel setStartValue:newTime];
    }
}

- (IBAction)readyToKillPressed:(id)sender {
    [self.delegate beginKillSelection];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
