//
//  ViewController.m
//  友盟推送
//
//  Created by 马雪山 on 2017/9/22.
//  Copyright © 2017年 xueshanma. All rights reserved.
//

#import "ViewController.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


#import <AVFoundation/AVFoundation.h>
//使用System Sound Services需要AudioToolbox框架的支持，需要导入其主头文件：
#import<AudioToolbox/AudioToolbox.h>


@interface ViewController ()


@property(nonatomic,strong)AVAudioPlayer *audioPlayer;

@property(nonatomic,copy)NSString *filePath;


@end

@implementation ViewController
// 音频文件的ID
SystemSoundID ditaVoice;

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    UIButton *localNotiBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 100, 200, 80)];
    [localNotiBtn setTitle:@"iOS10 本地通知" forState:UIControlStateNormal];
    localNotiBtn.backgroundColor = [UIColor grayColor];
    [localNotiBtn addTarget:self action:@selector(locoNotificationBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:localNotiBtn];
    
    UIButton *playVoicBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 220, 200, 80)];
    [playVoicBtn setTitle:@"AudioServices本地音频" forState:UIControlStateNormal];
    playVoicBtn.backgroundColor = [UIColor grayColor];
    [playVoicBtn addTarget:self action:@selector(playLocaVoiceClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playVoicBtn];

    UIButton *audioPlayer = [[UIButton alloc]initWithFrame:CGRectMake(50, 320, 200, 80)];
    [audioPlayer setTitle:@"audioPlayer本地音频" forState:UIControlStateNormal];
    audioPlayer.backgroundColor = [UIColor grayColor];
    [audioPlayer addTarget:self action:@selector(audioPlayerClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:audioPlayer];

    
    UIButton *audioMerge = [[UIButton alloc]initWithFrame:CGRectMake(50, 320, 200, 80)];
    [audioMerge setTitle:@"两段音频合成" forState:UIControlStateNormal];
    audioMerge.backgroundColor = [UIColor grayColor];
    [audioMerge addTarget:self action:@selector(audioMergeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:audioMerge];
    
    UIButton *moneyaudioMerge = [[UIButton alloc]initWithFrame:CGRectMake(50, 420, 200, 80)];
    [moneyaudioMerge setTitle:@"拼接金额音频文件" forState:UIControlStateNormal];
    moneyaudioMerge.backgroundColor = [UIColor grayColor];
    [moneyaudioMerge addTarget:self action:@selector(moneyaudioMergeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moneyaudioMerge];
    
    
    
    
}
//MARK: 拼接金额音频文件
- (void)moneyaudioMergeClick{
    NSArray *all_file = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"百",@"千",@"万",@"点",];

//    将金额转成中文后，可以对应到单独的语音文件，可以用NSArray 来存放需要用到的语音文件。
    NSString *moneyString = [self tranforNumberToString];
    NSLog(@"%@--%ld",moneyString,moneyString.length);
    
//    NSString *moneyString = @"一二点零一";//〇

    NSMutableArray *audio_file = [NSMutableArray array];
    for (int i = 0; i< moneyString.length; i++) {
        NSString *numStr = [moneyString substringWithRange:NSMakeRange(i, 1)];
        NSLog(@"拆分字符:%@",numStr);
        [audio_file addObject:numStr];
    }
    [audio_file addObject:@"元"];

    NSLog(@"音频文件数组:%@--%ld",audio_file,  audio_file.count);
    
    
    
    //轨道
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *audioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    
    CMTime start_time = kCMTimeZero;
    //遍历需要用到的语音文件，加入到合成的音轨中
    for(NSString *m_file in audio_file){
//        NSString *auidoPath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:m_file];
        
        NSString *auidoPath = [[NSBundle mainBundle]pathForResource:m_file ofType:@"mp3"];
        NSLog(@"%@",auidoPath);
        
        AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:auidoPath]];
        
        AVAssetTrack *audioAssetTrack1 = [[audioAsset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        CMTime current_time = audioAsset1.duration;
        [audioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, current_time) ofTrack:audioAssetTrack1 atTime:start_time error:nil];
        
        start_time = CMTimeAdd(start_time, current_time);
    }

    //输出路径
    NSString *outPutFilePath = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"xindong.m4a"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:nil];
    }
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    //写入路径中
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = AVFileTypeAppleM4A;
    [session exportAsynchronouslyWithCompletionHandler:^{
        if(session.status==AVAssetExportSessionStatusCompleted){
            //按照第一步的播放语音方法即可
            //播放后结束
            _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:outPutFilePath] error:nil];
           
            [_audioPlayer play];
            
        }
    }];
    
    
    
}
//如amount=12.30，按照中文读法，为“十二点三元”，我们需要把12.30转化成十二点三元
- (NSString *)tranforNumberToString{
    NSString *amount = @"111999.99";//12.01
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterSpellOutStyle;
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans"];
    NSNumber *num = [[[NSNumberFormatter alloc] init] numberFromString:amount];
    NSString *zh_num = [formatter stringFromNumber:num];
    
   
    return zh_num;
    
}


//MARK:两段音频拼接
- (void)audioMergeClick{
//1.获取本地音频素材
    NSString *audioPath1 = [[NSBundle mainBundle]pathForResource:@"一" ofType:@"mp3"];
    NSString *audioPath2 = [[NSBundle mainBundle]pathForResource:@"元" ofType:@"mp3"];
    AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath1]];
    AVURLAsset *audioAsset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath2]];
//2.创建两个音频轨道,并获取两个音频素材的轨道
    AVMutableComposition *composition = [AVMutableComposition composition];
    //音频轨道
    AVMutableCompositionTrack *audioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    AVMutableCompositionTrack *audioTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    //获取音频素材轨道
    AVAssetTrack *audioAssetTrack1 = [[audioAsset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *audioAssetTrack2 = [[audioAsset2 tracksWithMediaType:AVMediaTypeAudio]firstObject];
//3.将两段音频插入音轨文件,进行合并
    //音频合并- 插入音轨文件
    // `startTime`参数要设置为第一段音频的时长，即`audioAsset1.duration`, 表示将第二段音频插入到第一段音频的尾部。

    [audioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset1.duration) ofTrack:audioAssetTrack1 atTime:kCMTimeZero error:nil];
    [audioTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset2.duration) ofTrack:audioAssetTrack2 atTime:audioAsset1.duration error:nil];
//4. 导出合并后的音频文件
    //`presetName`要和之后的`session.outputFileType`相对应
    //音频文件目前只找到支持m4a 类型的
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    //删除最后一个目录,再拼接一个目录
    NSString *outPutFilePath = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"xindong.m4a"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:nil];
    }
    // 查看当前session支持的fileType类型
    NSLog(@"---%@",[session supportedFileTypes]);
    session.outputURL = [NSURL fileURLWithPath:self.filePath];
    session.outputFileType = AVFileTypeAppleM4A; //与上述的`present`相对应
    session.shouldOptimizeForNetworkUse = YES;   //优化网络
    [session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"合并成功----%@", outPutFilePath);
            _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:outPutFilePath] error:nil];
            [_audioPlayer play];
        } else {
            // 其他情况, 具体请看这里`AVAssetExportSessionStatus`.
        }
    }];
    
}

- (NSString *)filePath {
    if (!_filePath) {
        _filePath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        NSString *folderName = [_filePath stringByAppendingPathComponent:@"MergeAudio"];
        BOOL isCreateSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:folderName withIntermediateDirectories:YES attributes:nil error:nil];
        if (isCreateSuccess) _filePath = [folderName stringByAppendingPathComponent:@"xindong.m4a"];
    }
    return _filePath;
}

//MARK:audioPlayer播放本地音频
- (void)audioPlayerClick{
    
    NSError *error = nil;
    NSString *outPutFilePath = [[NSBundle mainBundle]pathForResource:@"一" ofType:@"mp3"];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:outPutFilePath] error:&error];
    if (error) {
        NSLog(@"-------%@",error);
    }
    [_audioPlayer play];
   
 
}

//MARK:播放本地音频
- (void)playLocaVoiceClick{
    // 1. 定义要播放的音频文件的URL
    NSURL *voiceURL = [[NSBundle mainBundle]URLForResource:@"unbelievable" withExtension:@"caf"];
    // 2. 注册音频文件（第一个参数是音频文件的URL 第二个参数是音频文件的SystemSoundID）
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(voiceURL),&ditaVoice);
    // 3. 为crash播放完成绑定回调函数
//    AudioServicesAddSystemSoundCompletion(ditaVoice,NULL,NULL,(void*)completionCallback,NULL);
//    AudioServicesAddSystemSoundCompletion(ditaVoice, NULL, NULL, NULL, NULL);
    // 4. 播放 ditaVoice 注册的音频 并控制手机震动
//    AudioServicesPlayAlertSound(ditaVoice);
    //    AudioServicesPlaySystemSound(ditaVoice);
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // 控制手机振动
    
AudioServicesPlayAlertSoundWithCompletion(ditaVoice,^{AudioServicesDisposeSystemSoundID(ditaVoice);
    
    NSLog(@"播放完成");
    
});
    
}


//MARK:本地通知
- (void)locoNotificationBtn {
    // 申请通知权限
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        // A Boolean value indicating whether authorization was granted. The value of this parameter is YES when authorization for the requested options was granted. The value is NO when authorization for one or more of the options is denied.
        if (granted) {
            
            // 1、创建通知内容，注：这里得用可变类型的UNMutableNotificationContent，否则内容的属性是只读的
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = @"标题";
            content.subtitle = @"子标题";
            content.body = @"消息内容内容内容内容内容内容内容";
             // app显示通知数量的角标
            content.badge = @(1);
            // 通知的提示声音，这里用的默认的声音
//            content.sound = [UNNotificationSound defaultSound];
            //自定义声音
            content.sound = [UNNotificationSound soundNamed:@"6414.mp3"];
            
            NSURL *imageUrl = [[NSBundle mainBundle] URLForResource:@"xintianjiayinhang" withExtension:@"png"];
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"imageIndetifier" URL:imageUrl options:nil error:nil];
            // 附件 可以是音频、图片、视频 这里是一张图片
            content.attachments = @[attachment];
            //通知下拉放大
            //content.launchImageName = @"xintianjiayinhang";
            // 标识符
            content.categoryIdentifier = @"categoryIndentifier";
            
// 2、创建通知触发
            /* 触发器分三种：
             UNTimeIntervalNotificationTrigger : 在一定时间后触发，如果设置重复的话，timeInterval不能小于60
             UNCalendarNotificationTrigger : 在某天某时触发，可重复
             UNLocationNotificationTrigger : 进入或离开某个地理区域时触发
             */
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:2 repeats:NO];
// 3、创建通知请求
            UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"KFGroupNotification" content:content trigger:trigger];
            
// 4、将请求加入通知中心
            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
                if (error == nil) {
                    NSLog(@"已成功加推送%@",notificationRequest.identifier);
                }
            }];
        }else{
            NSLog(@"用户点击不允许");
        }
        
    }];
  }


@end
