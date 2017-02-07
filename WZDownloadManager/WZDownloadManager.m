//
//  WZDownloadManager.m
//  WZDownloadManagerDemo
//
//  Created by wangzheng on 17/2/7.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import "WZDownloadManager.h"

#define WZCacheDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:NSStringFromClass([self class])]

#define WZFileName(URL) URL.lastPathComponent

#define WZFileFullPath(URL) [WZCacheDirectory stringByAppendingPathComponent:WZFileName(URL)]

static WZDownloadManager *downloadManager;

@interface WZDownloadManager () <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableDictionary *dataTasks;
@property (nonatomic, strong) NSMutableDictionary *downloadModels;

@end

@implementation WZDownloadManager

+(void)load {
    
    NSString *cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:NSStringFromClass([self class])];
    BOOL isDirectory = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory];
    if (!isExists || !isDirectory) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
}

#pragma mark --- lazy init
- (NSMutableDictionary *)dataTasks{
    if (!_dataTasks) {
        _dataTasks = [NSMutableDictionary dictionary];
    }
    return _dataTasks;
}

- (NSMutableDictionary *)downloadModels{
    if (!_downloadModels) {
        _downloadModels = [NSMutableDictionary dictionary];
    }
    return _downloadModels;
}


#pragma mark --- Singleton
+ (instancetype)sharedManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[WZDownloadManager alloc] init];
    });
    return downloadManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [super allocWithZone:zone];
    });
    return downloadManager;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    
    return downloadManager;
}


- (void)download:(NSURL *)URL
           state:(void(^)(WZDownloadState state))state
        progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progress
      completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))completion{
    
    if (!URL) {
        NSLog(@"url不存在");
        return;
    }
    
    if ([self isCompleted:URL]) {
        if (state) {
            state(WZDownloadStateCompleted);
        }
       
        return;
    }
    
    if ([self dataTask:URL]) {
        NSURLSessionDataTask *task = [self dataTask:URL];
        if (task.state == NSURLSessionTaskStateRunning) {
            [self pauseDownload:URL];
        } else {
            [self startDownload:URL];
        }
        return;
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-",(long long)[self URLHasDownloadedLength:URL]];
    [request setValue:range forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    NSUInteger taskIdentifier = arc4random() % 10000 + arc4random() % 10000;
    [task setValue:@(taskIdentifier) forKey:@"taskIdentifier"];
    self.dataTasks[WZFileName(URL)] = task;
    
    WZDownloadModel *downloadModel = [[WZDownloadModel alloc] init];
    downloadModel.URL = URL;
    downloadModel.state = state;
    downloadModel.progress = progress;
    downloadModel.completion = completion;
    downloadModel.outputStream = [NSOutputStream outputStreamToFileAtPath:WZFileFullPath(URL.absoluteString) append:YES];
    self.downloadModels[@(task.taskIdentifier).stringValue] = downloadModel;
    
    [self startDownload:URL];
}



#pragma mark --- NSURLSession delegate
// 已经接收到反应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    WZDownloadModel *downloadModel = self.downloadModels[@(dataTask.taskIdentifier).stringValue];
    if (!downloadModel) {
        return;
    }
    [downloadModel.outputStream open];
    
    NSInteger totalLength = response.expectedContentLength + [self URLHasDownloadedLength:downloadModel.URL];
    downloadModel.totalLength = totalLength;
    NSMutableDictionary *totalLengthDic = [NSMutableDictionary dictionaryWithContentsOfFile:[self filesTotalLengthPlistPath]] ?: [NSMutableDictionary dictionary];
    totalLengthDic[WZFileName(downloadModel.URL)] = @(totalLength);
    [totalLengthDic writeToFile:[self filesTotalLengthPlistPath] atomically:YES];
    completionHandler(NSURLSessionResponseAllow);
}

// 已经接受到数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    WZDownloadModel *downloadModel = self.downloadModels[@(dataTask.taskIdentifier).stringValue];
    if (!downloadModel) {
        return;
    }
    [downloadModel.outputStream write:data.bytes maxLength:data.length];
    if (downloadModel.progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSUInteger receivedSize = [self URLHasDownloadedLength:downloadModel.URL];
            NSUInteger expectedSize = downloadModel.totalLength;
            CGFloat progress = 1.0 * receivedSize / expectedSize;
            downloadModel.progress(receivedSize, expectedSize, progress);
        });
    }
    
    
}

// 已经完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    WZDownloadModel *downloadModel = self.downloadModels[@(task.taskIdentifier).stringValue];
    if (!downloadModel) {
        return;
    }
    [downloadModel closeOutputStream];
    
    [self.dataTasks removeObjectForKey:WZFileName(downloadModel.URL)];
    [self.downloadModels removeObjectForKey:@(task.taskIdentifier).stringValue];
    
    if (downloadModel.state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self isCompleted:downloadModel.URL]) {
                if (downloadModel.completion) {
                    downloadModel.completion(YES, [self fileFullPath:downloadModel.URL], error);
                }
                if (downloadModel.state) {
                    downloadModel.state(WZDownloadStateCompleted);
                }
            } else if (error) {
                if (downloadModel.completion) {
                    downloadModel.completion(NO, nil, error);
                }
                if (downloadModel.state) {
                    downloadModel.state(WZDownloadStateFailed);
                }
            }
        });
    }
}

#pragma mark --- Assist Methods
- (void)startDownload:(NSURL *)URL {
    
    NSURLSessionDataTask *task = [self dataTask:URL];
    if (!task) {
        return;
    }
    [task resume];
    
    WZDownloadModel *downloadModel = self.downloadModels[@(task.taskIdentifier).stringValue];
    
    if (!downloadModel) {
        return;
    }
    
    if (downloadModel.state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            downloadModel.state(WZDownloadStateRunning);
        });
    }
    
}

- (void)pauseDownload:(NSURL *)URL {
    NSURLSessionDataTask *task = [self dataTask:URL];
    if (!task) {
        return;
    }
    [task suspend];
    
    WZDownloadModel *downloadModel = self.downloadModels[@(task.taskIdentifier).stringValue];
    if (!downloadModel) {
        return;
    }
    if (downloadModel.state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            downloadModel.state(WZDownloadStateSuspended);
        });
    }
}

- (NSURLSessionDataTask *)dataTask:(NSURL *)URL {
    
    return self.dataTasks[WZFileName(URL)];
}

- (NSString *)filesTotalLengthPlistPath {
    
    return [WZCacheDirectory stringByAppendingPathComponent:@"FilesTotalLength.plist"];
}

- (NSInteger)totlaLength:(NSURL *)URL {
    
    NSDictionary *totalLengthDic = [NSDictionary dictionaryWithContentsOfFile:[self filesTotalLengthPlistPath]];
    if (!totalLengthDic) {
        return 0;
    }
    if (!totalLengthDic[WZFileName(URL)]) {
        return 0;
    }
    return [totalLengthDic[WZFileName(URL)] integerValue];
    
}

- (NSInteger)URLHasDownloadedLength:(NSURL *)URL {
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:WZFileFullPath(URL) error:nil];

    return [fileAttributes[NSFileSize] integerValue];
    
}

#pragma mark --- Public Methods
- (BOOL)isCompleted:(NSURL *)URL{

    if ([self totlaLength:URL] != 0) {
        if ([self totlaLength:URL] == [self URLHasDownloadedLength:URL]) {
            return YES;
        }
    }
    return NO;

}

- (NSString *)fileFullPath:(NSURL *)URL{
    
    return WZFileFullPath(URL);
}

- (CGFloat)progress:(NSURL *)URL{
    
    if ([self isCompleted:URL]) {
        return 1.0;
    }
    if ([self totlaLength:URL] == 0) {
        return 0.0;
    }
    return 1.0 * [self URLHasDownloadedLength:URL] / [self totlaLength:URL];
}

- (void)deleteFile:(NSURL *)URL{
    
    [self.dataTasks removeObjectForKey:WZFileName(URL)];
    [self.downloadModels removeObjectForKey:@([self dataTask:URL].taskIdentifier).stringValue];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:WZFileFullPath(URL)]) {
        return;
    }
    [fileManager removeItemAtPath:WZFileFullPath(URL) error:nil];
    NSMutableDictionary *totalLengthDic = [NSMutableDictionary dictionaryWithContentsOfFile:[self filesTotalLengthPlistPath]];
    [totalLengthDic removeObjectForKey:WZFileName(URL)];
    [totalLengthDic writeToFile:[self filesTotalLengthPlistPath] atomically:YES];
    
}

- (void)deleteAllFiles{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:WZCacheDirectory]) {
        return;
    }
    [fileManager removeItemAtPath:WZCacheDirectory error:nil];
    
    // Must create cache directory again or it will download fail if have not restart app.
    [fileManager createDirectoryAtPath:WZCacheDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    
    if ([fileManager fileExistsAtPath:[self filesTotalLengthPlistPath]]) {
        [fileManager removeItemAtPath:[self filesTotalLengthPlistPath] error:nil];
    }
    NSArray *dataTasks = [self.dataTasks allValues];
    [dataTasks makeObjectsPerformSelector:@selector(cancel)];
    [self.dataTasks removeAllObjects];
    
    for (WZDownloadModel *downloadModel in [self.downloadModels allValues]) {
        [downloadModel.outputStream close];
    }
    [self.downloadModels removeAllObjects];
    
    
}

@end
