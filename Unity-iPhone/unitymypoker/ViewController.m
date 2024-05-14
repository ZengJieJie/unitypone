//
//  ViewController.m
//  unitymypoker
//
//  Created by feng ting on 2024/5/15.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "UIViewController+mypoker.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    [appDelegate showUnityView:self];
}
-(void)iaoyongclikc{
    [self logDevice];
}


@end
