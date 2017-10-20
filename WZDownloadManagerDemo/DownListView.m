//
//  DownListView.m
//  WZDownloadManagerDemo
//
//  Created by wangzheng on 2017/10/20.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import "DownListView.h"
#import "DownListCell.h"
#import "WZDownloadManager.h"
NSString * const downloadURLString1 = @"http://yxfile.idealsee.com/9f6f64aca98f90b91d260555d3b41b97_mp4.mp4";
NSString * const downloadURLString2 = @"http://yxfile.idealsee.com/31f9a479a9c2189bb3ee6e5c581d2026_mp4.mp4";
NSString * const downloadURLString3 = @"http://yxfile.idealsee.com/d3c0d29eb68dd384cb37f0377b52840d_mp4.mp4";
NSString * const downloadURLString4 = @"http://baobab.wdjcdn.com/14564977406580.mp4";
NSString * const downloadURLString5 = @"http://baobab.wdjcdn.com/1442142801331138639111.mp4";


#define kDownloadURL1 [NSURL URLWithString:downloadURLString1]
#define kDownloadURL2 [NSURL URLWithString:downloadURLString2]
#define kDownloadURL3 [NSURL URLWithString:downloadURLString3]
#define kDownloadURL4 [NSURL URLWithString:downloadURLString4]
#define kDownloadURL5 [NSURL URLWithString:downloadURLString5]

@interface DownListView ()

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *downloadListArr;  // 支持添加  或者  删除

@end

@implementation DownListView

- (void)dealloc{
    NSLog(@"下载页面销毁");
}

- (NSMutableArray *)downloadListArr{
    if (!_downloadListArr) {
        _downloadListArr = [@[kDownloadURL1,kDownloadURL2,kDownloadURL3,kDownloadURL4,kDownloadURL5] mutableCopy];
    }
    return _downloadListArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark --- tableveiw delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.downloadListArr.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 87;
}
// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"DownListCell";
    DownListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSURL *URL = self.downloadListArr[indexPath.row];
    cell.url = URL;
    return cell;
}



@end
