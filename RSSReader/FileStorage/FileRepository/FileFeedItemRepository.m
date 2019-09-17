//
//  FileFeedItemRepository.m
//  RSSReader
//
//  Created by USER on 9/16/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "FileFeedItemRepository.h"

@interface FileFeedItemRepository()
@property (strong, nonatomic) NSFileManager* fileManager;
@end

@implementation FileFeedItemRepository

static FileFeedItemRepository* shared;

+(instancetype) sharedFileFeedItemRepository {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [FileFeedItemRepository new];
        shared.fileManager = [NSFileManager defaultManager];
    });
    return shared;
}

#pragma mark - FeedItem

- (void)saveFeedItem:(FeedItem*) item toFileWithName:(NSString*) fileName {
    
    NSMutableArray* encodedItems = [[NSMutableArray alloc] initWithObjects:[NSKeyedArchiver archivedDataWithRootObject:item], nil];
    
    NSData* encodedArray = [NSKeyedArchiver archivedDataWithRootObject:encodedItems];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    if ([self.fileManager fileExistsAtPath:filePath]) {
        //load file
        NSMutableArray<FeedItem *>* decodedItems = [self readFeedItemsFile:fileName];
        NSMutableArray<NSData *>* encodedFileContent = [[NSMutableArray alloc] init];
        for (FeedItem* decodedItem in decodedItems) {
            [encodedFileContent addObject:[NSKeyedArchiver archivedDataWithRootObject:decodedItem]];
        }
        
        [encodedFileContent addObject:[NSKeyedArchiver archivedDataWithRootObject:item]];
        
        NSData* encodedFileData = [NSKeyedArchiver archivedDataWithRootObject:encodedFileContent];
        [encodedFileData writeToFile:filePath atomically:YES];
        
    } else {
        [self.fileManager createFileAtPath:filePath contents:encodedArray attributes:nil];
    }
}

- (void) updateFeedItem:(FeedItem *) item inFile:(NSString *) fileName {
    NSMutableArray<FeedItem *>* items = [self readFeedItemsFile:fileName];
    if ([items count] > 1) {
        NSUInteger index = [items indexOfObjectPassingTest:^BOOL(FeedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj.link isEqualToString:item.link];
        }];
        
        [items replaceObjectAtIndex:index withObject:item];
        [self createAndSaveFeedItems:items toFileWithName:fileName];
    }
}

- (NSMutableArray<FeedItem *> *) readFeedItemsFile:(NSString*) fileName {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData* fileContent = [fileHandle readDataToEndOfFile];
    
    NSMutableArray<NSData *>* encodedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:fileContent];
    NSMutableArray<FeedItem *>* decodedItems = [[NSMutableArray alloc] init];
    
    for (NSData* data in encodedObjects) {
        FeedItem* item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (item) {
            [decodedItems addObject:item];
        }
    }
    
    return decodedItems;
}

- (void) removeFeedItem:(FeedItem *) item  fromFile:(NSString *) fileName {
    
    NSMutableArray<FeedItem *>* items = [self readFeedItemsFile:fileName];
    
    for (FeedItem* feedItem in [items copy]) {
        if ([feedItem.link isEqualToString:item.link]) {
            [items removeObject:feedItem];
        }
    }
    
    [self removeAllObjectsFormFile:fileName];
    
    for (FeedItem* fI in [items copy]) {
        [self saveFeedItem:fI toFileWithName:fileName];
    }
}

- (void)createAndSaveFeedItems:(NSMutableArray<FeedItem*>*) items toFileWithName:(NSString*) fileName {
    NSMutableArray<NSData*>* encodedItems = [[NSMutableArray alloc] init];
    
    for (FeedItem* item in [items copy]) {
        [encodedItems addObject:[NSKeyedArchiver archivedDataWithRootObject:item]];
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    [self.fileManager createFileAtPath:filePath contents:[NSKeyedArchiver archivedDataWithRootObject:encodedItems] attributes:nil];
}

- (void) removeAllObjectsFormFile:(NSString *) fileName {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    [self.fileManager createFileAtPath:filePath contents:nil attributes:nil];
}


- (NSMutableArray<NSString *>*) readStringsFromFile:(NSString *) fileName {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData* fileContent = [fileHandle readDataToEndOfFile];
    NSMutableArray<NSString *>* decodedArray = [NSKeyedUnarchiver unarchiveObjectWithData:fileContent];
    return decodedArray ? decodedArray : [[NSMutableArray alloc] init];
}

- (void) saveString:(NSString *) stringToSave toFile:(NSString *) fileName {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    if ([self.fileManager fileExistsAtPath:filePath]) {
        
        NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        NSData* fileContent = [fileHandle readDataToEndOfFile];
        NSMutableArray<NSString *>* savedItems = [NSKeyedUnarchiver unarchiveObjectWithData:fileContent];
        if (savedItems) {
            [savedItems addObject:stringToSave];
        } else {
            savedItems = [[NSMutableArray alloc] initWithObjects:stringToSave, nil];
        }
        
        
        NSData* encodedFileData = [NSKeyedArchiver archivedDataWithRootObject:savedItems];
        [encodedFileData writeToFile:filePath atomically:YES];
    } else {
        [self.fileManager createFileAtPath:filePath contents:[NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] initWithObjects:stringToSave, nil]] attributes:nil];
    }
}

- (void) removeString:(NSString *) string fromFile:(NSString *) fileName {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    if ([self.fileManager fileExistsAtPath:filePath]) {
        
        NSMutableArray<NSString *>* strings = [self readStringsFromFile:fileName];
        
        for (NSString* str in [strings copy]) {
            if ([str isEqualToString:string]) {
                [strings removeObject:str];
            }
        }
        
        [self removeAllObjectsFormFile:fileName];
        
        for (NSString* str in strings) {
            [self saveString:str toFile:fileName];
        }
        
    }
}

@end
