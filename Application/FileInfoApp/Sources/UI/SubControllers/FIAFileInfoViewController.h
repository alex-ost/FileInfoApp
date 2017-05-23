//
//  FIAFileInfoViewController.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FIAFileDatabase.h"
#import "FIAFileProcessorMediator.h"


@interface FIAFileInfoViewController : NSViewController

@property (nonatomic, strong) FIAFileDatabaseFile *file;
@property (nonatomic, copy) dispatch_block_t fileRemoveBlock;

// Accessor & Processor
@property (nonatomic, strong) FIAFileDatabase *fileDatabaseAccessor;
@property (nonatomic, strong) FIAFileProcessorMediator *fileProcessorMediator;

@end
