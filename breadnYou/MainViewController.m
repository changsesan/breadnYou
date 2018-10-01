//
//  MainViewController.m
//  FoodyUser
//
//  Created by dj jang on 2014. 11. 7..
//  Copyright (c) 2014년 dj jang. All rights reserved.
//

//#define kUrlMain                     @"http://t1.manse.kr/fooddiscovery2/index.html"
//#define kUrlMain                    @"http://mh.foody.kr"


//#define kUrlMain                    @"http://ma.dosoft.kr"
#define kUrlMain                        @"http://breadnyou.dosoft.kr"

//#define kUrlMain                    @"http://mha.foody.kr"
//#define kUrlMain                     @"http://www.naver.com"

#define kTagButtonAccommodation     100
#define kTagButtonReservation       200
#define kTagButtonSignIn            300

//#define TEST_USED_HTML  100000

#import "MainViewController.h"
#import "JsonProvider.h"

@interface MainViewController ()<UIWebViewDelegate>

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        cellHeight = 30.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController.interactivePopGestureRecognizer setEnabled:FALSE];
    
    [self setUserAgent];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    
    // 사이즈 스케일
    [self.webView setScalesPageToFit:YES];
    
    [self requestForURL:kUrlMain];
    
#ifdef TEST_USED_HTML
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testHtml" ofType:@"html" inDirectory:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    
    [self requestForURL:path];
    //    NSString *path = @"http://www.naver.com";
    //    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
#else
    [self requestForURL:kUrlMain];
#endif
    
#ifdef USE_WEB_SCROLL

#else
    [self initializeBottomMenu];
    [self initializeSliderViews];
    [self deviceOrientationChanged];
#endif
    
    UISwipeGestureRecognizer *swipeRightOrange = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToRightWithGestureRecognizer:)];
    swipeRightOrange.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightOrange];
    
    
    
//    NSString *login = [self getCookiesLogin];
//    NSString *userName =[self getCookiesLoginUserName];
//    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:login
//                                                  message:userName
//                                                 delegate:self
//                                        cancelButtonTitle:@"확인"
//                                        otherButtonTitles:@"취소", nil];
//    [alert show];
}

- (void)slideToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer{
    NSLog(@"slideToRightWithGestureRecognizer");
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"$('#leftmenu').trigger('open');"];
}


- (void)setUserAgent
{
    UIWebView* webview = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSLog(@"userAgent\t%@", userAgent);
    if (userAgent == nil || [userAgent isEqualToString:@""] )
    {
        userAgent = [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU %@ OS %@ like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile;",
                     [[UIDevice currentDevice] model],                                                            //모델(iPhone, iPad)
                     [[UIDevice currentDevice] model],                                                            //모델(iPhone, iPad)
                     [[UIDevice currentDevice] model]                                                             //모델(iPhone, iPad)
                     ];
    }
    
    NSString *uuID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pushToken = [defaults stringForKey:@"UD_TOKEN_ID"];
    
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *customUserAgent = [NSString stringWithFormat:@"HTTP_USER_AGENT=%@;os=ios;uuid=%@;appversion=%@;pushtoken=%@;",bundleId, uuID, appVersion, pushToken];
    //NSString *customUserAgent = [NSString stringWithFormat:@"os=%@;uuid=%@;appversion=%@;pushToken=%@;", device.model, uuID, appVersion, pushToken];
    NSLog(@"customUserAgent\t%@", customUserAgent);
    
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@;%@", userAgent, customUserAgent], @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *userAgent2 = [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSLog(@"userAgent 222222222222\t%@", userAgent2);
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    NSLog(@"%@", NSStringFromCGRect(bounds));
    _indicator.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    NSLog(@"%@", NSStringFromCGPoint(_indicator.center));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initButtomMenu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark  Rotation IOS6 이상
- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
    //    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self deviceOrientationChanged];
}

- (void)deviceOrientationChanged
{
    CGFloat screenY         = [[ScreenProvider sharedManager] screenY];
    CGFloat screenWidth     = [[ScreenProvider sharedManager] screenWidth];
    CGFloat screenHeight    = [[ScreenProvider sharedManager] screenHeight];
    CGFloat statusBarHeight = [[ScreenProvider sharedManager] statusBarHeight];
    
    UIDeviceOrientation o = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    if (UIDeviceOrientationIsPortrait(o))
    {
        cellHeight = (screenHeight-110.0f-40.0f)/8;
        //        self.bgIv.frame = CGRectMake(0, screenY, screenWidth, screenHeight);
        //
        //        UIImage *img = [UIImage imageNamed:@"img_help.png"];
        //        self.helpIv.frame = CGRectMake(-(img.size.width-screenWidth), screenY, img.size.width, img.size.height);
        
        self.shawdowView.frame = CGRectMake(0, screenY, screenWidth, screenHeight);
        
        
        if(IS_IPHONE_4)
        {
            self.sliderTableView.frame = CGRectMake(0, screenY+TITLE_MENU_HEIGHT, MAIN_SLIDER_MENU_WIDTH, screenHeight-TITLE_MENU_HEIGHT);
            
            self.menuWidth = self.sliderTableView.frame.size.width;
            self.outFrame = CGRectMake(-self.menuWidth, screenY+TITLE_MENU_HEIGHT, self.menuWidth, screenHeight-TITLE_MENU_HEIGHT);
            self.inFrame = CGRectMake (0, screenY+TITLE_MENU_HEIGHT, self.menuWidth, screenHeight-TITLE_MENU_HEIGHT);
        }
        else
        {
            self.sliderTableView.frame = CGRectMake(0, screenY+TITLE_MENU_HEIGHT, MAIN_SLIDER_MENU_WIDTH, screenHeight-TITLE_MENU_HEIGHT);
            
            self.menuWidth = self.sliderTableView.frame.size.width;
            self.outFrame = CGRectMake(-self.menuWidth, screenY+TITLE_MENU_HEIGHT, self.menuWidth, screenHeight-TITLE_MENU_HEIGHT);
            self.inFrame = CGRectMake (0, screenY+TITLE_MENU_HEIGHT, self.menuWidth, screenHeight-TITLE_MENU_HEIGHT);
        }
        
        if ([self.reqUrlString hasPrefix:@"http://shop0.dosoft.kr"] || [self.reqUrlString hasPrefix:@"http://www.dosoft.kr/WebUI_Mobile/"])
        {
            self.btnBottom4.hidden = YES;
        }
        else
        {
            NSString *isLogin = [self getCookiesLogin];
            if([isLogin isEqualToString:@"Y"])
            {
                //            btnWidth = screenWidth/3;
                self.btnBottom4.hidden = YES;
            }
            else
            {
                self.btnBottom4.hidden = NO;
            }
        }
        
        int btnWidth = screenWidth/4;
        self.btnBottom1.frame = CGRectMake(btnWidth*0, screenHeight-56, btnWidth, 56);
        self.btnBottom2.frame = CGRectMake(btnWidth*1, screenHeight-56, btnWidth, 56);
        self.btnBottom3.frame = CGRectMake(btnWidth*2, screenHeight-56, btnWidth, 56);
        self.btnBottom4.frame = CGRectMake(btnWidth*3, screenHeight-56, btnWidth, 56);
        
        if(isShowShoppingMall)
        {
            self.webView.frame = CGRectMake(0, statusBarHeight, screenWidth, screenHeight);
        }
        else
        {
            self.webView.frame = CGRectMake(0, statusBarHeight, screenWidth, screenHeight-56);
        }
    }
    else
    {
        //        NSLog(@"deviceOrientationChanged Land");
        
        self.shawdowView.frame = CGRectMake(0, screenY, screenWidth, screenHeight+statusBarHeight);
        
        self.sliderTableView.frame = CGRectMake(0, screenY+TITLE_MENU_HEIGHT, MAIN_SLIDER_MENU_WIDTH, screenHeight+statusBarHeight);
        
        self.menuWidth = self.sliderTableView.frame.size.width;
        self.outFrame = CGRectMake(-self.menuWidth, screenY+TITLE_MENU_HEIGHT, self.menuWidth, screenHeight+statusBarHeight);
        self.inFrame = CGRectMake (0, screenY+TITLE_MENU_HEIGHT, self.menuWidth, screenHeight+statusBarHeight);
        
        if ([self.reqUrlString hasPrefix:@"http://shop0.dosoft.kr"] || [self.reqUrlString hasPrefix:@"http://www.dosoft.kr/WebUI_Mobile/"])
        {
            self.btnBottom4.hidden = YES;
        }
        else
        {
            NSString *isLogin = [self getCookiesLogin];
            if([isLogin isEqualToString:@"Y"])
            {
                //            btnWidth = screenWidth/3;
                self.btnBottom4.hidden = YES;
            }
            else
            {
                self.btnBottom4.hidden = NO;
            }
        }
        
        int btnWidth = screenWidth/4;
        self.btnBottom1.frame = CGRectMake(btnWidth*0, screenHeight-56, btnWidth, 56);
        self.btnBottom2.frame = CGRectMake(btnWidth*1, screenHeight-56, btnWidth, 56);
        self.btnBottom3.frame = CGRectMake(btnWidth*2, screenHeight-56, btnWidth, 56);
        self.btnBottom4.frame = CGRectMake(btnWidth*3, screenHeight-56, btnWidth, 56);
        
        if(isShowShoppingMall)
        {
            self.webView.frame = CGRectMake(0, statusBarHeight, screenWidth, screenHeight-statusBarHeight);
        }
        else
        {
            self.webView.frame = CGRectMake(0, statusBarHeight, screenWidth, screenHeight-56-statusBarHeight);
        }
    }
    
    if(!self.isOpen)
    {
//        NSLog(@"Menu Hide +============>>>> ");
        
        //        CGRect hideRect = CGRectMake(-self.menuWidth, screenY+TITLE_HEIGHT, self.menuWidth, screenHeight-TITLE_HEIGHT);
        self.sliderTableView.frame = self.outFrame;
        self.isOpen = NO;
        self.shawdowView.hidden = YES;
    }
    
    //    NSLog(@"titleView = %@", NSStringFromCGRect(self.titleView.frame));
    //        NSLog(@"sliderTableView = %@", NSStringFromCGRect(self.sliderTableView.frame));
    //        NSLog(@"outFrame = %@", NSStringFromCGRect(self.outFrame));
    //        NSLog(@"inFrame = %@", NSStringFromCGRect(self.inFrame));
}


#pragma mark - private method
- (void)requestForURL:(NSString *)textUrl
{
    NSURL *url = [NSURL URLWithString:textUrl];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

/*
 - (IBAction)buttonTouchUp:(id)sender
 {
 NSInteger tag = [sender tag];
 
 switch (tag) {
 case kTagButtonAccommodation: {
 [self requestForURL:kUrlAccommodation];
 }
 break;
 case kTagButtonReservation: {
 [self requestForURL:kUrlReservation];
 }
 break;
 case kTagButtonSignIn: {
 [self requestForURL:kUrlSignIn];
 }
 break;
 default:
 break;
 }
 }
 */
#pragma mark - UIWebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad:webView");
    [_indicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad:webView");
    
    // UIWebView 사이즈에 페이지 너비 맞추기
//    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ", (int)webView.frame.size.width]];
    
    [_indicator stopAnimating];
    
    [self deviceOrientationChanged];
    [self initButtomMenu];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"webView:didFailLoadWithError");
    [_indicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSLog(@"request url : %@", [request URL]);
    
    NSString *userAgent2 = [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSLog(@"userAgent 222222222222\t%@", userAgent2);
    // 전체보기 메뉴 여부 체크
    if (![self webViewRequestProcess:request]) return NO;
    
    if (![self INIpayMobile:request]) return NO;
    
    return TRUE;
}

- (BOOL)webViewRequestProcess:(NSURLRequest *)request
{
    NSString *requestStr = [[request URL] absoluteString];
    self.reqUrlString = requestStr;
    NSLog(@"requestStr:%@", requestStr);
    
    //    NSString *parameterString = [request URL].parameterString;
    //    DLog(@"parameterString:%@", parameterString);
    
    if ([requestStr hasPrefix:@"http://shop0.dosoft.kr"] || [requestStr hasPrefix:@"http://www.dosoft.kr/WebUI_Mobile/"])
    {
        if(!self.btnBottom1.hidden)
        {
//            NSLog(@"쇼핑몰이 보인다.");
            isShowShoppingMall = YES;
            [self hiddenButtomMenu:YES];
            [self deviceOrientationChanged];
        }
        return YES;
    }
    else if ([requestStr hasPrefix:@"toapp:"])
    {
        // swipeMenu
        if ([requestStr hasPrefix:@"toapp:swipeMenu"])
        {
            [self drawerToggle];
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else if ([[[request URL] absoluteString] hasPrefix:@"jscallback://?"])
    {
        NSString *protocolPrefix = @"jscallback://?";
        NSString *urlStr = [[request URL] absoluteString];
        urlStr = [urlStr substringFromIndex:protocolPrefix.length];
        urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"urlStr = %@",urlStr);
        NSError *jsonError;
        NSDictionary *callInfo = [NSJSONSerialization
                                  JSONObjectWithData:[urlStr dataUsingEncoding:NSUTF8StringEncoding]
                                  options:kNilOptions
                                  error:&jsonError];
        NSLog(@"callInfo = %@",callInfo);
        
        if (jsonError != nil)
        {
            //call error callback function here
            NSLog(@"Error parsing JSON for the url %@",requestStr);
            return NO;
        }
        
        
        NSString *functionName = [callInfo objectForKey:@"functionname"];
        if (functionName == nil)
        {
            NSLog(@"Missing function name");
            return NO;
        }
        
        NSString *successCallback = [callInfo objectForKey:@"success"];
        NSString *errorCallback = [callInfo objectForKey:@"error"];
        NSArray *argsArray = [callInfo objectForKey:@"args"];
        [self callFunction:functionName withArgs:argsArray onSuccess:successCallback onError:errorCallback];
        
        return NO;
    }
    
    if(self.btnBottom1.hidden)
    {
//        NSLog(@"쇼핑몰이 안 보인다.");
        isShowShoppingMall = NO;
        [self hiddenButtomMenu:NO];
        [self deviceOrientationChanged];
    }
    return YES;
}

- (BOOL)INIpayMobile:(NSURLRequest *)request {
    
    //APP STORE URL 경우 openURL 함수를 통해 앱스토어 어플을 활성화 한다.
    NSString *requestStr = [[request URL] absoluteString];
    BOOL bAppStoreURL   = ([requestStr rangeOfString:@"phobos.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);
    BOOL bAppStoreURL2 = ([requestStr rangeOfString:@"itunes.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);
    if(bAppStoreURL || bAppStoreURL2) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    //안심 클릭 App 일 경우
    BOOL bansimClickApp = ([requestStr rangeOfString:@"ansimclick://" options:NSCaseInsensitiveSearch].location != NSNotFound);
    if(bansimClickApp) {
        NSURL *appURL = [NSURL URLWithString:requestStr];
        if([[UIApplication sharedApplication] canOpenURL:appURL]) {
            [[UIApplication sharedApplication] openURL:appURL];
        }
        else {
            NSString *alertMsg = @"카드사 공인인증 APP이 설치되어 있지 않습니다.\n페이지내의 설치하기 버튼을 터치 하여 주시기 바랍니다.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}

#pragma mark -
#pragma mark Init View
/*!
 @brief      View 및 Controller를 구성한다.
 @param
 @result
 */
- (void)initializeSliderViews
{
    self.isOpen = NO;
    
    // Add Shawdow and assign its gesture
    self.shawdowView = [[UIView alloc] initWithFrame:CGRectZero];
    self.shawdowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    self.shawdowView.hidden = YES;
    
    UITapGestureRecognizer *tapIt = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnShawdow:)];
    [self.shawdowView addGestureRecognizer:tapIt];
    self.shawdowView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.shawdowView];
    
    
    
    // Slider Table View
    CGFloat screenY         = [[ScreenProvider sharedManager] screenY];
    //    CGFloat screenWidth     = [[ScreenProvider sharedManager] screenWidth];
    CGFloat screenHeight    = [[ScreenProvider sharedManager] screenHeight];
    CGRect frame = CGRectMake(0, screenY+TITLE_MENU_HEIGHT, MAIN_SLIDER_MENU_WIDTH, screenHeight-TITLE_MENU_HEIGHT);
    
    self.sliderTableView = [[SKSTableView alloc] initWithFrame:frame];
    self.sliderTableView.dataSource = self;
    self.sliderTableView.delegate = self;
    self.sliderTableView.SKSTableViewDelegate = self;
    //    self.sliderTableView.alpha = 0.9;
    self.sliderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.sliderTableView.separatorColor = [UIColorProvider colorWithHexValue:@"bfbfbf"];
    
    //    [self.sliderTableView setContentInset:UIEdgeInsetsMake(5, 0.0f, 5, 0.0f)];
    //    self.sliderTableView.backgroundColor = [inset colorWithHexValue:@"034ea1"];
    UIImage *stretchImg = [[UIImage imageNamed:@"menu_bg.png"] stretchableImageWithLeftCapWidth:2/2 topCapHeight:13/2];
    
    //    UIImage *stretchImg = [[UIImage imageNamed:@"menu_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1,1,1,1) resizingMode:UIImageResizingModeStretch];
    
    //    self.sliderTableView.backgroundColor = [UIColor colorWithPatternImage:stretchImg];
    self.sliderTableView.backgroundColor = [UIColor whiteColor];//[UIColorProvider colorWithHexValue:@"eeeeee"];
    [self.sliderTableView setBackgroundView:[[UIImageView alloc] initWithImage:stretchImg]];
    [self.view addSubview:self.sliderTableView];
    
    // Gesture on self.view
    [self addPanGestureRecognizer];
    
}// MARK: View 및 Controller를 구성한다.

- (void)initializeBottomMenu
{
//    self.btnBottom1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnBottom1 addTarget:self action:@selector(clickButtonMenu:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.btnBottom1];
    
//    self.btnBottom2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnBottom2 addTarget:self action:@selector(clickButtonMenu:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.btnBottom2];
    
//    self.btnBottom3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnBottom3 addTarget:self action:@selector(clickButtonMenu:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.btnBottom3];
    
//    self.btnBottom4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnBottom4 addTarget:self action:@selector(clickButtonMenu:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.btnBottom4];
}

#pragma mark -
#pragma mark Menu Info

- (NSArray *)menuInfoArray
{
    NSArray *menu = nil;
    if (!menu)
    {
        menu = @[
                 @[
                     @[@"로그인 회원가입"],
                     @[@"회원가입하기"],
                     @[@"마이카드"],
                     
                     @[@"공지사항"],
                     @[@"이벤트조회"],
                     @[@"환경설정"]
                     /*
                     @[@"FOOD백과", @"원재료사전", @"아트동영상", @"아트디자인", @"샌드위치/커피", @"일본칵테일 음료", @"선물포장/제품포장", @"음식/집기상식"],
                     
                     @[@"건강정보"],
                     @[@"이벤트조회"],
                     @[@"쇼핑몰 바로가기"],
                     @[@"환경설정"],
                     @[@"커뮤니티", @"건의사항", @"공지사항", @"설문조사"]
                     ]
                      */
                      ]
                 ];
    }
    return menu;
}

- (NSArray *)menuMoveInfoArray
{
    NSArray *menu = nil;
    if (!menu)
    {
        menu = @[
                 @[
                     @[@"로그인 회원가입"],
                     @[@"http://breadnyou.dosoft.kr/join/join_1.asp"],
                     @[@"http://breadnyou.dosoft.kr/join/confirm_3.asp"],
                     
                     @[@"http://breadnyou.dosoft.kr/community/board/board_list.asp?b_type=BOARD10"],
                     @[@"http://breadnyou.dosoft.kr/community/board/board_list.asp?b_type=BOARD12"],
                     @[@"http://breadnyou.dosoft.kr/setting/setting.asp"]/*,
                     @[@"FOOD백과", @"http://breadnyou.dosoft.kr/food/dictionary.asp?food_menu=1", @"http://breadnyou.dosoft.kr/food/video.asp?food_menu=2", @"http://breadnyou.dosoft.kr/food/design_1.asp?food_menu=3", @"http://breadnyou.dosoft.kr/food/coffee.asp?food_menu=4", @"http://breadnyou.dosoft.kr/food/drink.asp?food_menu=7", @"http://breadnyou.dosoft.kr/food/pack_1.asp?food_menu=5", @"http://breadnyou.dosoft.kr/food/knowledge.asp?food_menu=6"],
                     
                     @[@"http://breadnyou.dosoft.kr/community/board/board_list.asp?b_type=BOARD11"],
                     @[@"http://breadnyou.dosoft.kr/community/board/board_list.asp?b_type=BOARD12"],
                     @[@"http://shop0.dosoft.kr/(X(1)S(mq0c02prvkvv20drlkovjk5e))/WebUI_MOBILE/Main/Main.aspx?AspxAutoDetectCookieSupport=1#:none"],
                     @[@"http://breadnyou.dosoft.kr/setting/setting.asp"],
                     @[@"커뮤니티", @"http://breadnyou.dosoft.kr/community/board/board_list.asp?b_type=BOARD13", @"http://breadnyou.dosoft.kr/community/board/board_list.asp?b_type=BOARD10", @"http://breadnyou.dosoft.kr/community/poll/poll.asp"]*/
                     ]
                 ];
    }
    return menu;
}


#pragma mark -
#pragma mark Slider Menu Show and Hide
- (void)drawerToggle
{
    if (!self.isOpen)
    {
        [self showSliderMenu];
    }else{
        [self hideSliderMenu];
    }
}

- (void)showSliderMenu
{
#ifdef USE_WEB_SCROLL
    return;
#endif
    
    [self dumpCookies:@"fg"];
    [self.sliderTableView reloadData];
    
    //    NSLog(@"open x=%f",self.menuView.center.x);
    float duration = MENU_DURATION/self.menuWidth*abs(self.sliderTableView.center.x)+MENU_DURATION/2; // y=mx+c
    
    // shawdow
    self.shawdowView.hidden = NO;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.shawdowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:SHAWDOW_ALPHA];
                     }
                     completion:nil];
    
    // drawer
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.sliderTableView.frame = self.inFrame;
                     }
                     completion:nil];
    
    self.isOpen= YES;
}

- (void)hideSliderMenu
{
#ifdef USE_WEB_SCROLL
    return;
#endif
    
    //    NSLog(@"close x=%f",self.menuView.center.x);
    float duration = MENU_DURATION/self.menuWidth*abs(self.sliderTableView.center.x)+MENU_DURATION/2; // y=mx+c
    
    // shawdow
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.shawdowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0f];
                     }
                     completion:^(BOOL finished){
                         self.shawdowView.hidden = YES;
                     }];
    
    // drawer
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.sliderTableView.frame = self.outFrame;
                     }
                     completion:nil];
    self.isOpen= NO;
}


#pragma mark - Pan GestureRecognizer
- (void)addPanGestureRecognizer {
    // Gesture on self.view
    if(!self.panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveDrawer:)];
        self.panGesture.maximumNumberOfTouches = 1;
        self.panGesture.minimumNumberOfTouches = 1;
    }
    [self.view addGestureRecognizer:self.panGesture];
}

- (void)removePanGestureRecognizer {
    if(self.panGesture) [self.view removeGestureRecognizer:self.panGesture];
}


#pragma mark - GestureRecognizer
- (void)tapOnShawdow:(UITapGestureRecognizer *)recognize {
    [self hideSliderMenu];
}

- (void)moveDrawer:(UIPanGestureRecognizer *)recognizer
{
    NSLog(@"moveDrawer");
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)recognizer velocityInView:self.view];
    //    NSLog(@"velocity x=%f",velocity.x);
    
    if([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateBegan) {
        //        NSLog(@"start");
        if ( velocity.x > MENU_TRIGGER_VELOCITY && !self.isOpen) {
            [self showSliderMenu];
        }else if (velocity.x < -MENU_TRIGGER_VELOCITY && self.isOpen) {
            [self hideSliderMenu];
        }
    }
    
    if([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateChanged) {
        //        NSLog(@"changing");
        float movingx = self.sliderTableView.center.x + translation.x;
        if ( movingx > -self.menuWidth/2 && movingx < self.menuWidth/2){
            
            self.sliderTableView.center = CGPointMake(movingx, self.sliderTableView.center.y);
            [recognizer setTranslation:CGPointMake(0,0) inView:self.view];
            
            float changingAlpha = SHAWDOW_ALPHA/self.menuWidth*movingx+SHAWDOW_ALPHA/2; // y=mx+c
            self.shawdowView.hidden = NO;
            self.shawdowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:changingAlpha];
        }
    }
    
    if([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateEnded) {
        //        NSLog(@"end");
        if (self.sliderTableView.center.x>0){
            [self showSliderMenu];
        }else if (self.sliderTableView.center.x<0){
            [self hideSliderMenu];
        }
    }
}


#pragma mark -
#pragma mark UITableViewDataSource
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//
//    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
//
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) return 110.0f;
    else if(indexPath.row == 1) return 40.0f;
    else {
        // 30
        return cellHeight;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self menuInfoArray] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self menuInfoArray][section] count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self menuInfoArray][indexPath.section][indexPath.row] count] - 1;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        return YES;
    }
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.sliderTableView)
    {
        static NSString *CellIdentifier = @"SKSTableViewCell";
        //        SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //
        //        if (!cell)
        SKSTableViewCell *cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if (indexPath.row == 6 || indexPath.row == 11) {
            cell.expandable = YES;
        }
        else {
            cell.expandable = NO;
        }
        
        /*
         if(indexPath.row > 1){
         UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(MAIN_SLIDER_MENU_WIDTH - 16, (cellHeight-(28/3))/2, 16/3, 28/3)];
         imgView.image = [UIImage imageNamed:@"left_menu_bg.gif"];
         [cell addSubview:imgView];
         }*/
        
        int height = 110.0f;
        int lineHeight = 2;
        if(indexPath.row == 0) height = 110.0f;
        else if(indexPath.row == 1) height = 40.0f;
        else {
            height = cellHeight;
            lineHeight = 1;
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, height-lineHeight, MAIN_SLIDER_MENU_WIDTH-16, lineHeight)];
        line.backgroundColor = [UIColorProvider colorWithHexValue:@"bfbfbf"];
        if(indexPath.row == 8 || indexPath.row == 9) {
        }
        else{
            [cell addSubview:line];
        }
        
        //        NSLog(@"[self menuInfoArray].count = %d", [[self menuInfoArray][0] count]);
        if(indexPath.row == 0)
        {
            CGRect frame = CGRectMake( 0, 30, MAIN_SLIDER_MENU_WIDTH/2, 46);
            NSString *login = [self getCookiesLogin];
            if(login && login.length > 0){
                //                [cell addSubview:[self createBtnWithFrame:frame imgName:@"left_logout.png" txt:@"로그아웃" action:@selector(btnLogout)]];
            }
            else{
                [cell addSubview:[self createBtnWithFrame:frame imgName:@"left_login.png" txt:@"로그인" action:@selector(btnLogout)]];
            }
            
            frame = CGRectMake( MAIN_SLIDER_MENU_WIDTH/2, 30, MAIN_SLIDER_MENU_WIDTH/2, 46);
            
            if(login && login.length > 0){
                [cell addSubview:[self createBtnWithFrame2:frame imgName:@"left_set.png" txt:@"환경설정" action:@selector(btnConfig)]];
            }
            else{
                [cell addSubview:[self createBtnWithFrame:frame imgName:@"left_member.png" txt:@"회원가입" action:@selector(btnTerms)]];
            }
            
            btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
            //            btnClose.backgroundColor = [UIColor yellowColor];
            btnClose.frame = CGRectMake( MAIN_SLIDER_MENU_WIDTH-30, 0, 30, 30);
            [btnClose setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
            [btnClose addTarget:self action:@selector(drawerToggle) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btnClose];
        }
        else
        {
            cell.textLabel.text = [self menuInfoArray][indexPath.section][indexPath.row][0];
            
            if(indexPath.row == 1)
            {
                cell.textLabel.font = [UIFont fontWithName:@"AppleGothic" size:14];
                cell.textLabel.textColor = [UIColor blackColor];
                
                NSString *login = [self getCookiesLogin];
                if(login && login.length > 0){
                    NSString *userName = @"";
                    if([self getCookiesLoginUserName].length > 0) userName = [NSString stringWithFormat:@"%@ 고객님", [self getCookiesLoginUserName]];
                    cell.textLabel.text = userName;
                }
            }
            /*
            else if(indexPath.row == [[self menuInfoArray][0] count]-3)
            {
                cell.backgroundColor = [UIColorProvider colorWithHexValue:@"a1a8ab"];
                //cell.backgroundColor = [UIColorProvider colorWithHexValue:@"000000"];
                cell.textLabel.font = [UIFont fontWithName:@"AppleGothic" size:12];
                cell.textLabel.textColor = [UIColor whiteColor];
            }
             */
            else
            {
                cell.textLabel.font = [UIFont fontWithName:@"AppleGothic" size:12];
                cell.textLabel.textColor = [UIColorProvider colorWithHexValue:@"9c9c9c"];
            }
            
            UIView *viwSelectedBackgroundView = [[UIView alloc] init];
            viwSelectedBackgroundView.backgroundColor = [UIColorProvider colorWithHexValue:@"ccddee"];
            cell.selectedBackgroundView = viwSelectedBackgroundView;
            
            
            /*
             static NSString *CellIdentifier = @"MainSliderMenuTableViewCell";
             MainSliderMenuTableViewCell *cell = (MainSliderMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
             if (cell == nil) {
             cell = [[MainSliderMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
             
             UIView *viwSelectedBackgroundView = [[UIView alloc] init];
             viwSelectedBackgroundView.backgroundColor = [UIColorProvider colorWithHexValue:@"034ea1"];
             cell.selectedBackgroundView = viwSelectedBackgroundView;
             }
             
             
             NSString *name = [[self menuInfoArray] objectAtIndex:indexPath.row] ;
             //        NSDictionary *device = [listShopDeviceArrays objectAtIndex:indexPath.row];
             
             //        NSString *dvcId = [device objectForKey:@"dvcId"];
             //        NSString *dvcNm = [device objectForKey:@"dvcNm"];
             //        NSString *connectionCode = [device objectForKey:@"connectionCode"];
             
             //        cell.textLabel.text = [NSString stringWithFormat:@"%@/%@ - [%@]", connectionCode, dvcNm, dvcId];
             //        cell.imageView.image = nil;//info[kSidebarCellImageKey];
             //
             //        if([connectionCode isEqualToString:@"01"]) cell.connectionStateIv.backgroundColor = [UIColor greenColor];
             //        else if([connectionCode isEqualToString:@"02"]) cell.connectionStateIv.backgroundColor = [UIColor redColor];
             //        else if([connectionCode isEqualToString:@"99"]) cell.connectionStateIv.backgroundColor = [UIColor grayColor];
             //
             
             //        [self menuInfoArray][indexPath.section][indexPath.row][0];
             
             [cell showDataWithName:[self menuInfoArray][indexPath.section][indexPath.row][0]];*/
        }
        //        cell.layoutMargins = UIEdgeInsetsZero;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"MainMenuTableViewCell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        return cell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    //    UIView *viwSelectedBackgroundView = [[UIView alloc] init];
    //    viwSelectedBackgroundView.backgroundColor = [UIColorProvider colorWithHexValue:@"bfbfbf"];
    //    cell.selectedBackgroundView = viwSelectedBackgroundView;
    //
    //    cell.backgroundColor = [UIColorProvider colorWithHexValue:@"f3f3f3"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self menuInfoArray][indexPath.section][indexPath.row][indexPath.subRow]];
    //    cell.textLabel.frame = CGRectMake(0, 0, 100, 25);
    //    cell.textLabel.backgroundColor = [UIColor redColor];
    //    cell.textLabel.text = @"ddd";
    //    cell.textLabel.font = [UIFont systemFontOfSize:10];
    //    cell.textLabel.textColor = [UIColorProvider colorWithHexValue:@"939393"];
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}



#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == self.sliderTableView)
    {
        return 0;
    }
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.sliderTableView){
        //    [self.CCKFNavDrawerDelegate CCKFNavDrawerSelection:[indexPath row]];
        //        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //        [self hideSliderMenu];
        
        //        NSLog(@"%d 그룹에 %d 번이 선택 되었다..", indexPath.section, indexPath.row);
        NSLog(@"1 Section: %d, Row:%d, Subrow:%d", indexPath.section, indexPath.row, indexPath.subRow);
        
        NSString *url = [NSString stringWithFormat:@"%@", [self menuMoveInfoArray][indexPath.section][indexPath.row][indexPath.subRow]];
        NSLog(@"url : %@", url);
        
        if (indexPath.row > 0){
            if (indexPath.row == 6 || indexPath.row == 11) {
            }
            else {
                [self requestForURL:url];
                [self hideSliderMenu];
            }
        }
    }
    else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"2 Section: %d, Row:%d, Subrow:%d", indexPath.section, indexPath.row, indexPath.subRow);
    
    NSString *url = [NSString stringWithFormat:@"%@", [self menuMoveInfoArray][indexPath.section][indexPath.row][indexPath.subRow]];
    NSLog(@"url : %@", url);
    
    //    if(indexPath.row == 4 || indexPath.row >= 7)
    {
        [self requestForURL:url];
        [self hideSliderMenu];
    }
}

- (void)AddShopInfo
{
    //    DLog(@"success response JSON:%@", operation.responseString);
    //    [delegate httpManagerDidSuccess:responseObject];
    
    //    NSDictionary *result = (NSDictionary *)responseObject;
    //    if(!result)
    //    {
    //        return;
    //    }
    
    //    self.shopInfoArrays = [NSMutableArray arrayWithCapacity:0];   //    self.shopInfoArrays = nil;
    //    if(self.shopInfoArrays) NSLog(@"count = %d", [self.shopInfoArrays count]);
    //
    //    // print
    //    if(self.shopInfoArrays && [self.shopInfoArrays count] > 0)
    //    {
    //        [self.shopInfoArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //            //            DLog(@"idx = %d", idx);
    //        }];
    //    }
    
    [self.sliderTableView reloadData];
    
}


#pragma mark - Actions

- (void)collapseSubrows
{
    [self.sliderTableView collapseCurrentlyExpandedIndexPaths];
}

- (void)refreshData
{
    NSArray *array = @[
                       @[
                           @[@"Section0_Row0", @"Row0_Subrow1",@"Row0_Subrow2"],
                           @[@"Section0_Row1", @"Row1_Subrow1", @"Row1_Subrow2", @"Row1_Subrow3", @"Row1_Subrow4", @"Row1_Subrow5", @"Row1_Subrow6", @"Row1_Subrow7", @"Row1_Subrow8", @"Row1_Subrow9", @"Row1_Subrow10", @"Row1_Subrow11", @"Row1_Subrow12"],
                           @[@"Section0_Row2"]
                           ]
                       ];
    [self reloadTableViewWithData:array];
    
    //    [self setDataManipulationButton:UIBarButtonSystemItemUndo];
}

- (void)undoData
{
    [self reloadTableViewWithData:nil];
    
    //    [self setDataManipulationButton:UIBarButtonSystemItemRefresh];
}

- (void)reloadTableViewWithData:(NSArray *)array
{
    //    self.contents = array;
    
    // Refresh data not scrolling
    //    [self.tableView refreshData];
    
    [self.sliderTableView refreshDataWithScrollingToIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
}


#pragma mark - Cookies
- (NSString *)getCookiesLogin
{
    NSString *value = @"";
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        if([[cookie name] isEqualToString:@"CookieForMobile"])
        {
            value = [cookie value];
            break;
        }
    }
    NSLog(@"Login : %@", value);
    return value;
}

- (NSString *)urlencode:(NSString *)ori
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[ori UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSString *)getCookiesLoginUserName
{
    NSString *value = @"";
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        NSString *cookieName = [[cookie name] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if([cookieName isEqualToString:@"CookieForMobile_name"])
        {
            value = [[cookie value] stringByReplacingPercentEscapesUsingEncoding:-2147481280];
            break;
        }
    }
    NSLog(@"LoginUserName : %@", value);
    return value;
}

- (void)dumpCookies:(NSString *)msgOrNil
{
    NSMutableString *cookieDescs = [[NSMutableString alloc] init];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        [cookieDescs appendString:[self cookieDescription:cookie]];
    }
    NSLog(@"------ [Cookie Dump: %@] ---------\n%@", msgOrNil, cookieDescs);
    NSLog(@"----------------------------------");
}

- (NSString *)cookieDescription:(NSHTTPCookie *)cookie
{
    NSMutableString *cDesc      = [[NSMutableString alloc] init];
    [cDesc appendString:@"[NSHTTPCookie]\n"];
    [cDesc appendFormat:@"  name            = %@\n",            [[cookie name] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

//    [cDesc appendFormat:@"  value1           = %@\n",            [[cookie value] stringByReplacingPercentEscapesUsingEncoding:0x80000000 + kCFStringEncodingDOSKorean]];
    [cDesc appendFormat:@"  value           = %@\n",            [[cookie value] stringByReplacingPercentEscapesUsingEncoding:-2147481280]];
    [cDesc appendFormat:@"  domain          = %@\n",            [cookie domain]];
    [cDesc appendFormat:@"  path            = %@\n",            [cookie path]];
    [cDesc appendFormat:@"  expiresDate     = %@\n",            [cookie expiresDate]];
    [cDesc appendFormat:@"  sessionOnly     = %d\n",            [cookie isSessionOnly]];
    [cDesc appendFormat:@"  secure          = %d\n",            [cookie isSecure]];
    [cDesc appendFormat:@"  comment         = %@\n",            [cookie comment]];
    [cDesc appendFormat:@"  commentURL      = %@\n",            [cookie commentURL]];
    [cDesc appendFormat:@"  version         = %d\n",            [cookie version]];
    
    //  [cDesc appendFormat:@"  portList        = %@\n",            [cookie portList]];
    //  [cDesc appendFormat:@"  properties      = %@\n",            [cookie properties]];
    
    return cDesc;
}


//UIImage *imageNormal = [UIImage imageNamed:@"icon_footer_01.png"];
//UIButton *btnLogout = [UIButton buttonWithType:UIButtonTypeCustom];
//btnLogout.frame = CGRectMake( 0, 0, MAIN_SLIDER_MENU_WIDTH/2, imageNormal.size.height );
//[btnLogout setImage:imageNormal forState:UIControlStateNormal];
//[cell addSubview:btnLogout];

#pragma mark -
#pragma mark UIButton Create
- (UIButton *)createBtnWithFrame:(CGRect)rect
                         imgName:(NSString*)imgName
                             txt:(NSString*)txt
                          action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.backgroundColor = [UIColorProvider colorWithHexValue:@"2e353f"];
    [btn setFrame:rect];
    
    //    UIImage *image = [UIImage imageNamed:imgName];
    
    if (txt) {
        [btn setTitle:txt forState:UIControlStateNormal & UIControlStateHighlighted];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        [btn setTitleColor:[MColor colorNamed:@"ffffff"] forState:UIControlStateHighlighted];
        //        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -image.size.width, 0.0, 0.0)];
        btn.titleLabel.backgroundColor =[UIColor clearColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:9];
    }
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 36, 36)];
    imgView.center = CGPointMake(btn.frame.size.width / 2, (btn.frame.size.height / 2));
    imgView.image = [UIImage imageNamed:imgName];
    [btn addSubview:imgView];
    
    CGSize imageSize = btn.imageView.frame.size;
    CGSize titleSize = btn.titleLabel.frame.size;
    btn.titleEdgeInsets = UIEdgeInsetsMake(0.0f,
                                           - imageSize.width,
                                           - (titleSize.height + 46),
                                           0.0f);
    
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIButton *)createBtnWithFrame2:(CGRect)rect
                         imgName:(NSString*)imgName
                             txt:(NSString*)txt
                          action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.backgroundColor = [UIColor redColor];
    [btn setFrame:rect];
    
    //    UIImage *image = [UIImage imageNamed:imgName];
    
    if (txt) {
        [btn setTitle:txt forState:UIControlStateNormal & UIControlStateHighlighted];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        [btn setTitleColor:[MColor colorNamed:@"ffffff"] forState:UIControlStateHighlighted];
        //        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -image.size.width, 0.0, 0.0)];
        btn.titleLabel.backgroundColor =[UIColor clearColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:10];
    }
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 56, 56)];
    imgView.center = CGPointMake(btn.frame.size.width / 2, (btn.frame.size.height / 2)+10);
    imgView.image = [UIImage imageNamed:imgName];
    [btn addSubview:imgView];
    
    CGSize imageSize = btn.imageView.frame.size;
    CGSize titleSize = btn.titleLabel.frame.size;
    btn.titleEdgeInsets = UIEdgeInsetsMake(0.0f,
                                           - imageSize.width,
                                           - (titleSize.height + 78),
                                           0.0f);
    
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma mark -
#pragma mark UIButton Action
- (void)btnLogout
{
    NSString *isLogin = [self getCookiesLogin];
    NSLog(@"isLogin = %@", isLogin);
    
    if([isLogin isEqualToString:@"Y"]) [self requestForURL:@"http://breadnyou.dosoft.kr/join/logout.asp"];
    else [self requestForURL:@"http://breadnyou.dosoft.kr/join/confirm_1.asp"];
    
    [self hideSliderMenu];
}

- (void)btnTerms
{
    [self requestForURL:@"http://breadnyou.dosoft.kr/join/join_1.asp"];
    [self hideSliderMenu];
}

- (void)btnConfig
{
    [self requestForURL:@"http://breadnyou.dosoft.kr/setting/setting.asp"];
    [self hideSliderMenu];
}


#pragma mark -
#pragma mark UIButton Image
- (void)initButtomMenu
{
    UIImage *imageNormal = [UIImage imageNamed:@"footer_icon1.gif"];
    UIImage *imageHighlighted = [UIImage imageNamed:@"footer_icon1_on.gif"];
    [self.btnBottom1 setImage:imageNormal forState:UIControlStateNormal];
    [self.btnBottom1 setImage:imageHighlighted forState:UIControlStateHighlighted];
    [self.btnBottom1 addTarget:self action:@selector(clickButtonMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnBottom1.layer setBorderWidth:0.5];
    [self.btnBottom1.layer setBorderColor:[[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0] CGColor]];

    imageNormal = [UIImage imageNamed:@"footer_icon2.gif"];
    imageHighlighted = [UIImage imageNamed:@"footer_icon2_on.gif"];
    [self.btnBottom2 setImage:imageNormal forState:UIControlStateNormal];
    [self.btnBottom2 setImage:imageHighlighted forState:UIControlStateHighlighted];
    [self.btnBottom2 addTarget:self action:@selector(clickButtonMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnBottom2.layer setBorderWidth:0.5];
    [self.btnBottom2.layer setBorderColor:[[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0] CGColor]];
    
    imageNormal = [UIImage imageNamed:@"footer_icon4.gif"];
    imageHighlighted = [UIImage imageNamed:@"footer_icon4_on.gif"];
    [self.btnBottom3 setImage:imageNormal forState:UIControlStateNormal];
    [self.btnBottom3 setImage:imageHighlighted forState:UIControlStateHighlighted];
    [self.btnBottom3 addTarget:self action:@selector(clickButtonMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnBottom3.layer setBorderWidth:0.5];
    [self.btnBottom3.layer setBorderColor:[[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0] CGColor]];
    
//    NSString *isLogin = [self getCookiesLogin];
//    if([isLogin isEqualToString:@"Y"])
//    {
//        imageNormal = [UIImage imageNamed:@"footer_icon6.gif"];
//        imageHighlighted = [UIImage imageNamed:@"footer_icon6_on.gif"];
//    }
//    else
//    {
        imageNormal = [UIImage imageNamed:@"footer_icon5.gif"];
        imageHighlighted = [UIImage imageNamed:@"footer_icon5_on.gif"];
//    }
    [self.btnBottom4 setImage:imageNormal forState:UIControlStateNormal];
    [self.btnBottom4 setImage:imageHighlighted forState:UIControlStateHighlighted];
    [self.btnBottom4 addTarget:self action:@selector(clickButtonMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnBottom4.layer setBorderWidth:0.5];
    [self.btnBottom4.layer setBorderColor:[[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0] CGColor]];
}

- (void)hiddenButtomMenu:(BOOL)isHidden
{
    [self.btnBottom1 setHidden:isHidden];
    [self.btnBottom2 setHidden:isHidden];
    [self.btnBottom3 setHidden:isHidden];
    [self.btnBottom4 setHidden:isHidden];
}

//- (void)updateLoginButtonImage
//{
//    NSString *isLogin = [self getCookiesLogin];
//    NSLog(@"isLogin = %@", isLogin);
//    UIImage *imageNormal = [UIImage imageNamed:@"footer_icon5.gif"];
//    UIImage *imageHighlighted = [UIImage imageNamed:@"footer_icon5_on.gif"];
//    if([isLogin isEqualToString:@"Y"])
//    {
//        imageNormal = [UIImage imageNamed:@"footer_icon6.gif"];
//        imageHighlighted = [UIImage imageNamed:@"footer_icon6_on.gif"];
//    }
//    [self.btnBottom4 setImage:imageNormal forState:UIControlStateNormal];
//    [self.btnBottom4 setImage:imageHighlighted forState:UIControlStateHighlighted];
//}

- (void)clickButtonMenu:(id)sender{
    NSString *url = @"";
    if(sender == self.btnBottom1)       url = @"http://breadnyou.dosoft.kr/";
    else if(sender == self.btnBottom2)  url = @"http://breadnyou.dosoft.kr/community/board/board_list.asp?b_type=BOARD10";
    else if(sender == self.btnBottom3)  url = @"http://breadnyou.dosoft.kr/setting/setting.asp";
    else if(sender == self.btnBottom4) {
        [self btnLogout];
        return;
    }
        
    [self requestForURL:url];
    [self hideSliderMenu];
}


#pragma mark -
#pragma mark JavaScript CallBack Function
- (void)callFunction:(NSString *)name withArgs:(NSArray *)args onSuccess:(NSString *)successCallback onError:(NSString *)errorCallback
{
    NSError *error;
    id retVal = [[JsonProvider sharedManager] makeJsonStringByTokenId];
    
    if (error != nil)
    {
        NSString *resultStr = [NSString stringWithString:error.localizedDescription];
        [self callErrorCallback:errorCallback withMessage:resultStr];
        return;
    }
    
    [self callSuccessCallback:successCallback withRetValue:retVal forFunction:name];
}

- (void)callErrorCallback:(NSString *)name withMessage:(NSString *)msg
{
    if (name != nil)
    {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);",name,msg]];
    }
    else
    {
        NSLog(@"%@",msg);
    }
}

- (void)callSuccessCallback:(NSString *)name withRetValue:(id)retValue forFunction:(NSString *)funcName
{
    if (name != nil)
    {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:retValue forKey:@"result"];
        [self callJSFunction:name withArgs:resultDict];
    }
    else
    {
        NSLog(@"Result of function %@ = %@", funcName,retValue);
    }
}

- (void)callJSFunction:(NSString *)name withArgs:(NSMutableDictionary *)args
{
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args options:0 error:&jsonError];
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from the response  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"jsonStr = %@", jsonStr);
    
    if (jsonStr == nil)
    {
        NSLog(@"jsonStr is null. count = %d", (int)[args count]);
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);",name,jsonStr]];
}

@end
