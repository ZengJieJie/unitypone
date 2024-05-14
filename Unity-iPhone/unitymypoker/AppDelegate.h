#import <UIKit/UIKit.h>
#include  <UnityFramework/UnityFramework.h>
#import "ViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,UnityFrameworkListener>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UnityFramework *ufw;

- (void)showUnityView:(ViewController *) myview;

- (void)showNativeView;

@end
