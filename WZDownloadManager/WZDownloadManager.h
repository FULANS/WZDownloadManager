//
//  WZDownloadManager.h
//  WZDownloadManagerDemo
//
//  Created by wangzheng on 17/2/7.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZDownloadModel.h"
@interface WZDownloadManager : NSObject

+ (instancetype)sharedManager;

- (void)download:(NSURL *)URL
           state:(void(^)(WZDownloadState state))state
        progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progress
      completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))completion;

- (BOOL)isCompleted:(NSURL *)URL;

// 获取文件的全路径
- (NSString *)fileFullPath:(NSURL *)URL;

- (CGFloat)progress:(NSURL *)URL;

- (void)deleteFile:(NSURL *)URL;

- (void)deleteAllFiles;


@end
