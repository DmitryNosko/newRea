//
//  FileFeedItemService.h
//  RSSReader
//
//  Created by USER on 9/16/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItemServiceProtocol.h"

@interface FileFeedItemService : NSObject <FeedItemServiceProtocol>
+(instancetype) sharedFileFeedItemService;
@end

