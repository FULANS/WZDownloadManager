//
//  WZDownloadModel.m
//  WZDownloadManagerDemo
//
//  Created by wangzheng on 17/2/7.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import "WZDownloadModel.h"

@implementation WZDownloadModel

- (void)closeOutputStream {
    if (_outputStream) {
        [_outputStream close];
        _outputStream = nil;
    }
}

@end
