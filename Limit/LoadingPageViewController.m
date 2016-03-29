//
//  LoadingPageViewController.m
//  Limit
//
//  Created by Rix Lai on 12/25/15.
//  Copyright © 2015 Rix. All rights reserved.
//

#import "LoadingPageViewController.h"

#define SPECIAL_COLOR [UIColor colorWithRed:39.0/255.0 green:179.0/255.0 blue:160.0/255.0 alpha:1]

@interface LoadingPageViewController()


@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation LoadingPageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"loader" ofType:@"gif"];
    
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    self.view.backgroundColor = SPECIAL_COLOR;
    
    [self.webView loadData:gif MIMEType:@"image/gif" textEncodingName:@"loader.gif" baseURL:url];
    
    self.webView.userInteractionEnabled = NO;
    
    
}
@end
