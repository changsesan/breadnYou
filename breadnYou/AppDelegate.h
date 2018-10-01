//
//  AppDelegate.h
//  FoodyUser
//
//  Created by LimSH on 2015. 3. 9..
//  Copyright (c) 2015년 LimSH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Ackon/Ackon.h>
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ACKAckonManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController    *mainVC;

@property (nonatomic, strong) NSMutableSet *beaconAckons;
@property (nonatomic, strong) ACKBeaconAckon *beaconAckon;

@property (nonatomic, strong) UINavigationController *rootViewController;


- (void)pushMainViewController;

@end

