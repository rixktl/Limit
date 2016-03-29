//
//  SettingViewController.m
//  Limit_beta
//
//  Created by Rix on 5/25/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *UnitLabel;
@property (weak, nonatomic) IBOutlet UIButton *OffsetLabel;

@end


@implementation SettingViewController

static NSString * const MPH = @"M P H";
static NSString * const KPH = @"K P H";


- (IBAction)DoneButton:(id)sender {
    // Go back to the original view by reverse direction(animation)
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)UnitChange:(id)sender {
    if([[Utility loadData:@"Unit"] isEqualToString:KPH]){
        [self.UnitLabel setTitle:MPH forState:UIControlStateNormal];
        [Utility saveData:@"Unit" withValue:MPH];
    }else{
        [self.UnitLabel setTitle:KPH forState:UIControlStateNormal];
        [Utility saveData:@"Unit" withValue:KPH];
    }
}



- (IBAction)OffsetChange:(id)sender {
    if([[Utility loadData:@"Exact"] isEqualToString:@"On"]){
        [self.OffsetLabel setTitle:@"Off" forState:UIControlStateNormal];
        [Utility saveData:@"Exact" withValue:@"Off"];
    }else{
        [self.OffsetLabel setTitle:@"On" forState:UIControlStateNormal];
        [Utility saveData:@"Exact" withValue:@"On"];
    }
}


- (void)loadDataToLabel{
    
    // For Unit
    if([Utility loadData:@"Unit"] != nil){
        [self.UnitLabel setTitle:[Utility loadData:@"Unit"] forState:UIControlStateNormal];
    }else{
        // Default
        [self.UnitLabel setTitle:MPH forState:UIControlStateNormal];
        [Utility saveData:@"Unit" withValue:MPH];
    }
    
    // For Limit offset(exact value)
    if([Utility loadData:@"Exact"]){
        [self.OffsetLabel setTitle:[Utility loadData:@"Exact"] forState:UIControlStateNormal];
    }else{
        // Default
        [self.OffsetLabel setTitle:@"Off" forState:UIControlStateNormal];
        [Utility saveData:@"Exact" withValue:@"Off"];
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadDataToLabel];
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
