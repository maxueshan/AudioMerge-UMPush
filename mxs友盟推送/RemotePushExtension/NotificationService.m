/*
 
mutable-content
 
 */
//  NotificationService.m
 /*
  当满足如下两个条件，应用收到远程推送时，应用会加载 extension 和调用 didReceiveNotificationRequest:withContentHandler:
  方法。
  
  远程通知的配置是展示 Alert
  The remote notification is configured to display an alert.
  
  注意：不能修改静默推送或推送内容是声音或者应用的角标
  
  远程推送的 aps 字典中，mutable-content : 1
  The remote notification’s aps dictionary includes the mutable-content key with the value set to 1.
  注意：不能修改静默推送或推送内容是声音或者应用的角标
  
  在 didReceiveNotificationRequest:withContentHandler: 里面可以处理远程推送内容，修改远程推送内容的时间是有限的。如果修改内容任务没有完成，系统会调用 serviceExtensionTimeWillExpire
  方法，给你提供最后一次提供修改内容的机会。如果你没有修改远程推送成功，系统将会展示远程推送最原始的内容。
  
  
  */
#import "NotificationService.h"
#import <AVFoundation/AVFoundation.h>
#import "Speaker.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

//这里是通知内容重写的方法
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    NSLog(@"-----进入通知 extension");
    self.contentHandler = contentHandler;
    //// copy发来的通知，开始做一些处理
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    //重写通知内容
    self.bestAttemptContent.title = @"extension:标题";
    self.bestAttemptContent.subtitle = @"extension:子标题";
    self.bestAttemptContent.body = @"extension:内容内容内容内容内容内容内容";
    
    [[Speaker speechcontroller]beginConversation:[NSString stringWithFormat:@"通知拦截成功"]];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.contentHandler(self.bestAttemptContent);
        
        
    });
    
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
