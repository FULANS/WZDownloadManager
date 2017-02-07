//
//  WZDownloadModel.h
//  WZDownloadManagerDemo
//
//  Created by wangzheng on 17/2/7.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WZDownloadState) {
    
    WZDownloadStateRunning = 0,
    WZDownloadStateSuspended,
    WZDownloadStateCompleted,
    WZDownloadStateFailed
};

@interface WZDownloadModel : NSObject

@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, assign) NSInteger totalLength;

@property (nonatomic, copy) void (^state)(WZDownloadState state);

@property (nonatomic, copy) void (^progress)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress);

@property (nonatomic, copy) void (^completion)(BOOL isSuccess, NSString *filePath, NSError *error);

- (void)closeOutputStream;

@end
