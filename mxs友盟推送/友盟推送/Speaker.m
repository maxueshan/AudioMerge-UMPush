//
//  Speaker.m
//  语音播报
//
//  Created by 马雪山 on 2017/9/18.
//  Copyright © 2017年 xueshanma. All rights reserved.
//

#import "Speaker.h"

@interface Speaker ()



@property(nonatomic,strong)NSArray *voices;

@property(nonatomic,strong)NSArray *speechStrings;



@end



@implementation Speaker





+ (instancetype)speechcontroller{
    
    return [[self alloc]init];
    
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _synthesizer = [[AVSpeechSynthesizer alloc]init];

        　　　　　　//zh-CN 中文  en-US 英文
        
        _voices = @[[AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"],
                    
                    //                    [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"]
                    
                    ];
        
        
        
        _speechStrings = @[@"这是一个文本播报"];
        
    }
    
    return self;
    
}


- (void)beginConversation:(NSString *)speechStrings{
    
//    for (int i = 0; i<self.speechStrings.count; i++) {
    
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:speechStrings];
        
        utterance.voice = self.voices[0];//设置声音
        
        utterance.rate = 0.4f;//播放语音内容的速度
        
        utterance.pitchMultiplier = 0.7f;//语调
        
        utterance.postUtteranceDelay = 0.1f;//在说下一句话前的停顿时长
        
        //开始语音播放
        
        [self.synthesizer speakUtterance:utterance];
        
        
        
//    }
    
    
    
}
@end
