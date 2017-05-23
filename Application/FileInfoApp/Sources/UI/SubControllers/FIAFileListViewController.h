//
//  FIAFileListViewController.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FIAFileDatabase.h"


typedef void (^FileSelectionBlock)(FIAFileDatabaseFile *file);

@interface FIAFileListViewController : NSViewController

@property (nonatomic, copy) FileSelectionBlock fileSelectionBlock;

// Accessor
@property (nonatomic, strong) FIAFileDatabase *fileDatabaseAccessor;

- (void)reloadFielsList;

@end
