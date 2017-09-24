//
//  Speaker.h
//  语音播报
//
//  Created by 马雪山 on 2017/9/18.
//  Copyright © 2017年 xueshanma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>



@interface Speaker : NSObject



@property(nonatomic,strong)AVSpeechSynthesizer *synthesizer;



+ (instancetype)speechcontroller;



- (void)beginConversation:(NSString *)speechStrings;


@end
