//
//  RSSParser.m
//  RSSReader
//
//  Created by Dzmitry Noska on 8/30/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "RSSParser.h"
#import <UIKit/UIKit.h>

@interface RSSParser () <NSXMLParserDelegate>
@property (strong, nonatomic) NSString* element;
@property (strong, nonatomic) FeedItem* feedItem;
@property (strong, nonatomic) NSXMLParser* parser;
@property (strong, nonatomic) NSURL* resourceURL;
@end

static NSString* PATTERN_FOR_VALIDATION = @"<\/?[A-Za-z]+[^>]*>";

@implementation RSSParser

#pragma mark - ParserMethods

- (void) rssParseWithURL:(NSURL*) url {
    self.resourceURL = url;
    
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [self.parser setDelegate:self];
    [self.parser setShouldResolveExternalEntities:NO];
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    NSThread* thread = [[NSThread alloc] initWithBlock:^{
        [self.parser parse];
    }];
    [thread start];
    
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
    self.element = elementName;
    if ([self.element isEqualToString:@"rss"]) {
        self.feedItem = [[FeedItem alloc] init];
    }
    if ([self.element isEqualToString:@"item"]) {
        self.feedItem = [[FeedItem alloc] init];
    } else if ([self.element isEqualToString:@"enclosure"]) {
        self.feedItem.imageURL = [attributeDict objectForKey:@"url"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        if (self.feedItem != nil) {
            self.feedItem.itemDescription = [self correctDescription:self.feedItem.itemDescription];
            self.feedItem.resourceURL = self.resourceURL;
            self.feedItemDownloadedHandler(self.feedItem);
        }
        self.feedItem = nil;
    }
}

- (NSMutableString*) correctDescription:(NSString *) string {
    NSRegularExpression* regularExpression = [NSRegularExpression regularExpressionWithPattern:PATTERN_FOR_VALIDATION
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
    string = [regularExpression stringByReplacingMatchesInString:string
                                                         options:0
                                                           range:NSMakeRange(0, [string length])
                                                    withTemplate:@""];
    return [string mutableCopy];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![trimmed isEqualToString:@"\n"]) {
        if ([self.element isEqualToString:@"title"]) {
            self.feedItem.itemTitle = string;
        } else if ([self.element isEqualToString:@"link"]) {
            [self.feedItem.link appendString:string];
        } else if ([self.element isEqualToString:@"pubDate"]) {
            self.feedItem.pubDate = [self convertStringToDate:string];
        } else if ([self.element isEqualToString:@"description"]) {
            [self.feedItem.itemDescription appendString:string];
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.parserDidEndDocumentHandler();
}

- (NSDate *) convertStringToDate:(NSString *) string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]]];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    return [dateFormatter dateFromString:string];
}

@end
