//
//  FIAFileProcessorMediator.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 03/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FileProcessorInterface/FPToolDefines.h>


@interface FIAFileProcessorMediator : NSObject <FPFileProcessorService>

@property (nonatomic, readonly) BOOL running;

- (void)runMediatorWithCompletionBlock:(void (^)(BOOL, NSError *))block;

@end
