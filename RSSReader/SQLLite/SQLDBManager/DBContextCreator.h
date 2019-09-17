//
//  DBContextCreator.h
//  RSSReader
//
//  Created by Dzmitry Noska on 9/13/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBContextCreator : NSObject {
    sqlite3* rssDataBase;
}
- (void) createDB;
@end
