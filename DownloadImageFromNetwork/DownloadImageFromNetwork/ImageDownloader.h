//
//  ImageDownloader.h
//  DownloadImageFromNetwork
//
//  Created by X-Liang on 16/8/4.
//  Copyright © 2016年 X-Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppModel;
@interface ImageDownloader : NSObject

@property (nonatomic, strong) AppModel *appModel;

@property (nonatomic, copy) void (^completionHandler)();

- (void)startDownload;

- (void)cancelDownload;

@end
