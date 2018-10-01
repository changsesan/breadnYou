//
//  IntroViewController.m
//  FoodyUser
//
//  Created by dj jang on 2014. 11. 7..
//  Copyright (c) 2014년 dj jang. All rights reserved.
//

#import "IntroViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

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
    // Do any additional setup after loading the view from its nib.
    [self.navigationController.navigationBar setHidden:YES];
    
    [self nextMoveTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nextMoveTimer
{
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(moveMain)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)moveMain
{
//    MainViewController *viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
//    [self.navigationController pushViewController:viewController animated:NO];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate pushMainViewController];
}


@end
