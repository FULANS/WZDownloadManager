//
//  ViewController.h
//  WZDownloadManagerDemo
//
//  Created by wangzheng on 17/2/7.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import "ViewController.h"
#import "WZDownloadManager.h"

NSString * const downloadURLString1 = @"http://baobab.wdjcdn.com/14564977406580.mp4";
NSString * const downloadURLString2 = @"http://baobab.wdjcdn.com/1442142801331138639111.mp4";

#define kDownloadURL1 [NSURL URLWithString:downloadURLString1]
#define kDownloadURL2 [NSURL URLWithString:downloadURLString2]

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *downloadButton1;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton2;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView1;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView2;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel1;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel2;

@property (weak, nonatomic) IBOutlet UILabel *totalSizeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *totalSizeLabel2;

@property (weak, nonatomic) IBOutlet UILabel *currentSizeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *currentSizeLabel2;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGFloat progress1 = [[WZDownloadManager sharedManager] progress:kDownloadURL1];
    CGFloat progress2 = [[WZDownloadManager sharedManager] progress:kDownloadURL2];
    NSLog(@"progress of downloadURL1: %.2f", progress1);
    NSLog(@"progress of downloadURL2: %.2f", progress2);
    
    self.progressView1.progress = progress1;
    self.progressLabel1.text = [NSString stringWithFormat:@"%.f%%", progress1 * 100];
    [self.downloadButton1 setTitle:[self titleWithDownloadState:[self stateWithProgress:progress1]]
                          forState:UIControlStateNormal];
    
    self.progressView2.progress = progress2;
    self.progressLabel2.text = [NSString stringWithFormat:@"%.f%%", progress2 * 100];
    [self.downloadButton2 setTitle:[self titleWithDownloadState:[self stateWithProgress:progress2]]
                          forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if ([[WZDownloadManager sharedManager] isCompleted:kDownloadURL1]) {
        NSLog(@"%@", [[WZDownloadManager sharedManager] fileFullPath:kDownloadURL1]);
    }
    if ([[WZDownloadManager sharedManager] isCompleted:kDownloadURL2]) {
        NSLog(@"%@", [[WZDownloadManager sharedManager] fileFullPath:kDownloadURL2]);
    }
}

- (NSString *)titleWithDownloadState:(WZDownloadState)state {
    
    switch (state) {
        case WZDownloadStateRunning:
            return @"Pause";
        case WZDownloadStateSuspended:
            return @"Resume";
        case WZDownloadStateCompleted:
            return @"Finish";
        case WZDownloadStateFailed:
            return @"Start";
    }
}

- (WZDownloadState)stateWithProgress:(CGFloat)progress {
    
    WZDownloadState state;
    if (progress == 1.0) {
        state = WZDownloadStateCompleted;
    } else if (progress > 0) {
        state = WZDownloadStateSuspended;
    } else {
        state = WZDownloadStateFailed;
    }
    return state;
}

#pragma mark - Actions

- (IBAction)clearAllFiles:(id)sender {
    
    [[WZDownloadManager sharedManager] deleteAllFiles];
    
    self.progressView1.progress = 0.0;
    self.progressView2.progress = 0.0;
    self.currentSizeLabel1.text = @"0";
    self.currentSizeLabel2.text = @"0";
    self.totalSizeLabel1.text = @"0";
    self.totalSizeLabel2.text = @"0";
    self.progressLabel1.text = @"0%";
    self.progressLabel2.text = @"0%";
    [self.downloadButton1 setTitle:@"Start" forState:UIControlStateNormal];
    [self.downloadButton2 setTitle:@"Start" forState:UIControlStateNormal];
}

- (IBAction)downloadFile1:(UIButton *)sender {
    
    [self download:kDownloadURL1
    totalSizeLabel:self.totalSizeLabel1 currentSizeLabel:self.currentSizeLabel1
     progressLabel:self.progressLabel1 progressView:self.progressView1
            button:sender];
}

- (IBAction)downloadFile2:(UIButton *)sender {
    
    [self download:kDownloadURL2
    totalSizeLabel:self.totalSizeLabel2 currentSizeLabel:self.currentSizeLabel2
     progressLabel:self.progressLabel2 progressView:self.progressView2
            button:sender];
}

- (void)download:(NSURL *)URL totalSizeLabel:(UILabel *)totalSizeLabel currentSizeLabel:(UILabel *)currentSizeLabel
   progressLabel:(UILabel *)progressLabel progressView:(UIProgressView *)progressView
          button:(UIButton *)button
{
    
    [[WZDownloadManager sharedManager] download:URL state:^(WZDownloadState state) {
        
        
        [button setTitle:[self titleWithDownloadState:state] forState:UIControlStateNormal];
        
        if (state == WZDownloadStateCompleted) {
            NSLog(@"下载已经完成, 此时点击按钮可以实现播放功能");
            // 此时点击按钮可以实现播放功能
        }
        
        
        
        
    } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
        
        totalSizeLabel.text = [NSString stringWithFormat:@"%zdMB", expectedSize / 1024 / 1024];
        currentSizeLabel.text = [NSString stringWithFormat:@"%zdMB", receivedSize / 1024 / 1024];
        progressLabel.text = [NSString stringWithFormat:@"%.f%%", progress * 100];
        progressView.progress = progress;
        
        
    } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
        
        if (isSuccess) {
            NSLog(@"下载成功 \n %@", filePath);
            
            // 实现 已下载页面 的思路:
            /*
             1.通过button肯定能获取到对应的下载完成的数据model,通过fmdb或者其他缓存手段把model存入到本地,类似收藏,这样在 已下载页面 列表展示的时候和网络获取到的列表一样
             
             2.在已下载页面点击播放时,通过model的URL属性 找到本地对应存储文件的路径 ([[WZDownloadManager sharedManager] fileFullPath:URL]  方法), 播放之即可
             */
            
            
            
            
        } else {
            NSLog(@"下载失败 \n %@", error);
        }
  
    }];
}

- (IBAction)deleteFile1:(UIButton *)sender {
    
    [[WZDownloadManager sharedManager] deleteFile:kDownloadURL1];
    
    self.progressView1.progress = 0.0;
    self.currentSizeLabel1.text = @"0";
    self.totalSizeLabel1.text   = @"0";
    self.progressLabel1.text    = @"0%";
    [self.downloadButton1 setTitle:@"Start" forState:UIControlStateNormal];
}

- (IBAction)deleteFile2:(UIButton *)sender {
    
    [[WZDownloadManager sharedManager] deleteFile:kDownloadURL2];
    
    self.progressView2.progress = 0.0;
    self.currentSizeLabel2.text = @"0";
    self.totalSizeLabel2.text   = @"0";
    self.progressLabel2.text    = @"0%";
    [self.downloadButton2 setTitle:@"Start" forState:UIControlStateNormal];
}

@end
