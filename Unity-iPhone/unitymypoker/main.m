//
//  main.m
//  unitymypoker
//
//  Created by feng ting on 2024/5/15.
//




#import <UIKit/UIKit.h>
#import "AppController.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(argc) forKey:@"argc"];
    [userDefaults synchronize];
    
    [userDefaults setObject:[NSString stringWithFormat:@"%p",argv] forKey:@"argv"];
    [userDefaults synchronize];
    
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppController class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
