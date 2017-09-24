//
//  UMessageViewController.m
//  UMessageDemo
//
//  Created by 石乐 on 16/8/24.
//  Copyright © 2016年 石乐. All rights reserved.
//

#import "UMessageViewController.h"
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <CommonCrypto/CommonDigest.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif
#import "UMessage.h"
@interface UMessageViewController ()
@property (weak, nonatomic) IBOutlet UILabel *devicetoken;
@property (weak, nonatomic) IBOutlet UILabel *idfa;
@property (weak, nonatomic) IBOutlet UILabel *openudid;
@property (weak, nonatomic) IBOutlet UILabel *alert;
@property (weak, nonatomic) IBOutlet UILabel *sound;
@property (weak, nonatomic) IBOutlet UILabel *badge;

@property (weak, nonatomic) IBOutlet UITextView *userinfo;
@property (nonatomic,strong)  NSString* openUDID ;
@property (nonatomic,strong)  NSString *adId;
@end

@implementation UMessageViewController
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoNotification:) name:@"userInfoNotification" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [UMessage addCardMessageWithLabel:@"com.abc"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.devicetoken.text=[ud objectForKey:@"UMPDevicetoken"];
    self.idfa.text=[ud objectForKey:@"UMPIdfa"];
    self.openudid.text=[ud objectForKey:@"UMPOpenudid"];
    if ([[[UIDevice currentDevice] systemVersion]intValue]>=10) {
        
        
        if ([[ud objectForKey:@"UMPAlert"] isEqualToString:@"2"]) {
            self.alert.text=@"Enalbe";
        }else
        {
            self.alert.text=@"Disable";
        }
        if ([ [ud objectForKey:@"UMPSound"] isEqualToString:@"2"]) {
            self.sound.text=@"Enalbe";
        }else
        {
            self.sound.text=@"Disable";
        }
        if ([[ud objectForKey:@"UMPBadge"] isEqualToString:@"2"]) {
            self.badge.text=@"Enalbe";
        }else
        {
            self.badge.text=@"Disable";
        }
    }else
    {
        if ([[ud objectForKey:@"UMPAlert"] isEqualToString:@"4"]) {
            self.alert.text=@"Enalbe";
        }else
        {
            self.alert.text=@"Disable";
        }
        if ([[ud objectForKey:@"UMPSound"] isEqualToString:@"2"]) {
            self.sound.text=@"Enalbe";
        }else
        {
            self.sound.text=@"Disable";
        }
        if ([[ud objectForKey:@"UMPBadge"] isEqualToString:@"1"]) {
            self.badge.text=@"Enalbe";
        }else
        {
            self.badge.text=@"Disable";
        }
    }
    
}

-(void)userInfoNotification:(NSNotification*)notification{
    
    NSDictionary *nameDictionary = [notification userInfo];
    self.userinfo.text=[nameDictionary objectForKey:@"userinfo"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation

{
    
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    
}

- (BOOL)shouldAutorotate

{
    
    return YES;
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations

{
    
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
    
}

@end
