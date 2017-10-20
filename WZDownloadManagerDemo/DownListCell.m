//
//  DownListCell.m
//  WZDownloadManagerDemo
//
//  Created by wangzheng on 2017/10/20.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import "DownListCell.h"
#import "WZDownloadManager.h"
@implementation DownListCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.downloadBtn addTarget:self action:@selector(download) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.deleteBtn addTarget:self action:@selector(delete) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.downloadBtn setTitle:@"Start" forState:UIControlStateNormal];

}

- (void)download{
    
    if ([self.downloadBtn.currentTitle isEqualToString:@"Start"]) {
    
        __weak typeof(self) wself = self;
        
        [[WZDownloadManager sharedManager] download:self.url destPath:nil state:^(WZDownloadState state) {
            
            [wself.downloadBtn setTitle:[wself titleWithDownloadState:state] forState:UIControlStateNormal];
            
        } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
            
            wself.currentSizeLabel.text = [NSString stringWithFormat:@"%zdMB", receivedSize / 1024 / 1024];
            wself.totalSizeLabel.text = [NSString stringWithFormat:@"%zdMB", expectedSize / 1024 / 1024];
            wself.progressLabel.text = [NSString stringWithFormat:@"%.f%%", progress * 100];
            wself.progress.progress = progress;
            
            NSLog(@"下载任务%@ -- %lf",wself.url , progress);
            
        } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
            
            if (isSuccess) {
                NSLog(@"FilePath: %@", filePath);
            } else {
                NSLog(@"Error: %@", error);
            }
            
        }];
    }else if ([self.downloadBtn.currentTitle isEqualToString:@"Waiting"]) {
        [[WZDownloadManager sharedManager] cancelDownloadOfURL:self.url];
    } else if ([self.downloadBtn.currentTitle isEqualToString:@"Pause"]) {
        [[WZDownloadManager sharedManager] suspendDownloadOfURL:self.url];
    } else if (self.downloadBtn) {
        [[WZDownloadManager sharedManager] resumeDownloadOfURL:self.url];
    } else if ([self.downloadBtn.currentTitle isEqualToString:@"Finish"]) {
        NSLog(@"File has been downloaded! It's path is: %@", [[WZDownloadManager sharedManager] fileFullPathOfURL:self.url]);
    }
 
}


- (void)delete{
    
    [[WZDownloadManager sharedManager] deleteFileOfURL:self.url];

    self.progress.progress = 0.0;
    self.currentSizeLabel.text = @"0";
    self.totalSizeLabel.text = @"0";
    self.progressLabel.text = @"0%";
    [self.downloadBtn setTitle:@"Start" forState:UIControlStateNormal];
}

- (void)setUrl:(NSURL *)url{
    _url = url;
    
    CGFloat progress = [[WZDownloadManager sharedManager] fileHasDownloadedProgressOfURL:url];
    self.progress.progress = progress;
    
    self.progressLabel.text = [NSString stringWithFormat:@"%.f%%", progress * 100];
    
}


- (NSString *)titleWithDownloadState:(WZDownloadState)state {
    
    switch (state) {
        case WZDownloadStateWaiting:
            return @"Waiting";
        case WZDownloadStateRunning:
            return @"Pause";
        case WZDownloadStateSuspended:
            return @"Resume";
        case WZDownloadStateCanceled:
            return @"Start";
        case WZDownloadStateCompleted:
            return @"Finish";
        case WZDownloadStateFailed:
            return @"Start";
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
