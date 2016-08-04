//
//  ImageDownloader.m
//  DownloadImageFromNetwork
//
//  Created by X-Liang on 16/8/4.
//  Copyright © 2016年 X-Liang. All rights reserved.
//

#import "ImageDownloader.h"
#import "AppModel.h"
#define kAppIconSize 48
@interface ImageDownloader ()

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@end

@implementation ImageDownloader

- (void)startDownload {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.appModel.imageURLString]];
    _sessionDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                       completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                           if (error) {
                                                               if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection) {
                                                                   // 未开启 HTTP 安全服务
                                                                   abort();
                                                               }
                                                           }
                                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                               UIImage *image = [[UIImage alloc] initWithData:data];
                                                               if (image.size.width != kAppIconSize ||
                                                                   image.size.height != kAppIconSize) {
                                                                   CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
                                                                   UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.f);
                                                                   CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
                                                                   [image drawInRect:imageRect];
                                                                   self.appModel.appIcon = UIGraphicsGetImageFromCurrentImageContext();
                                                                   UIGraphicsEndImageContext();
                                                               } else {
                                                                   self.appModel.appIcon = image;
                                                               }
                                                               
                                                               if (self.completionHandler!= nil) {
                                                                   self.completionHandler();
                                                               }
                                                           }];
                                                           
                                                       }];
    [_sessionDataTask resume];
}

- (void)cancelDownload {
    // 取消任务
    [self.sessionDataTask cancel];
    // 将任务置空
    _sessionDataTask = nil;
}

@end
