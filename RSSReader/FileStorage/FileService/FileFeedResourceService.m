//
//  FileFeedResourceService.m
//  RSSReader
//
//  Created by USER on 9/16/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "FileFeedResourceService.h"
#import "FileFeedResourceRepository.h"

@interface FileFeedResourceService ()
@property (strong, nonatomic) FileFeedResourceRepository* fileFeedResourceRepository;
@end

static NSString* const MENU_FILE_NAME = @"MainMenuFile.txt";

@implementation FileFeedResourceService

static FileFeedResourceService* shared;

+(instancetype) sharedFileFeedResourceService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [FileFeedResourceService new];
        shared.fileFeedResourceRepository = [FileFeedResourceRepository sharedFileFeedResourceRepository];
    });
    return shared;
}

- (FeedResource *) addFeedResource:(FeedResource *) resource {
    [self.fileFeedResourceRepository saveFeedResource:resource toFileWithName:MENU_FILE_NAME];
    return resource;
}

- (void) removeFeedResource:(FeedResource *) resource {
    [self.fileFeedResourceRepository removeFeedResource:resource fromFile:MENU_FILE_NAME];
}

- (NSMutableArray<FeedResource *>*) feedResources {
    return [self.fileFeedResourceRepository feedResources:MENU_FILE_NAME];
}

- (FeedResource *) resourceByURL:(NSURL *) url {
    
    NSMutableArray<FeedResource *>* resources = [self.fileFeedResourceRepository feedResources:MENU_FILE_NAME];
    FeedResource* res = nil;
    for (FeedResource* resource in resources) {
        if ([resource.url.absoluteString isEqualToString:url.absoluteString]) {
            res = resource;
        }
    }
//    NSUInteger index = [resources indexOfObjectPassingTest:^BOOL(FeedResource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if([obj.url.absoluteString isEqual:url.absoluteString]) {
//            *stop = YES;
//            return YES;
//        } else {
//            return NO;
//        }
//    }];
//    NSLog(@"index = %@", @(index));
//    return [resources objectAtIndex:index];
    return res;
}

@end
