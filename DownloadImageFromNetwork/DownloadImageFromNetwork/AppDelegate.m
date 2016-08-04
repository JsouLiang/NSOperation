//
//  AppDelegate.m
//  DownloadImageFromNetwork
//
//  Created by X-Liang on 16/8/4.
//  Copyright © 2016年 X-Liang. All rights reserved.
//

#import "AppDelegate.h"
#import "ParseOperation.h"
#import "RootViewController.h"
/// 数据来源
static NSString *const TopPaidAppsFeed =
@"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml";

@interface AppDelegate ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) ParseOperation *parse;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:TopPaidAppsFeed]];
    
    NSURLSessionTask *sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                        if (error) {
                                                                            // 如果没有错误回到主队列进行操作
                                                                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection) {
                                                                                    // 未开启 HTTP 安全服务
                                                                                    abort();
                                                                                } else {
                                                                                    [self handleError:error];
                                                                                }
                                                                            }];
                                                                        } else {
                                                                            self.queue = [[NSOperationQueue alloc] init];
                                                                            _parse = [[ParseOperation alloc] initWithData:data];
                                                                            
                                                                            __weak AppDelegate *weakSelf = self;
                                                                            [self.parse setErrorHandler:^(NSError *error) {
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                    [weakSelf handleError:error];
                                                                                });
                                                                            }];
                                                                            
                                                                            __weak ParseOperation *weakParse = self.parse;
                                                                            [self.parse setCompletionBlock:^{
                                                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                if (weakSelf.parse.appModelList != nil) {
                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                        RootViewController *rotVc = (RootViewController *)[(UINavigationController *)weakSelf.window.rootViewController topViewController];
                                                                                        rotVc.entries = weakParse.appModelList;
                                                                                        [rotVc.tableView reloadData];
                                                                                    });
                                                                                }
                                                                                // ParseOperaion 操作结束
                                                                                weakSelf.queue = nil;
                                                                            }];
                                                                            
                                                                            // 这个操作将会开启 ParseOperation
                                                                            [self.queue addOperation:self.parse];
                                                                            
                                                                        }
                                                                    }];
    [sessionTask resume];
    
    return YES;
}

- (void)handleError:(NSError *)error {
    
}
@end
