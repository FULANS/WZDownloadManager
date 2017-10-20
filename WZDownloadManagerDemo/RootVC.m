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
@interface RootVC ()

@end

@implementation RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
