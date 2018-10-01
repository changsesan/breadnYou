//
//  MainViewController.h
//  FoodyUser
//
//  Created by dj jang on 2014. 11. 7..
//  Copyright (c) 2014년 dj jang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenProvider.h"
//#import "MainSliderMenuTableViewCell.h"
#import "SKSTableViewCell.h"
#import "UIColorProvider.h"
#import "SKSTableView.h"


#define TITLE_MENU_HEIGHT               0.0f
#define MAIN_SLIDER_MENU_WIDTH          220.0f
#define SHAWDOW_ALPHA                   0.5
#define MENU_DURATION                   0.3
#define MENU_TRIGGER_VELOCITY           350

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)

//#define USE_WEB_SCROLL              1000      전체보기 메뉴 자바스크립트 버전 일 경우

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SKSTableViewDelegate>
{
    BOOL isShowShoppingMall;
    
    CGFloat cellHeight;
    
    UIButton *btnClose;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

// Bottom Menu
@property (weak, nonatomic) IBOutlet UIButton *btnBottom1;
@property (weak, nonatomic) IBOutlet UIButton *btnBottom2;
@property (weak, nonatomic) IBOutlet UIButton *btnBottom3;
@property (weak, nonatomic) IBOutlet UIButton *btnBottom4;

@property (strong, nonatomic) NSString *reqUrlString;

// Slider
@property (nonatomic)           float               menuWidth;
@property (nonatomic)           BOOL                isOpen;
@property (nonatomic)           CGRect              outFrame;
@property (nonatomic)           CGRect              inFrame;
@property (strong, nonatomic)   UIView              *shawdowView;
@property (strong, nonatomic)   SKSTableView        *sliderTableView;
//@property (strong, nonatomic)   NSMutableArray      *shopInfoArrays;

@property (strong, nonatomic)   UIPanGestureRecognizer  *panGesture;


- (void)hideSignatureView;
- (void)setUserAgent;

@end
