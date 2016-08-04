//
//  ParseOperation.m
//  DownloadImageFromNetwork
//
//  Created by X-Liang on 16/8/4.
//  Copyright © 2016年 X-Liang. All rights reserved.
//

#import "ParseOperation.h"
#import "AppModel.h"
// string contants found in the RSS feed
static NSString *kIDStr     = @"id";
static NSString *kNameStr   = @"im:name";
static NSString *kImageStr  = @"im:image";
static NSString *kArtistStr = @"im:artist";
static NSString *kEntryStr  = @"entry";

@interface ParseOperation ()<NSXMLParserDelegate>
@property (nonatomic, copy) NSArray *appModelList;
@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableArray *workingArray;
@property (nonatomic, strong) AppModel *workingEntry;   //
@property (nonatomic, strong) NSMutableString *workingPropertyString;
@property (nonatomic, strong) NSArray *elementsToParse;
@property (nonatomic, readwrite) BOOL stroingCharacterData;

@end

@implementation ParseOperation

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        _dataToParse = data;
        _elementsToParse = @[kIDStr, kNameStr, kImageStr, kArtistStr];
    }
    return self;
}

- (void)main {
    _workingArray = [NSMutableArray array];
    _workingPropertyString = [NSMutableString string];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.dataToParse];
    parser.delegate = self;
    if (!self.isCancelled) {
        
        // parse 调用代理时是在当前线程
        [parser parse];
        
        if (![self isCancelled]) {
            self.appModelList = [NSArray arrayWithArray:self.workingArray];
        }
    }
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
}

// -------------------------------------------------------------------------------
//	parser:didStartElement:namespaceURI:qualifiedName:attributes:
// -------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    // entry: { id (link), im:name (app name), im:image (variable height) }
    //
    if ([elementName isEqualToString:kEntryStr])
    {
        self.workingEntry = [[AppModel alloc] init];
    }
    self.stroingCharacterData = [self.elementsToParse containsObject:elementName];
}

// -------------------------------------------------------------------------------
//	parser:didEndElement:namespaceURI:qualifiedName:
// -------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (self.workingEntry != nil)
    {
        if (self.stroingCharacterData)
        {
            NSString *trimmedString =
            [self.workingPropertyString stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.workingPropertyString setString:@""];  // clear the string for next time
            if ([elementName isEqualToString:kIDStr])
            {
                self.workingEntry.appURLString = trimmedString;
            }
            else if ([elementName isEqualToString:kNameStr])
            {
                self.workingEntry.appName = trimmedString;
            }
            else if ([elementName isEqualToString:kImageStr])
            {
                self.workingEntry.imageURLString = trimmedString;
            }
            else if ([elementName isEqualToString:kArtistStr])
            {
                self.workingEntry.artist = trimmedString;
            }
        }
        else if ([elementName isEqualToString:kEntryStr])
        {
            [self.workingArray addObject:self.workingEntry];
            self.workingEntry = nil;
        }
    }
}

// -------------------------------------------------------------------------------
//	parser:foundCharacters:
// -------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.stroingCharacterData)
    {
        [self.workingPropertyString appendString:string];
    }
}

// -------------------------------------------------------------------------------
//	parser:parseErrorOccurred:
// -------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (self.errorHandler)
    {
        self.errorHandler(parseError);
    }
}

@end
