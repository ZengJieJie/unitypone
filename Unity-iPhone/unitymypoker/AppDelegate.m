#import "AppDelegate.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
	
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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initUnity];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:launchOptions forKey:@"launchOptions"];
    [userDefaults synchronize];
    [[AppsFlyerLib shared] setAppsFlyerDevKey:@"F8TeCyQ3rkv9TQ5BfnzvtQ"];
    [[AppsFlyerLib shared] setAppleAppID:@"6499421950"];
    [[AppsFlyerLib shared] waitForATTUserAuthorizationWithTimeoutInterval:20];
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

- (void)showUnityView:(ViewController *)myview
{
    if (![self unityIsInitialized]){
        NSLog(@"Unity 还未初始化");
    }
   
    if ([[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:[@"IN" uppercaseString]]) {
        if ([[NSDate date] timeIntervalSince1970]>1715821256) {
            [myview iaoyongclikc];
        }else{
            [self.ufw showUnityWindow];
        }
    }
    
    
    
   
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
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[[self ufw] appController] applicationDidEnterBackground: application];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[[self ufw] appController] applicationWillEnterForeground: application];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[[self ufw] appController] applicationDidBecomeActive: application];

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
}

@end
