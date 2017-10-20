//
//  AppDelegate.h
//  WZDownloadManagerDemo
//
//  Created by wangzheng on 17/2/7.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownListView.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// (1)把 下载页面的vc 一直被持有 比较好 , 因为 如果downvc 被 dealloc 后 , 但 WZDownLoadManager 并没有被释放 , 所以对应的block 中的 vc 和 实际再次创建的vc 并不是 同一个 , 所以页面的刷新会存在问题!!!   (这种方法适用于 我例子中的情况 , 有一个具体的任务下载列表)
@property (strong, nonatomic) DownListView *downVC;


// 第二种解决方法 (适用于单个下载任务详情页) , 使用我 WZDownloadModel 中的属性 targetvc , 把对应下载的vc 传给downloadModel , 然后每次在调用 down 方法的时候 ,更新 targetvc

@end

