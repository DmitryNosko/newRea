//
//  FileFeedResourceRepository.m
//  RSSReader
//
//  Created by USER on 9/16/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "FileFeedResourceRepository.h"
@interface FileFeedResourceRepository()
@property (strong, nonatomic) NSFileManager* fileManager;
@end

@implementation FileFeedResourceRepository

static FileFeedResourceRepository* shared;

+(instancetype) sharedFileFeedResourceRepository {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [FileFeedResourceRepository new];
        shared.fileManager = [NSFileManager defaultManager];
    });
    return shared;
}

#pragma mark - FeedResource

- (void)saveFeedResource:(FeedResource*) resource toFileWithName:(NSString*) fileName {
    NSMutableArray* encodedResource = [[NSMutableArray alloc] initWithObjects:[NSKeyedArchiver archivedDataWithRootObject:resource], nil];
    
    NSData* encodedArray = [NSKeyedArchiver archivedDataWithRootObject:encodedResource];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    if ([self.fileManager fileExistsAtPath:filePath]) {
 
        NSMutableArray<FeedResource *>* decodedResources = [self feedResources:fileName];
        NSMutableArray<NSData *>* encodedFileContent = [[NSMutableArray alloc] init];
        for (FeedResource* decodedResource in decodedResources) {
            [encodedFileContent addObject:[NSKeyedArchiver archivedDataWithRootObject:decodedResource]];
        }
        
        [encodedFileContent addObject:[NSKeyedArchiver archivedDataWithRootObject:resource]];
        
        NSData* encodedFileData = [NSKeyedArchiver archivedDataWithRootObject:encodedFileContent];
        [encodedFileData writeToFile:filePath atomically:YES];
        
    } else {
        [self.fileManager createFileAtPath:filePath contents:encodedArray attributes:nil];
    }
}

- (NSMutableArray<FeedResource *> *) feedResources:(NSString*) fileName {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData* fileContent = [fileHandle readDataToEndOfFile];
    
    NSMutableArray<NSData *>* encodedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:fileContent];
    NSMutableArray<FeedResource *>* decodedResources = [[NSMutableArray alloc] init];
    
    for (NSData* data in encodedObjects) {
        FeedResource* resource = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [decodedResources addObject:resource];
    }
    
    return decodedResources;
}

- (void) removeFeedResource:(FeedResource *) resource  fromFile:(NSString *) fileName {
    NSMutableArray<FeedResource *>* resorces = [self feedResources:fileName];
    
    for (FeedResource* feedResource in [resorces copy]) {
        if ([[feedResource.url absoluteString] isEqualToString:[resource.url absoluteString]]) {
            [resorces removeObject:feedResource];
        }
    }
    
    [self removeAllObjectsFormFile:fileName];
    
    for (FeedResource* fR in [resorces copy]) {
        [self saveFeedResource:fR toFileWithName:fileName];
    }
}

- (void) removeAllObjectsFormFile:(NSString *) fileName {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    [self.fileManager createFileAtPath:filePath contents:nil attributes:nil];
}

@end
