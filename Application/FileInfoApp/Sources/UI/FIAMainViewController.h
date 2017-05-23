//
//  FIAMainViewController.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 31/12/2016.
//  Copyright © 2016 AlexOst. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FIAFileDatabase.h"
#import "FIAFileProcessorMediator.h"


@interface FIAMainViewController : NSViewController

// Accessor & Processor
@property (nonatomic, strong) FIAFileDatabase *fileDatabaseAccessor;
@property (nonatomic, strong) FIAFileProcessorMediator *fileProcessorMediator;

@end

