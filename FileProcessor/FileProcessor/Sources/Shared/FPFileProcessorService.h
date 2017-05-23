//
//  FPFileProcessorProtocol.h
//  FileProcessor
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^StringValueBlock)(NSString *value, NSError *error);
typedef void (^NumberValueBlock)(NSNumber *value, NSError *error);

@protocol FPFileProcessorService

// Returns File Processor version.
- (void)getVersionWithCompletionBlock:(StringValueBlock)block;

// Info Operations
- (void)getSHA1HashForFile:(NSString *)filePath withCompletionBlock:(StringValueBlock)block;
- (void)getSizeForFile:(NSString *)filePath withCompletionBlock:(NumberValueBlock)block;

// Action Operations
- (void)removeFile:(NSString *)filePath withCompletionBlock:(void(^)(BOOL removed, NSError *error))block;

@end
