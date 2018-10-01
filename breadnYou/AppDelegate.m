//
//  AppDelegate.m
//  FoodyUser
//
//  Created by LimSH on 2015. 3. 9..
//  Copyright (c) 2015년 LimSH. All rights reserved.
//

#import "AppDelegate.h"
#import "IntroViewController.h"
#import "MainViewController.h"


#define kTokenUploadUrl                     @"http://mm.foody.kr/include/gcm_reg.asp"
#define ID_APPSTORE                         @"975769075"

@interface AppDelegate ()

@end

@implementation AppDelegate

// 실행 중이 아닌 상태에서 노티를 받았을 때
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [self restoredCookie];
    
    NSURLSessionConfiguration *configObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    if(configObject.HTTPCookieAcceptPolicy != NSHTTPCookieAcceptPolicyAlways) {
        configObject.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    }
    
# if TARGET_IPHONE_SIMULATOR
    NSLog(@"시뮬레이터에서 실행");
//    [self addACKAckonManager:application didFinishLaunchingWithOptions:launchOptions];
//    [self startAckonManager];
# else
    NSLog(@"실제 단말에서 실행");
//    [self addACKAckonManager:application didFinishLaunchingWithOptions:launchOptions];
//    [self startAckonManager];
# endif
    
    // 어플리케이션이 실행되어있지 않은 경우 푸시를 받아서 어플리케이션이 실행될때 관련 정보가 launchOptions에 담겨오게 되며 그 정보를 가지고
    // didFinishLaunchingWithOptions를 재호출하는 로직
    // 어플리케이션 실행시 옵션사항 중 Push 서비스 관련 정보를 추
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo != nil){
//        [self application:application didFinishLaunchingWithOptions:userInfo];
        
        NSString *appName = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
        
        NSString *alertMsg = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appName message:alertMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
        [alert show];
    }
    
    [self regPushNotification];
    
    // Badge 개수 설정
    [self setApplicationBadgeNumber:0];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    IntroViewController *viewController = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
    self.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    self.window.rootViewController = self.rootViewController;
    
    [self.window makeKeyAndVisible];
    
    
    // update 후 적용 kiko
    //[self versionCheck];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:@"dfdfdfdfdfdf" forKey:@"UD_TOKEN_ID"];
//    [defaults synchronize];
    
    return YES;
}

- (void)pushMainViewController
{
     if(!self.mainVC) {
         self.mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
         self.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.mainVC];
         self.window.rootViewController = self.rootViewController;
        [self.mainVC setUserAgent];
     }
    //MainViewController *vc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
   
    [self.rootViewController.navigationBar setHidden:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [self setApplicationBadgeNumber:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self saveCookie];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark APNS Service
/**
 *	@brief APNS에 디바이스를 등록한다.
 *	@param
 *	@return
 *	@remark
 *	@see
 */
- (void)regPushNotification
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        // ios8
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    }
    else // ios7
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

#ifdef __IPHONE_8_0

- (BOOL)checkNotificationType:(UIUserNotificationType)type
{
    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    return (currentSettings.types & type);
}

#endif

- (void)setApplicationBadgeNumber:(NSInteger)badgeNumber
{
    UIApplication *application = [UIApplication sharedApplication];
    
#ifdef __IPHONE_8_0
    // compile with Xcode 6 or higher (iOS SDK >= 8.0)
    
    if(SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        application.applicationIconBadgeNumber = badgeNumber;
    }
    else
    {
        if ([self checkNotificationType:UIUserNotificationTypeBadge])
        {
            NSLog(@"badge number changed to %d", badgeNumber);
            application.applicationIconBadgeNumber = badgeNumber;
        }
        else
            NSLog(@"access denied for UIUserNotificationTypeBadge");
    }
    
#else
    // compile with Xcode 5 (iOS SDK < 8.0)
    application.applicationIconBadgeNumber = badgeNumber;
    
#endif
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

/**
 *	@brief 어플리케이션이 최초 실행될 때에 어플리케이션이 푸시서비스를 이용함을 알리고 허용할지를 물어보게 하고 사용자의 동의를 얻었을 경우 실행되는 메서드
 *	@param
 *	@return void
 *	@remark RemoteNotification 등록 성공. deviceToken을 수신
 *	@see
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Provider에게 DeviceToken 전송
//    NSLog(@"deviceToken : %@", deviceToken);
    NSLog(@"RemoteNotification 등록 성공");
    
    NSMutableString *deviceId = [NSMutableString string];
    const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
    for(int i = 0 ; i < 32 ; i++)
    {
        [deviceId appendFormat:@"%02x", ptr[i]];
    }
    NSLog(@"APNS Device Token: %@", deviceId);
  
    /*
    //  NSString* str = [[NSString alloc] initWith:deviceId encoding:NSUTF8StringEncoding];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"등록성공" message:deviceId delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alert show];
    
//    [self addCookieByToken:deviceId];
    */
    [self writeToTextFile:deviceId withPrefix:@"token"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceId forKey:@"UD_TOKEN_ID"];
    [defaults synchronize];
    
    
    if(!self.mainVC)
    {
        [self.mainVC setUserAgent];
    }
    
    // Token Upload
    //[self tokenUpload:deviceId];
    
    
}

// 파일 저장
- (void)writeToTextFile:(id)class withPrefix:(NSString *)prefix
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDateFormatter* df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@_%@.txt", documentsDirectory, [df stringFromDate:[NSDate date]], prefix];
    
    if([class isKindOfClass:[NSString class]]) {
        [class writeToFile:fileName
                atomically:NO
                  encoding:NSStringEncodingConversionAllowLossy
                     error:nil];
    }
    else if ([class isMemberOfClass:[NSDictionary class]])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:class
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        if (jsonData) {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [jsonString writeToFile:fileName
                         atomically:NO
                           encoding:NSStringEncodingConversionAllowLossy
                              error:nil];
        }
    }
    else{
        [class writeToFile:fileName atomically:YES];
    }
}

/**
 *	@brief APNS 에 RemoteNotification 등록 실패 실행되는 메서드
 *	@param
 *	@return void
 *	@remark
 *	@see
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"fail RemoteNotification Registration: %@", [error description]);
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"APNS 등록 실패" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
    //    [alert show];
}

/**
 *	@brief 실행 중이며 Foreground/Background 푸시 메시지를 받았을 경우 호출되는 메서드.
 *	@param
 *	@return void
 *	@remark
 *	@see
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (application.applicationState == UIApplicationStateActive)
    {
        // ....
    }
    else
    {
        // ....
    }
    
    NSLog(@"userInfo : %@", userInfo);
    
    [self setApplicationBadgeNumber:0];
    
    NSString *appName = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    
    NSString *alertMsg = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:appName message:alertMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
    [alert show];
}


#pragma mark -
#pragma mark Token Upload
/**
 *	@brief 토큰 업로드를 요청한다.
 *	@param NSString deviceId
 *	@return void
 *	@remark
 *	@see
 */
- (void)tokenUpload:(NSString *)deviceId
{
    NSString *url = [NSString stringWithFormat:kTokenUploadUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
# if TARGET_IPHONE_SIMULATOR
    NSLog(@"시뮬레이터에서 실행");
    deviceId = [NSString stringWithFormat:@"a62f32fe191602368efb27af7fead64a5ea374a2351850f6d9daf12771b3eeb4"];
# else
    NSLog(@"실제 단말에서 실행");
    NSLog(@"deviceId = %@", deviceId);
# endif
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *postParam = [NSString stringWithFormat:@"TelNum=01012345678&RegID=%@&Version=%@&Device=user&Device2=A",deviceId,version];
    
    NSData *postData = [postParam dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSLog(@"postData  = %@",postData);
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //    [request setValue:@"Mozilla/4.0 (compatible;)" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPBody:postData];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


#pragma mark -
#pragma mark NSMutableURLRequest
/**
 *	@brief HTML이 처리되고 난 뒤 얻는 데이터를 처리한다.
 *	@param
 *	@return void
 *	@remark
 *	@see
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
# if TARGET_IPHONE_SIMULATOR
    NSLog(@"시뮬레이터에서 실행");
# else
    NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"recieved : %@",returnString);
    
    //    UrlXmlHandler *handler = [[UrlXmlHandler alloc] init];
    //    NSString *str = [NSString stringWithFormat:@"%@,%@",strToken,[[handler parseLogin:returnString] retain]];
    //
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
    //    [alert show];
# endif
}

/**
 *	@brief NSURLConnection 이 종료되었을 때 호출된다.
 *	@param
 *	@return void
 *	@remark
 *	@see
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

/**
 *	@brief NSURLConnection 이 에러시 호출된다.
 *	@param
 *	@return void
 *	@remark
 *	@see
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connect error: %@", [error localizedDescription]);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


#pragma mark -
#pragma mark ACKAckonManager
- (void)addACKAckonManager:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ACKNotificationManager application:application didFinishLaunchingWithOptions:launchOptions];
    //CMS server URL 설정합니다.
    [ACKAckonManager setServerURL:[NSURL URLWithString:@"foodyc.manse.kr"]];
    //CMS 서버에서 발급받은 서비스 아이디를 입력합니다
    [ACKAckonManager setServiceIdentifier:@"ACK15030002"];
    //구입한 SerialNumber를 입력합니다.
    [ACKAckonManager setSerialNumber:@"GK6M-GA9M-JHM4"];
    [ACKAckonManager setUpdateTimeInterval:0];
    [ACKAckonManager setMinimumUpdateTimeInterval:30];
}

- (void)startAckonManager
{
    self.beaconAckons = [NSMutableSet new];
    
    [ACKAckonManager setDelegate:self];
    //유저의 위치정보 수집 동의 후 서버에 유저 등록을 합니다.
    //유저등록은 최초에만 필수 이며 초기화 이후 필요하지 않습니다.
    [ACKAckonManager requestEnabled:^(BOOL success, NSError *error) {
        if(success){
            [ACKAckonManager allAckonWithCompletionBlock:^(NSError *error, NSArray *result) {
                [ACKAckonManager startRanging];//Ranging을 시작합니다.
            }];
            
        }else{//실패시 알림
            [[[UIAlertView alloc] initWithTitle:@"실패" message:error.description delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark UIAckonManagerDelegate
- (void)ackonManager:(ACKAckonManager *)manager didRangeAckons:(NSArray *)ackons
{
    //수신된 비콘을  ackons에 차곡차곡 쌓습니다
    [self.beaconAckons addObjectsFromArray:ackons];
}

- (void)ackonManager:(ACKAckonManager *)manager didError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오류" message:error.description delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
    [alertView show];
}


#pragma mark Version Check
- (void) versionCheck
{
    NSString *strServerVersion = @"";
    NSString *strClientVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    NSString *storeString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", ID_APPSTORE];
    //NSString * storeString = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/apple-store/id%@?mt=8", ID_APPSTORE];
    
    NSURL *storeURL = [NSURL URLWithString:storeString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:storeURL];
    [request setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ( [data length] > 0 && !error ) {
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *versionsInAppStore = [[appData valueForKey:@"results"] valueForKey:@"version"];
                
                if ( ![versionsInAppStore count] ) { // No versions of app in AppStore
                    int k = 10;
                }
                else {
                    
                    //NSArray *serverVersionArray = [strServerVersion componentsSeparatedByString:@"."];
                    NSArray *serverVersionArray = [[versionsInAppStore objectAtIndex:0] componentsSeparatedByString:@"."];
                    NSArray *clientVersionArray = [strClientVersion componentsSeparatedByString:@"."];

                    if ([serverVersionArray count] == 3 || [clientVersionArray count] == 3)
                    {
                        for (int i = 0; i < 3; i++) {
                            
                            if ([[serverVersionArray objectAtIndex:i] intValue] > [[clientVersionArray objectAtIndex:i] intValue]) {
                                
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Version" message:@"서버에 새로운 애플리케이션이 있습니다.\n지금 다운로드 받으시겠습니까?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"아니오", @"예", nil, nil];
                                
                                [alert setTag:1234];
                                
                                [alert show];
                                
                                break;
                                
                            }
                            
                        }
                    }
                }
            });
        }
    }];
}

#pragma mark -
#pragma mark CookieStorage
- (void)saveCookie
{
    NSLog(@"%@", @"saveCookieStorage");
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"MySavedCookies"];
    NSLog(@"%@", @"PersisteWebCookie Saved");
}

- (void)restoredCookie
{
//    NSLog(@"%@", @"PersisteWebCookie");
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:@"MySavedCookies"];
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    NSLog(@"%@", @"PersisteWebCookie Restored");
}

- (void)addCookieByToken:(NSString*)token
{
//    if([self isExistTokenInfo])
//    {
//        NSLog(@"이미 저장된 토큰 정보가 있습니다.");
//        return;
//    }
//    [self deleteCookies];
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mh.foody.kr", NSHTTPCookieDomain,
                                @"\\", NSHTTPCookiePath,  // IMPORTANT!
                                @"tokenId", NSHTTPCookieName,
                                token, NSHTTPCookieValue,
                                @"2020-12-30 15:00:00 +0000", NSHTTPCookieExpires,
                                nil];
    
    NSHTTPCookie *cookie1 = [NSHTTPCookie cookieWithProperties:properties];
    NSArray* cookieArray = [NSArray arrayWithObjects: cookie1, nil];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookieArray forURL:[NSURL URLWithString:@"mm.foody.kr"] mainDocumentURL:nil];
    
    
    [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"Printing cookies %@", obj);
    }];
    
    [self dumpCookies:@"dd"];
}

- (BOOL)isExistTokenInfo
{
    BOOL isFind = NO;
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        NSString *cookieName = [[cookie name] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if([cookieName isEqualToString:@"tokenId"])
        {
            isFind = YES;
            break;
        }
    }
    NSLog(@"isFind : %d", isFind);
    return isFind;
}

- (void)deleteCookies
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        NSString *cookieName = [[cookie name] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if([cookieName isEqualToString:@"tokenId"])
        {
            [storage deleteCookie:cookie];
            break;
        }
    }
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


@end
