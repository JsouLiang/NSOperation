//
//  RootViewController.m
//  DownloadImageFromNetwork
//
//  Created by X-Liang on 16/8/4.
//  Copyright © 2016年 X-Liang. All rights reserved.
//

#import "RootViewController.h"
#import "AppModel.h"
#import "ImageDownloader.h"

#define kCustomRowCount 1

static NSString *CellIdentifier = @"LazyTableCell";
static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";

@interface RootViewController ()
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageDownloadsInProgress = [NSMutableDictionary dictionary];
}

/// 结束所有下载操作
- (void)terminateAllDonwloads {
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [self.imageDownloadsInProgress removeAllObjects];
}

- (void)dealloc {
    [self terminateAllDonwloads];
}

- (void)didReceiveMemoryWarning {
    [self terminateAllDonwloads];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = self.entries.count;
    if (count == 0) {
        return kCustomRowCount;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSUInteger nodeCount = self.entries.count;
    if (nodeCount == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        if (nodeCount > 0) {
            AppModel *model = (self.entries)[indexPath.row];
            cell.textLabel.text = model.appName;
            cell.detailTextLabel.text = model.artist;
            
            // 如果APP没有 下载图片, 则在用户没有滑动的时候进行下载
            if (!model.appIcon) {
                if (!self.tableView.dragging &&
                    !self.tableView.decelerating) {
                    [self startIconDownload:model forIndexPath:indexPath];
                }
                cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
            } else {
                cell.imageView.image = model.appIcon;
            }
        }
    }
    return cell;
}

/// 开启指定 cell 的图片下载操作
- (void)startIconDownload:(AppModel *)appRecord forIndexPath:(NSIndexPath *)indexPath {
    ImageDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (!iconDownloader) {
        iconDownloader = [[ImageDownloader alloc] init];
        iconDownloader.appModel = appRecord;
        [iconDownloader setCompletionHandler:^{
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.imageView.image = appRecord.appIcon;
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
        }];
        self.imageDownloadsInProgress[indexPath] = iconDownloader;
        [iconDownloader startDownload];
    }
}

/// 下载显示在界面上的 Cell 中的图片
- (void)loadImagesForOnScreenRows {
    if (self.entries.count > 0) {
        NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visibleRows) {
            AppModel *model = self.entries[indexPath.row];
            if (!model.appIcon) {
                [self startIconDownload:model forIndexPath:indexPath];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnScreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnScreenRows];
}

@end
