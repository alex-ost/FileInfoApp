//
//  FIAMainViewController.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 31/12/2016.
//  Copyright © 2016 AlexOst. All rights reserved.
//

#import "FIAMainViewController.h"
#import "FIAFileListViewController.h"
#import "FIAFileInfoViewController.h"


@interface FIAMainViewController ()

@property (nonatomic, weak) FIAFileListViewController *fileListViewController;
@property (nonatomic, weak) FIAFileInfoViewController *fileInfoViewController;

@end


@implementation FIAMainViewController

#pragma mark - Overridden
- (void)setFileDatabaseAccessor:(FIAFileDatabase *)fileDatabaseAccessor {
	_fileDatabaseAccessor = fileDatabaseAccessor;
	self.fileInfoViewController.fileDatabaseAccessor = fileDatabaseAccessor;
	self.fileListViewController.fileDatabaseAccessor = fileDatabaseAccessor;
}

- (void)setFileProcessorMediator:(FIAFileProcessorMediator *)fileProcessorMediator {
	_fileProcessorMediator = fileProcessorMediator;
	self.fileInfoViewController.fileProcessorMediator = fileProcessorMediator;
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"info"]) {
		self.fileInfoViewController = segue.destinationController;
		self.fileInfoViewController.fileRemoveBlock = ^() {
			[self.fileListViewController reloadFielsList];
		};
	} else if ([segue.identifier isEqualToString:@"list"]) {
		self.fileListViewController = segue.destinationController;
		self.fileListViewController.fileSelectionBlock = ^(FIAFileDatabaseFile *file) {
			self.fileInfoViewController.file = file;
		};
	}
}

@end
