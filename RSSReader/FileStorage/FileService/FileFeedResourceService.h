//
//  FileFeedResourceService.h
//  RSSReader
//
//  Created by USER on 9/16/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedResourceServiceProtocol.h"

@interface FileFeedResourceService : NSObject <FeedResourceServiceProtocol>
+(instancetype) sharedFileFeedResourceService;
@end
