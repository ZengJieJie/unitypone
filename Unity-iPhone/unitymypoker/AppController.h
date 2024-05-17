#import <UIKit/UIKit.h>
#include  <UnityFramework/UnityFramework.h>
#import "ViewController.h"

#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@class RootViewController;

@interface AppController : NSObject <UIApplicationDelegate,UnityFrameworkListener, AppsFlyerLibDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UnityFramework *ufw;
@property(nonatomic, readonly) RootViewController* viewController;
@property(nonatomic, strong) NSString* afStatus;
- (NSString*)getAfStatus;

- (void)showUnityView;

- (void)showNativeView;


@end




