//
//  ViewController.m
//  Werewolf
//
//  Created by Lauren Lee on 4/11/14.
//  Copyright (c) 2014 Lauren Lee. All rights reserved.
//

#import "TitleViewController.h"
#import "LoadSetupViewController.h"
#import "CRProductTour.h"

@interface TitleViewController ()

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (strong, nonatomic) CRProductTour *productTourView;
@property (strong, nonatomic) UITapGestureRecognizer *tapAnywhereToDismiss;

@end

@implementation TitleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSettingsPopover];
}

- (void)setupSettingsPopover
{
    _productTourView = [[CRProductTour alloc] initWithFrame:self.view.frame];
    
    // Create popover bubble
    CRBubble *settingsBubble = [[CRBubble alloc] initWithAttachedView:_settingsButton title:@"" description:@"Hold down three fingers to open\nthe settings at any time" arrowPosition:CRArrowPositionTop andColor:[UIColor colorWithWhite:0.298 alpha:1.000]];
    NSMutableArray *bubbleArray = [[NSMutableArray alloc] initWithObjects:settingsBubble, nil];
    [_productTourView setBubbles:bubbleArray];
    
    _tapAnywhereToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSettingsPopover:)];
    
    [self.view addSubview:_productTourView];
    
}

- (IBAction)toggleSettingsPopover:(id)sender {
    
    [_productTourView setVisible:![_productTourView isVisible]];
    
    if ([_productTourView isVisible]) {
       [self.view addGestureRecognizer:_tapAnywhereToDismiss];
    }
    else {
        [self.view removeGestureRecognizer:_tapAnywhereToDismiss];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide navigation bar on this screen
    [self.navigationController setNavigationBarHidden:YES];
    
    // Set status bar color to default = black
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
