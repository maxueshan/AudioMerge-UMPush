//
//  AppDelegate.m
//iOS通知详细介绍:   http://www.cocoachina.com/ios/20161017/17769.html

/*
 这里我们要注意一定要有"mutable-content": "1",
 以及一定要有Alert的字段，否则可能会拦截通知失败。（苹果文档说的）。
 除此之外，我们还可以添加自定义字段，比如，图片地址，图片类型
 
 */

#import "AppDelegate.h"
#import "ViewController.h"

#import "UMessage.h"
 #import <AVFoundation/AVFoundation.h>
#import "Speaker.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    _window.rootViewController = [ViewController new];
    [_window makeKeyAndVisible];
    
//MARK: 注册
    //设置 AppKey 及 LaunchOptions
    [UMessage startWithAppkey:@"59bfcd158f4a9d66b0000023" launchOptions:launchOptions httpsEnable:YES ];
    
    //是否开启开发模式，开发模式为YES。生产模式为NO，不调用默认为生产模式
    [UMessage openDebugMode:YES];
    //注册通知
    [UMessage registerForRemoteNotifications];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //iOS10特有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // 必须写代理，不然无法监听通知的接收与点击
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 点击允许
                NSLog(@"-50-注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@", settings);
                }];
            } else {
                // 点击不允许
                NSLog(@"注册失败");
            }
        }];
    }else if ([[UIDevice currentDevice].systemVersion floatValue] >8.0){
        //iOS8 - iOS10
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
        
    }else if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        //iOS8系统以下
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
        //打开日志，方便调试
    [UMessage setLogEnabled:YES];
    
    
    
    return YES;
}
//MARK: 前台收到通知
//iOS10新增：处理前台--收到通知--的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题

    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [UMessage setAutoAlert:NO];
        //应用处于前台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        NSLog(@"前台收到通知");
        //播报
        NSString *str = userInfo[@"aps"][@"alert"][@"body"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[Speaker speechcontroller]beginConversation:[NSString stringWithFormat:@"前台收到通知"]];

            
        });

        
    }else{
        //判断为本地通知
        
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
     
    }
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}
//MARK: 通知的点击事件
//iOS10新增：处理后台--点击通知--的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        NSLog(@"后台收到通知--点击:%@",userInfo);
        //播报
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[Speaker speechcontroller]beginConversation:@"点击通知方法"];

        });

        
    }else{
        //判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
        
       
    }
    
    // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler();  // 系统要求执行这个方法
    
}

//MARK: 不用点击,后台自动执行
/**
 *  当接收到远程通知时调用(iOS7.0之后使用)
 *
 *  当前在前台时; 或者app在后台\app被彻底退出状态下,点击通知打开app进入前台; 都可以执行以下方法
 *
 *
 * 执行completionHandler 作用
 *
 *      1> 系统会估量App消耗的电量，并根据传递的UIBackgroundFetchResult 参数记录新数据是否可用
 *      2> 调用完成的处理代码时，应用的界面缩略图会自动更新
 *
 * 如果想要接收到通知后,不要用户点击通知, 就执行以下代码, 那么必须有三个要求:
 
 1> 必须勾选后台模式Remote Notification ;
 2> 告诉系统是否有新的内容更新(执行完成代码块)
 3> 设置发送通知的格式("content-available":"1")
 4> 如果需要推送语音播报 则还需要在capabilities 中的background mode中勾选voice over ip 和 remote notifications，文章末尾有相关demo
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    //回调
    completionHandler(UIBackgroundFetchResultNewData);
    
    NSLog(@"iOS7及以上系统，收到通知:%@", userInfo);
    NSLog(@"fetchCompletionHandler方法执行%@", userInfo);
    
    //手机振动起来
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //播放语音
    NSString *str = userInfo[@"aps"][@"alert"][@"body"];
    [[Speaker speechcontroller]beginConversation:[NSString stringWithFormat:@"饭吃方法执行"]];
    
    
}
//iOS10以下使用这个方法接收通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //关闭友盟自带的弹出框
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    
    NSLog(@"iOS6及以下系统，收到通知:%@", userInfo);
    
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //1.2.7版本开始不需要用户再手动注册devicetoken，SDK会自动注册
    // [UMessage registerDeviceToken:deviceToken];
    NSLog(@"---%@",deviceToken);
    
    
}

// 获得Device Token失败
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"注册失败did Fail To Register For Remote Notifications With Error: %@", error);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
