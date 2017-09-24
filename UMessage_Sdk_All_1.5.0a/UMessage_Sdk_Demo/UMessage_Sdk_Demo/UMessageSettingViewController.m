//
//  UMessageAliasViewController.m
//  UMessageDemo
//
//  Created by 石乐 on 16/8/24.
//  Copyright © 2016年 石乐. All rights reserved.
//

#import "UMessageSettingViewController.h"
#import "UMessage.h"

@interface UMessageSettingViewController ()

@end

@implementation UMessageSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pushstate:(id)sender {
    UIButton *button=sender;
    if(button.selected){
        [UMessage registerForRemoteNotifications];
        
    }else{
        [UMessage unregisterForRemoteNotifications];
       
        
    }
    button.selected = !button.selected;
    
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
