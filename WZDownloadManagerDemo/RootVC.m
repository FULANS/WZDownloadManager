//
//  RootVC.m
//  WZDownloadManagerDemo
//
//  Created by wangzheng on 2017/10/16.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import "RootVC.h"
#import "DownListView.h"
#import "AppDelegate.h"

@import WebKit;
NSString * const downloadURLStringTest = @"http://yxfile.idealsee.com/9f6f64aca98f90b91d260555d3b41b97_mp4.mp4";

@interface RootVC ()<WKNavigationDelegate>

@property (strong, nonatomic) UILabel *lab;

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
 
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 300, 375, 200)];
    _webView.navigationDelegate = self;
    _webView.backgroundColor = [UIColor yellowColor];
    _webView.userInteractionEnabled = YES;
    [self.view addSubview:_webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:downloadURLStringTest]]];
    
    // 删除:
//    [[LKDownLoadManager sharedManager] deleteAllFiles];
    
    UIButton *start = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [start setTitle:@"开始下载" forState:(UIControlStateNormal)];
    start.frame = CGRectMake(0, 100, 100, 40);
    start.backgroundColor = [UIColor redColor];
    [start addTarget:self action:@selector(startAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:start];
    
    UIButton *pause = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [pause setTitle:@"暂停下载" forState:(UIControlStateNormal)];
    pause.frame = CGRectMake(0, 150, 100, 40);
    pause.backgroundColor = [UIColor redColor];
    [pause addTarget:self action:@selector(pauseAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:pause];
    
    self.lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 100, 30)];
    [self.view addSubview:self.lab];
    
}

- (void)startAction{
    
    
}


- (void)pauseAction{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
    UIStoryboard * SB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self.navigationController pushViewController:appDelegate.downVC
                                         animated:YES];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"完成");
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"文件加载失败");
    
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"失败");
}


@end
