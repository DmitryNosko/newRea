//
//  DBManager.m
//  RSSReader
//
//  Created by Dzmitry Noska on 9/13/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "DBManager.h"

@interface DBManager()
@end

static NSString* const dataBase = @"rssDataBase.db";

@implementation DBManager

static DBManager* shared;

+(instancetype) sharedDBManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [DBManager new];
    });
    return shared;
}

- (NSString *) dataBasePath {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"rssDataBase.db"];
}



@end
