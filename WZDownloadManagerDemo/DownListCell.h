//
//  DownListCell.h
//  WZDownloadManagerDemo
//
//  Created by wangzheng on 2017/10/20.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (weak, nonatomic) IBOutlet UILabel *currentSizeLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalSizeLabel;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;


@property (weak, nonatomic) IBOutlet UIProgressView *progress;


@property (copy, nonatomic) void (^downBlock)(DownListCell *cell);

@property (copy, nonatomic) void (^deleteBlock)(DownListCell *cell);

@property (strong, nonatomic) NSURL *url;

@end
