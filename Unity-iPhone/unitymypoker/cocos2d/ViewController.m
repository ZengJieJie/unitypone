#include "ViewController.h"
#import <Foundation/Foundation.h>
#import "AppController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CommonCrypto/CommonDigest.h"
#import "SAMKeychain.h"
#import "AppController.h"
#import "RootViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation ViewController


+ (void)setloadview {

    AppController *appDelegate = (AppController *)([UIApplication sharedApplication].delegate);
        [appDelegate showUnityView];
}

+ (NSString *)getAppsFlyer {
    NSString *adid = [Adjust adid];
    return adid;
}



+(NSString *)getDevice{
    NSString* pkgName = [[NSBundle mainBundle] bundleIdentifier];
    NSString* account = @"6483493695";
    NSString* imei = [SAMKeychain passwordForService:pkgName account:account];
    if (imei.length == 0) {
        CFUUIDRef uuidref = CFUUIDCreate(nil);
        CFStringRef uuidrefStr = CFUUIDCreateString(nil, uuidref);
        NSString* uuidStr = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidrefStr));
        CFRelease(uuidref);
        CFRelease(uuidrefStr);
        
        const char *uuidStr_str = [uuidStr UTF8String];
        unsigned char md5[CC_MD5_DIGEST_LENGTH];
        CC_MD5(uuidStr_str, (CC_LONG)strlen(uuidStr_str), md5);
        NSMutableString *mutable_str = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [mutable_str appendFormat:@"%02x", md5[i]];
        }
        imei = mutable_str;
        [SAMKeychain setPassword:imei forService:pkgName account:account];
       
    }
    return imei;
    
}


+ (void)Vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (NSString*)getPasteBoard {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    return pasteboard.string;
}

+ (NSInteger)getDeviceType {
  
    return [[UIDevice currentDevice] userInterfaceIdiom];
}


+ (NSString *)getCountryCode {
    NSString *countryCode = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] uppercaseString];
    return countryCode;
}

@end

