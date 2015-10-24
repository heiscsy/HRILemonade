//
//  ViewController.m
//  testAudio
//
//  Created by Yuhan Long on 10/20/15.
//  Copyright © 2015 Yuhan Long. All rights reserved.
//

#import "ViewController.h"
#import "AQRecorder.h"
#include <iostream>
#include <deque>
#define THRESHOLD -30




@interface ViewController () {
    UIImageView *imageView_;
    AudioQueueLevelMeterState	*_chan_lvls;
    UInt32 data_sz;
    AQRecorder *recorder;
    UIImage *confuse;
    UIImage *smile;
    bool issmile;
    std::deque<bool> voiceOverThreshold;
}

-(void)refresh;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    
    imageView_.contentMode=UIViewContentModeScaleAspectFill;
    // 2. Important: add OpenCV_View as a subview
    [self.view addSubview:imageView_];
    

    
    //NSString *filePath =
    //[[NSBundle mainBundle] pathForResource:@"smile" ofType:@"png"];
   // NSURL *fileNameAndPath = [NSURL fileURLWithPath:filePath];
    
    
   // CIImage *smile = [CIImage imageWithContentsOfURL:fileNameAndPath];
    confuse = [UIImage imageNamed:@"confuse.png"];
    smile = [UIImage imageNamed:@"smile.png"];

   // UIImage *newImage = [UIImage imageWithCIImage:smile];

    //if (smile==nil) std::cout<<"error reading"<<std::endl;
    imageView_.image = confuse; // Display the image if it is there....
    
    
    AudioSessionInitialize(NULL,
                           NULL,
                           nil,
                           (__bridge  void *)(self)
                           );
    
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory
                            );
    
    AudioSessionSetActive(true);
    
    
    recorder = new AQRecorder();
    
    recorder->StartRecord(CFSTR("recordedFile.caf"));
    
    data_sz = sizeof(AudioQueueLevelMeterState) * 1;//[_channelNumbers count];
    
    
    UInt32 val = 1;
    XThrowIfError(AudioQueueSetProperty(recorder->Queue(), kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32)), "couldn't enable metering");
    
    _chan_lvls = (AudioQueueLevelMeterState*)malloc(1 * sizeof(AudioQueueLevelMeterState));
    
    
    
    NSTimer *_updateTimer = [NSTimer
                     scheduledTimerWithTimeInterval:0.1
                     target:self
                     selector:@selector(_refresh)
                     userInfo:self
                     repeats:YES
                     ];
    

    
    
    
    
}


- (void)_refresh
{

        OSErr status = AudioQueueGetProperty(recorder->Queue(), kAudioQueueProperty_CurrentLevelMeterDB, _chan_lvls, &data_sz);
       // std::cout<<_chan_lvls->mAveragePower<<std::endl;
         if (_chan_lvls->mAveragePower>THRESHOLD)
         {
             voiceOverThreshold.push_back(true);
             imageView_.image = smile;
             [imageView_ setNeedsDisplay];
         }
        else
        {
            voiceOverThreshold.push_back(false);
            //imageView_.image = confuse;
        }
    
        if (voiceOverThreshold.size()==20)
        {
            if(find(voiceOverThreshold.begin(),voiceOverThreshold.end(),true)!=voiceOverThreshold.end())
                imageView_.image = smile;
            else
                imageView_.image = confuse;
            
            [imageView_ setNeedsDisplay];

            voiceOverThreshold.clear();
        }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.a
}

@end
