//
//  NavigationViewController.m
//  Limit
//
//  Created by Rix on 5/26/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "NavigationViewController.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController


// Disable auto rotate for all view controller after navigation view controller
- (BOOL)shouldAutorotate
{
    id currentViewController = self.topViewController;
    
    if ([currentViewController isKindOfClass:[UIViewController class]])
        return NO;
    
    return YES;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
