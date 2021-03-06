//
//  GameViewController.m
//  Werewolf
//
//  Created by Lauren Lee on 4/25/14.
//  Copyright (c) 2014 Lauren Lee. All rights reserved.
//

#import "GameViewController.h"
#import "EndGameViewController.h"
#import "NightActionController.h"
#import "CarouselController.h"
#import "Player.h"
#import "AlphaView.h"
#import "Role.h"
#import "Seer.h"


#define ALERT_VIEW_TAG 33700


@interface GameViewController () <UIAlertViewDelegate, UITextFieldDelegate, TimerViewControllerProtocol, CarouselControllerProtocol, NightActionControllerProtocol>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *whereToTapLabel;
@property (weak, nonatomic) IBOutlet UIButton *cornerButton;

@property (strong, nonatomic) EndGameViewController *endGameViewController;
@property (strong, nonatomic) NightActionController *nightActionController;
@property (strong, nonatomic) CarouselController *carouselController;

@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) AlphaView *alphaView;
@property (strong, nonatomic) UIView *boxView;

@property (nonatomic) BOOL firstAppearance;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Game View did Load");
    
    [self setupGameControllers];
    
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(20, 233, 160, 40)];
    [_boxView.layer setBorderWidth:1];
    [_boxView.layer setCornerRadius:5];
    _boxView.layer.masksToBounds = YES;
    [self.view addSubview:_boxView];
    
    [self turnLight];
    [self setupCarousel];
    [self setupCornerButton];
    
    [self.view sendSubviewToBack:_boxView];

    [self updateTapLabelWithString:@"Hello Moderator!\nSelect a player to update their name. (Player 1 is to your right.)"];
    
//    [self createAlphaView];
//    [self showPregameExplanationView];
    
    _alphaView = [[AlphaView alloc] initWithFrame:self.view.frame];
    _firstAppearance = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_firstAppearance) {
//        [self beginNameEntry];
//        [_carousel scrollByNumberOfItems:_game.numPlayers duration:1];
        _firstAppearance = NO;
    }
}

- (void)setupGameControllers
{
    _timerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"timer"];
    _timerViewController.game = _game;
    _timerViewController.delegate = self;
    
    _nightActionController = [NightActionController new];
    _nightActionController.game = _game;
    _nightActionController.delegate = self;
    
    _carouselController = [CarouselController new];
    _carouselController.game = _game;
    _carouselController.delegate = self;
}

#pragma mark - Timer View Controller Methods

- (void)showTimerViewController
{
    [_alphaView maxAlpha];
    [self showAlphaView];
    [_timerViewController.view setAlpha:0.0];
    
    [self addChildViewController:_timerViewController];
    [self.view addSubview:_timerViewController.view];
    [_timerViewController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:2 animations:^{
        [_timerViewController.view setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self dismissAlphaView];
    }];
    
}

- (void)hideTimerViewController
{
    [_timerViewController.view removeFromSuperview];
    [_timerViewController removeFromParentViewController];
}

#pragma mark - End Game View Controller

- (void)showEndGameViewController
{
    [_alphaView maxAlpha];
    [self showAlphaView];
    [_endGameViewController.view setAlpha:0.0];
    
    [self addChildViewController:_endGameViewController];
    [self.view addSubview:_endGameViewController.view];
    [_endGameViewController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:2 animations:^{
        [_endGameViewController.view setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self dismissAlphaView];
    }];
}

#pragma mark - Game Mode Methods

//- (void)getNextNameEntry
//{
//    [self moveToNextPlayer];
//    if (_game.didWrap) {
//        NSLog(@"Game did wrap");
//        [self showViewOfType:kBeginDay];
//    }
//    else {
//        [self createAlertViewOfType:kNameEntry];
//    }
//
//}

- (void)showRoleToNextPlayer
{
    [self dismissAlphaView];
    if (_game.didWrap) {
        [self showViewOfType:kBeginDay];
    }
    else {
        [self createAlertViewOfType:kReadyToSeeRole];
    }
}

- (void)moveToNextNightAction
{
    [self dismissAlphaView];
    if (_game.didWrap) {
        [self createAlertViewOfType:kNightResult];
    }
    else {
        [self createAlertViewOfType:kAreYouX];
    }
}

// Passing the phone to the next player at night
- (void)moveToNextPlayer
{
    _game.currentPlayerIndex = [_game nextAlivePlayer:_game.currentPlayerIndex];
    [_carousel scrollToItemAtIndex:_game.currentPlayerIndex animated:YES];
    if (_game.currentRound > 0) {
        [self resetTapLabel];
        [self hideCornerButton];
    }
}

- (void)scrollToNextPlayer
{
    int nextIndex = [_game nextAlivePlayer:_carousel.currentItemIndex];
    [_carousel scrollToItemAtIndex:nextIndex animated:YES];
}

- (void)passedToPlayer
{
    [self dismissAlphaView];
    if (_game.currentRound == 0) {
        [self createAlertViewOfType:kReadyToSeeRole];
    }
    else {
        [self createAlertViewOfType:kAreYouX];
    }

}

// Pop open Timer View
- (void)beginDay
{
    [self dismissAlphaView];
    
    _game.currentRound++;
    _game.isNight = NO;
    
    
    [self showTimerViewController];
    
}

// Let players select person to kill
- (void)beginKillSelection
{
    [self turnLight];
    [_titleLabel setText:@"Who To Kill?"];
    [self showNoKillCornerButton];
    [self resetCarousel];
    
    [self hideTimerViewController];
    
//    [self showKillExplanationView];
    
}

- (void)beginNight
{
    [UIView animateWithDuration:2 animations:^{
        
        [self hideCornerButton];
        
        _titleLabel.text = [NSString stringWithFormat:@"Night %d", _game.currentRound];
        _game.isNight = YES;
        [self resetTapLabel];
        [self resetCarousel];
        [self turnDark];

    } completion:^(BOOL finished) {
        
        if (_game.currentRound == 0) {
            [self createAlertViewOfType:kReadyToSeeRole];
        }
        else
        {
            int numWolves = [[_game.gameSetup.roleNumbers objectForKey:@"Werewolf"] intValue];
            if (numWolves > 1) {
                [self showViewOfType:kWolvesDecideKill];
            }
            else {
                [self createAlertViewOfType:kAreYouX];
            }
        }
    }];
}

- (void)wolvesDecidedKill
{
    [self dismissAlphaView];
    [self createAlertViewOfType:kAreYouX];
}

#pragma mark - Changing Skin Methods

- (void)turnDark
{
    //change view to dark skin
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.098 alpha:1.000]];
    [_boxView.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [_carousel reloadData];
}

- (void)turnLight
{
    //change view to light skin
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [_boxView.layer setBorderColor:[UIColor blackColor].CGColor];
    
    [_carousel reloadData];
}


#pragma mark - Subview Methods

- (void)showAlphaView
{
    [self.view addSubview:_alphaView];
}

-(void)dismissAlphaView
{
    [_alphaView removeFromSuperview];
    [_alphaView reset];
}

- (void)showViewOfType:(NSInteger)type
{
    [self dismissAlphaView];
    UITapGestureRecognizer *tapToDismiss;
    
    switch (type) {
            
        case kPassRight:
            
            [_alphaView addBigText:@"PASS\nRIGHT"];
            if (_game.currentRound == 0) {
                tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRoleToNextPlayer)];
            }
            else {
                tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveToNextNightAction)];
            }
            [_alphaView addGestureRecognizer:tapToDismiss];
            break;
            
        case kBeginDay:
            
            [_alphaView addBigText:[NSString stringWithFormat:@"BEGIN\nDAY %d",_game.currentRound+1]];
            tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginDay)];
            [_alphaView addGestureRecognizer:tapToDismiss];
            break;
            
        case kPassToPlayer:
            
            [_alphaView addBigText:@"PASS\nTO"];
            [_alphaView addBoxView];
            tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passedToPlayer)];
            [_alphaView addGestureRecognizer:tapToDismiss];
            break;
            
        case kWolvesDecideKill:
            
            [_alphaView addExplanationViewWithMessage:@"Moderator, please memorize and then do the following:\n\n1) Say \"Village, go to sleep.\"\n\n2) Close your eyes.\n\n3) Say \"Wolves wake up. Pick who to kill.\"\n\n4) Wait ten seconds.\n\n5) Say \"Wolves go to sleep.\"\n\n6) Say \"Everyone wake up.\"\n\n7) Then starting with you, use the phone to perform night actions."];
            tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wolvesDecidedKill)];
            [_alphaView addGestureRecognizer:tapToDismiss];
            
        default:
            break;
    }
    
    [self showAlphaView];
}


#pragma mark - Alert View Methods

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_VIEW_TAG + kNameEntry) {
        
        Player *currentSelectedPlayer = _game.players[_carousel.currentItemIndex];
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        if (buttonIndex == 1) {
            if ([_game isDuplicateName:textField.text]) {
                [alertView setMessage:@"That's the same name as someone else. Pick another."];
            }
            else {
                [currentSelectedPlayer setName:textField.text];
                [_carousel reloadData];
                if (_game.isNight) {
                    [self createAlertViewOfType:kReadyToSeeRole];
                }
            }
        }
        else {
            if (_game.isNight) {
                [self createAlertViewOfType:kReadyToSeeRole];
            }
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textField;
    
    Player *currentSelectedPlayer = _game.players[_carousel.currentItemIndex];
    
    switch (alertView.tag) {
            
        case ALERT_VIEW_TAG + kNameEntry:
            
            // Allows moderator to enter a player name
            
            textField = [alertView textFieldAtIndex:0];
            
            if (buttonIndex == 1) {

                    [currentSelectedPlayer setName:textField.text];
                    [_carousel reloadData];
                    if (_game.isNight) {
                        [self createAlertViewOfType:kReadyToSeeRole];
                    }
                    else{
                        [self scrollToNextPlayer];
                    }
            }
            break;
            
        case ALERT_VIEW_TAG + kReadyToSeeRole:
            
            // Asks Player "Are you ready to see your role?"
            
            if (buttonIndex == 0) {
                [self showViewOfType:kPassToPlayer]; // Wrong person!
            }
            else if (buttonIndex == 1) {
                [self createAlertViewOfType:kShowRoleAlert]; // Yes! Show role
            }
            else if (buttonIndex == 2) {
                [self createAlertViewOfType:kNameEntry]; // Name incorrect! Change
            }
            
            break;
            
        case ALERT_VIEW_TAG + kShowRoleAlert:
            
            // Shows Player their role and role information
            
            if (buttonIndex == 0) {
                [self showViewOfType:kPassRight];
                [self moveToNextPlayer];
            }
            
            break;
            
        case ALERT_VIEW_TAG + kKillPlayer:
            
            // Selects player to kill
            
            if (buttonIndex == 1) {
                // Kill player
                
                [_game killPlayerAtIndex:_carousel.currentItemIndex];
                [self beginNight];
                
                [_carousel reloadData];
            }
            
            break;
            
        case ALERT_VIEW_TAG + kNoKillConfirmation:
            
            if (buttonIndex == 1) {
                [_game checkGameState];
                [self beginNight];
            }
            
            break;
            
        case ALERT_VIEW_TAG + kAreYouX:
            
            if (buttonIndex == 1) {
                [self updateTapLabelWithString:[_game.currentPlayer.role tapLabel]];
                [self showCornerButtonForCurrentPlayer];
            }
            else {
                [self showViewOfType:kPassToPlayer];
            }
            
            break;
            
            
        case ALERT_VIEW_TAG + kNightAction:
            
            if (buttonIndex == 1) {
                
                [[NSOperationQueue new] addOperationWithBlock:^{
                    [_nightActionController handleNightActionWithSelectedPlayer:currentSelectedPlayer];
                    
                    if ([_game.currentPlayer.role isKindOfClass:[Seer class]]) {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self createAlertViewOfType:kSeerPeek];
                        }];
                    }
                    else {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            
                            [self showViewOfType:kPassRight];
                            [self moveToNextPlayer];

                        }];
                    }
                }];
                
            }
            
            break;
            
        case ALERT_VIEW_TAG + kSeerPeek:
            
            if (buttonIndex == 0) {
                [self showViewOfType:kPassRight];
                [self moveToNextPlayer];

            }
            break;
            
        case ALERT_VIEW_TAG + kNightActionConfirm:
            
            if (buttonIndex == 0) {
                [self showViewOfType:kPassRight];
                [self moveToNextPlayer];
            }
            break;
            
        case ALERT_VIEW_TAG + kNightResult:
            
            if (buttonIndex == 0) {
                
                if (_game.isOver) {
                    _endGameViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"endGame"];
                    _endGameViewController.game = _game;
                    [self showEndGameViewController];

                }
                else {
                    [self beginDay];
                }
                
            }
            
            break;
            
        default:
            
            break;
    }
    

}

- (void)createAlertViewOfType:(NSInteger)type
{
    UIAlertView *alertView;
    Player *currentSelectedPlayer = _game.players[_carousel.currentItemIndex];
    
    
    switch (type) {
            
        {case kNameEntry:
        
            _alertView = [[UIAlertView alloc] initWithTitle:@"Enter Name Of Player"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Submit", nil];
            
            
            
//            switch (_game.currentPlayerIndex) {
//                case 0:
//                    alertView = [[UIAlertView alloc] initWithTitle:@"Hello Moderator!" message:@"Please enter everyone's names, starting with yours" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//                    break;
//                case 1:
//                    alertView = [[UIAlertView alloc] initWithTitle:@"Enter The Name Of The Player To Your Right" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//                    break;
//                default:
//                    alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Enter The Name Of The Player To The Right Of %@", _game.previousPlayer.name] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//                    break;
//            }
            
            _alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            _alertView.tag = ALERT_VIEW_TAG + kNameEntry;
            [[_alertView textFieldAtIndex:0] setDelegate:self];
            [[_alertView textFieldAtIndex:0] setText:[currentSelectedPlayer name]];
            [[_alertView textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
            [[_alertView textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
            
            alertView = _alertView;
            
            break;
        }
            
        {case kReadyToSeeRole:
            
          
            alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Hello %@", _game.currentPlayer.name]
                                                    message:@"Ready to see your role?"
                                                   delegate:self
                                          cancelButtonTitle:[NSString stringWithFormat:@"I'm not %@!", _game.currentPlayer.name]
                                          otherButtonTitles: @"Yes, show me my role!", @"Yes, but let me fix my name", nil];
            alertView.tag = ALERT_VIEW_TAG + kReadyToSeeRole;
            break;
        }
            
        {case kKillPlayer:
            
            alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Kill %@?", currentSelectedPlayer.name]
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles: @"Yes", nil];
            alertView.tag = ALERT_VIEW_TAG + kKillPlayer;
            break;}
            
        case kShowRoleAlert:
            
            alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Your Role: %@", [_game.currentPlayer.role name]]
                                                    message:[[_game.currentPlayer role] getNightZeroInfo]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
            alertView.tag = ALERT_VIEW_TAG + kShowRoleAlert;
            break;
            
        case kNoKillConfirmation:
            
            alertView = [[UIAlertView alloc] initWithTitle:@"Are You Sure?"
                                                    message:@"Not killing is usually inadvisable for the village"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"We're sure", nil];
            alertView.tag = ALERT_VIEW_TAG + kNoKillConfirmation;
            break;
            
        case kAreYouX:
            
            alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Are You %@?", [_game.currentPlayer name]]
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
            alertView.tag = ALERT_VIEW_TAG + kAreYouX;
            break;
            
        case kNightAction:
            
            alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You've Selected %@", [currentSelectedPlayer name]]
                                                    message:@"Final answer?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
            alertView.tag = ALERT_VIEW_TAG + kNightAction;
            break;
            
        case kSeerPeek:
            
            alertView = [[UIAlertView alloc] initWithTitle:@"You Take A Peek"
                                                    message:[NSString stringWithFormat:@"%@ looks like a %@", currentSelectedPlayer.name, currentSelectedPlayer.role.seerSeesAs]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
            alertView.tag = ALERT_VIEW_TAG + kSeerPeek;
            break;
            
        case kNightActionConfirm:
            
            alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You've Chosen %@", currentSelectedPlayer.name]
                                                    message:[_nightActionController getNightActionConfirmMessageForPlayer:currentSelectedPlayer]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
            alertView.tag = ALERT_VIEW_TAG + kNightActionConfirm;
            
            break;
            
        case kNightResult:
            
            alertView = [[UIAlertView alloc] initWithTitle:@"You wake and find..."
                                                   message:[_game checkNightResult]
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
            alertView.tag = ALERT_VIEW_TAG + kNightResult;

            break;
            
        default:
            NSLog(@"unknown alert type: %ld", (long)type);
            break;
    }
    

    [alertView show];
}


- (void)showPassToAlertView
{
    Player *currentPlayer = _game.players[_carousel.currentItemIndex];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Pass the device to %@", currentPlayer.name] message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    alertView.tag = PASS_TO_ALERT_TAG;
    [alertView show];

}

- (void)showRoleAlertView
{
    Player *currentPlayer = _game.players[_game.currentPlayerIndex];
    NSString *additionalMessage = @"";
//    additionalMessage = [_nightActionController createSecretMessageForPlayer:currentPlayer];
    
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Your Role: %@", currentPlayer.role.name]
                                                        message:additionalMessage
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
//    alertView.tag = SHOW_ROLE_ALERT_TAG;
    [alertView show];
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag == ALERT_VIEW_TAG + kNameEntry) {
        UITextField *textfield = [alertView textFieldAtIndex:0];
        
        if ([textfield.text length] > 0) {
            if ([_game isDuplicateName:textfield.text]) {
                [alertView setMessage:@"Same or duplicate name! Please change to something different."];
                return NO;
            }
            else
            {
                [alertView setMessage:@""];
                return YES;
            }
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - Text Field Methods

//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    int textLength = [textField.text length];
//    int replacementLength = [string length];
//    
//    NSLog(@"%@ %@",textField.text, string);
//    
//    BOOL hasCharacters = (replacementLength > 0) || (textLength > 1);
//    if (hasCharacters) {
//        UIButton *submitButton = [[alertView subviews] lastObject];
//        if ([_game isDuplicateName:string]) {
//            [submitButton setEnabled:NO];
//            [alertView setMessage:@"That's the same name as someone else!"];
//        }
//        else {
//            [submitButton setEnabled:YES];
//            [alertView setMessage:@""];
//        }
//    }
//    
//    return YES;
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_alertView dismissWithClickedButtonIndex:1 animated:YES];
    
    return YES;
}

#pragma mark - iCarousel Methods

-(void)setupCarousel
{
    _carousel.delegate = _carouselController;
    _carousel.dataSource = _carouselController;
    _carousel.type = iCarouselTypeInvertedWheel;
    _carousel.viewpointOffset = CGSizeMake(50, 0);
    _carousel.vertical = YES;
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (_carousel.autoscroll > 0) {
//        _carousel.autoscroll = 0;
//        [_carousel scrollToItemAtIndex:0 animated:YES];
//    }
//}

- (void)resetCarousel
{
    _game.currentPlayerIndex = [_game nextAlivePlayer:-1];
    [_carousel scrollToItemAtIndex:_game.currentPlayerIndex animated:YES];
    _game.didWrap = NO;
}

#pragma mark - Tap Label Methods

-(void)updateTapLabelWithString:(NSString *)string
{
    [_whereToTapLabel setText:string];
}

-(void)resetTapLabel
{
    [_whereToTapLabel setText:@""];
}

#pragma mark - Button Methods

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupCornerButton
{
    [_cornerButton setTitle:@"Ready To Start" forState:UIControlStateNormal];
    [_cornerButton addTarget:self action:@selector(beginNight) forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideCornerButton
{
    [_cornerButton setHidden:YES];
    [_cornerButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
}

- (void)showNoKillCornerButton
{
    [_cornerButton setTitle:@"No Kill" forState:UIControlStateNormal];
    [_cornerButton addTarget:self action:@selector(noKillPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cornerButton setHidden:NO];

}

- (void)noKillPressed
{
    if (!_game.isNight) {
        [self createAlertViewOfType:kNoKillConfirmation];
    }
    else {
        [self showViewOfType:kPassRight];
        [self moveToNextPlayer];
    }
    
}

- (void)showCornerButtonForCurrentPlayer
{
    switch (_game.currentPlayer.role.roleID) {
        case kWerewolf:
        case kVigilante:
            [self showNoKillCornerButton];
            break;
            
        default:
            break;
    }
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
