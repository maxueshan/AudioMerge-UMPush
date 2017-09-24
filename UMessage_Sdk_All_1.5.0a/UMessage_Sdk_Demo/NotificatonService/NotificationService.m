//
//  NotificationService.m
//  NotificatonService
//
//  Created by 石乐 on 16/9/14.
//  Copyright © 2016年 石乐. All rights reserved.
/*
mutable-content
 
 */

#import "NotificationService.h"
#import <AVFoundation/AVFoundation.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

//test
@property (nonatomic,strong) NSString *filePath;

@property(nonatomic,strong)AVAudioPlayer *audioPlayer;


@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
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
    
    
//    [self playLocaVoiceClick];//固定
    
    [self moneyaudioMergeClick];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.contentHandler(self.bestAttemptContent);

    });
    
   
    
    
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
        NSLog(@"单个:%@",auidoPath);
        
        AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:auidoPath]];
        
        AVAssetTrack *audioAssetTrack1 = [[audioAsset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        CMTime current_time = audioAsset1.duration;
        [audioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, current_time) ofTrack:audioAssetTrack1 atTime:start_time error:nil];
        
        start_time = CMTimeAdd(start_time, current_time);
    }
    
    //输出路径
    NSString *outPutFilePath = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"xindong.m4a"];
    
    NSLog(@"最终路径:%@",outPutFilePath);
    
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
    NSString *amount = @"12";//12.01
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterSpellOutStyle;
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans"];
    NSNumber *num = [[[NSNumberFormatter alloc] init] numberFromString:amount];
    NSString *zh_num = [formatter stringFromNumber:num];
    
    
    return zh_num;
    
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



// 音频文件的ID
SystemSoundID ditaVoice;

//MARK:播放本地音频
- (void)playLocaVoiceClick{
    // 1. 定义要播放的音频文件的URL
//    NSURL *voiceURL = [[NSBundle mainBundle]URLForResource:@"6414" withExtension:@"mp3"];
    NSURL *voiceURL = [[NSBundle mainBundle]URLForResource:@"国付宝到账提醒" withExtension:@"mp3"];//可以播报, 注意资源路径

    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"国付宝到账提醒" ofType:@"mp3"];
    
    NSLog(@"play: %@",path);
    
    // 2. 注册音频文件（第一个参数是音频文件的URL 第二个参数是音频文件的SystemSoundID）
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(voiceURL),&ditaVoice);
    // 3. 为crash播放完成绑定回调函数
    //    AudioServicesAddSystemSoundCompletion(ditaVoice,NULL,NULL,(void*)completionCallback,NULL);
    //    AudioServicesAddSystemSoundCompletion(ditaVoice, NULL, NULL, NULL, NULL);
    // 4. 播放 ditaVoice 注册的音频 并控制手机震动
    //    AudioServicesPlayAlertSound(ditaVoice);
    //    AudioServicesPlaySystemSound(ditaVoice);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // 控制手机振动
    
    AudioServicesPlayAlertSoundWithCompletion(ditaVoice,^{AudioServicesDisposeSystemSoundID(ditaVoice);
        
        NSLog(@"播放完成");
        
    });
    
}



- (void)playAudio:(NSURL *)url
{
    // 传入地址
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    // 播放器
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    // 播放器layer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
//    playerLayer.frame = self.view.frame;
    // 视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加到imageview的layer上
//    [self.view.layer addSublayer:playerLayer];
    // 隐藏提示框 开始播放
    // 播放
    [player play];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}


@end

