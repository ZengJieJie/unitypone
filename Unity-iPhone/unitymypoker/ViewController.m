//
//  ViewController.m
//  unitymypoker
//
//  Created by feng ting on 2024/5/15.
//

#import "ViewController.h"
#import "AppDelegate.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    [appDelegate showUnityView:self];
}

-(void)viewDidAppear:(BOOL)animated{
   
}



@end
