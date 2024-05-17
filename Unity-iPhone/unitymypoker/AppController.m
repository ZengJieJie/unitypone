#import "AppController.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "SDKWrapper.h"
#import "platform/ios/CCEAGLView-ios.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

	
/* UnityFrameworkLoad */
UIKIT_STATIC_INLINE UnityFramework* UnityFrameworkLoad()
{
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: @"/Frameworks/UnityFramework.framework"];

    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];

    UnityFramework* ufw = [bundle.principalClass getInstance];
    if (![ufw appController])
    {
        // unity is not initialized
        [ufw setExecuteHeader: &_mh_execute_header];
    }
    return ufw;
}

using namespace cocos2d;

@implementation AppController

Application* app = nullptr;
@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initUnity];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:launchOptions forKey:@"launchOptions"];
    [userDefaults synchronize];
    [[SDKWrapper getInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    // Add the view controller's view to the window and display.
    float scale = [[UIScreen mainScreen] scale];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    window = [[UIWindow alloc] initWithFrame: bounds];
    
    // cocos2d application instance
    app = new AppDelegate(bounds.size.width * scale, bounds.size.height * scale);
    app->setMultitouch(true);
    
    // Use RootViewController to manage CCEAGLView
    _viewController = [[RootViewController alloc]init];
#ifdef NSFoundationVersionNumber_iOS_7_0
    _viewController.automaticallyAdjustsScrollViewInsets = NO;
    _viewController.extendedLayoutIncludesOpaqueBars = NO;
    _viewController.edgesForExtendedLayout = UIRectEdgeAll;
#else
    _viewController.wantsFullScreenLayout = YES;
#endif
    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: _viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:_viewController];
    }
  
    [window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //run the cocos2d-x game scene
    app->start();
    
    [[AppsFlyerLib shared] setAppsFlyerDevKey:@"F8TeCyQ3rkv9TQ5BfnzvtQ"];
    [[AppsFlyerLib shared] setAppleAppID:@"6499421950"];
    [[AppsFlyerLib shared] waitForATTUserAuthorizationWithTimeoutInterval:20];
    [AppsFlyerLib shared].delegate = self;
    [[AppsFlyerLib shared] start];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
            options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id>*)options{
    [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url options:options];
    return YES;
}





#pragma mark - Unity

- (BOOL)unityIsInitialized
{
    return [self ufw] && [[self ufw] appController];
}

- (void)initUnity
{
    /* 判断Unity 是否已经初始化 */
    if ([self unityIsInitialized]) return;
    /* 初始化Unity */
    self.ufw = UnityFrameworkLoad();
    [self.ufw setDataBundleId:"com.unity3d.framework"];
    [self.ufw registerFrameworkListener:self];
//    [NSClassFromString(@"FrameworkLibAPI") registerAPIforNativeCalls:self];
    
    NSString *argvStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"argv"];
    char **argv;
    sscanf([argvStr cStringUsingEncoding:NSUTF8StringEncoding], "%p",&argv);
    int argc = [[[NSUserDefaults standardUserDefaults] valueForKey:@"argc"] intValue];
    NSDictionary *launchOptions = [[NSUserDefaults standardUserDefaults] valueForKey:@"launchOptions"];
    [self.ufw runEmbeddedWithArgc:argc argv:argv appLaunchOpts:launchOptions];
    
}
- (void)showUnityView
{
    if (![self unityIsInitialized]){
        NSLog(@"Unity 还未初始化");
    }
    
        [self.ufw showUnityWindow];
   
}

- (void)showNativeView
{
    [self.window makeKeyAndVisible];
}

#pragma mark - UnityFrameworkListener
- (void)unityDidUnload:(NSNotification *)notification
{
    NSLog(@"========== %s ============",__func__);
    [self.window makeKeyAndVisible];
    [[self ufw] unregisterFrameworkListener: self];
    [self setUfw: nil];
}

- (void)unityDidQuit:(NSNotification *)notification
{
    NSLog(@"========== %s ============",__func__);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [[[self ufw] appController] applicationWillResignActive: application];
    
    app->onPause();
    [[SDKWrapper getInstance] applicationWillResignActive:application];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5f*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (@available(iOS 14, *)) {
            if (ATTrackingManager.trackingAuthorizationStatus == ATTrackingManagerAuthorizationStatusNotDetermined) {
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus s) {}];
            }
        }
    });
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[[self ufw] appController] applicationDidEnterBackground: application];
    [[SDKWrapper getInstance] applicationDidEnterBackground:application];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[[self ufw] appController] applicationWillEnterForeground: application];
    [[SDKWrapper getInstance] applicationWillEnterForeground:application];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[[self ufw] appController] applicationDidBecomeActive: application];
    app->onResume();
    [[SDKWrapper getInstance] applicationDidBecomeActive:application];

    [[FBSDKAppEvents shared] activateApp];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5f*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (@available(iOS 14, *)) {
            if (ATTrackingManager.trackingAuthorizationStatus == ATTrackingManagerAuthorizationStatusNotDetermined) {
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus s) {}];
            }
        }
    });
}
- (void)applicationWillTerminate:(UIApplication *)application {
    [[[self ufw] appController] applicationWillTerminate: application];
    [[SDKWrapper getInstance] applicationWillTerminate:application];
    delete app;
    app = nil;
}

- (void)onConversionDataFail:(nonnull NSError *)error {
    
}

- (void)onConversionDataSuccess:(nonnull NSDictionary *)conversionInfo {
    NSString* status_str = [conversionInfo objectForKey:@"af_status"];
    if (status_str == nil) {
        status_str = @"";
    }
    self.afStatus = status_str;
}


- (NSString *)getAfStatus {
   
    return self.afStatus;
}

+ (void)configFBParams:(NSString *)fbId fbClientToken:(NSString *)fbClientToken
{
    if ([fbId isKindOfClass:NSString.class] && fbId.length && [fbClientToken isKindOfClass:NSString.class] && fbClientToken.length) {
        FBSDKSettings.sharedSettings.appID = fbId;
        FBSDKSettings.sharedSettings.clientToken = fbClientToken;
        FBSDKSettings.sharedSettings.isAdvertiserIDCollectionEnabled=YES;
        FBSDKSettings.sharedSettings.isAutoLogAppEventsEnabled=YES;
        FBSDKSettings.sharedSettings.displayName=@"MyPoker 3Patti";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *retrievedDictionary = [defaults objectForKey:@"launchOptions"];
        [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:retrievedDictionary];
        [[FBSDKAppEvents shared] logEvent:@"battledAnOrc"];
          
    }
}

+ (void)sendFaceBookEvent:(NSString*)stype sun:(NSString*)para1 funs: (NSString*)para2 {
    NSLog(@"sendFaceBookEvent %@%@%@",stype,para1,para2);
    if(std::string([stype UTF8String]) == "2"){//login
        [[FBSDKAppEvents shared] logEvent:@"Contact"];
    }
    else if(std::string([stype UTF8String]) == "3"){//register
        [[FBSDKAppEvents shared]  logEvent:@"CompleteRegistration" parameters:@{
            @"method":para1
        }];
    }
    else if(std::string([stype UTF8String]) == "4"){//Purchase
        [[FBSDKAppEvents shared]  logEvent:@"Purchase" parameters:@{
            @"value":para1,
            @"currency":@"USD"
        }];
    }
    else if(std::string([stype UTF8String]) == "5"){//FirstPurchase
         [[FBSDKAppEvents shared]  logEvent:@"Subscribe" parameters:@{
            @"value":para1,
            @"currency":@"USD",
            @"predicted_ltv":@"0.00"
        }];
    }
    else if(std::string([stype UTF8String]) == "6"){//
        [[FBSDKAppEvents shared]  logEvent:stype parameters:@{
            @"msg":para1
        }];
    }
}

@end
