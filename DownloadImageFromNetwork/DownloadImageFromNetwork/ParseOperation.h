//
//  ParseOperation.h
//  DownloadImageFromNetwork
//
//  Created by X-Liang on 16/8/4.
//  Copyright © 2016年 X-Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseOperation : NSOperation

/// 当发生错误时调用
@property (nonatomic, copy) void(^errorHandler)(NSError *error);

/// 当输入的XML数据被解析成功后会转为 AppModel 对象并被加入到该数组中
/// 该数组只有当操作完成时才有效
@property (nonatomic, copy, readonly) NSArray *appModelList;

- (instancetype)initWithData:(NSData *)data;

@end
