//
//  FIAAppDelegate.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 31/12/2016.
//  Copyright © 2016 AlexOst. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FIAFileDatabase.h"
#import "FIAFileProcessorMediator.h"


@interface FIAAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, readonly) FIAFileDatabase *fileDatabaseAccessor;
@property (nonatomic, readonly) FIAFileProcessorMediator *fileProcessorMediator;

@end

