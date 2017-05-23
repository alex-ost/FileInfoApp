//
//  FIAFileInfoViewController.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FIAFileInfoViewController.h"
#import "FIAAppDelegate.h"
#import "FIAFileInfoTableCellView.h"
#import "FIAFileActionTableCellView.h"
#import "NSImage+ImageByExtension.h"


typedef enum {
	FileName,
	FilePath,
	FileSize,
	FileSHA1Hash,
} FileInfoCell;

typedef enum {
	RemoveFromDB,
	RemoveFromDisk,
} FileActionCell;

@interface FIAFileInfoViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSImageView *fileIconImageView;

@end


@implementation FIAFileInfoViewController

#pragma mark - Overridden
- (void)setFile:(FIAFileDatabaseFile *)file {
	_file = file;
	self.fileIconImageView.image = _file != nil ? [NSImage imageByExtension:self.file.filePath.pathExtension] : nil;
	[self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return self.infoCellCount + self.actionCellCount;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if (row < self.infoCellCount) {
		return [self fileInfoView:tableView viewForTableColumn:tableColumn row:row];
	}
	// Action cells
	return [self fileActionView:tableView viewForTableColumn:tableColumn row:row];
}

- (NSView *)fileActionView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	FIAFileActionTableCellView *cellView = [tableView makeViewWithIdentifier:@"fileActionCell" owner:self];
	cellView.backgroundStyle = NSBackgroundStyleDark;
	
	BOOL hasFile = self.file != nil;
	cellView.actionButton.hidden = !hasFile;
	switch ((FileActionCell)(row - self.infoCellCount)) {
		case RemoveFromDB: {
			cellView.actionButton.title = @"Remove From DB";
			cellView.actionBlock = ^(FIAFileActionTableCellView *cell) {
				[self removeFile:self.file fromDisk:false];
			};
		}
			break;
		case RemoveFromDisk: {
			cellView.actionButton.title = @"Remove From Disk";
			cellView.actionBlock = ^(FIAFileActionTableCellView *cell) {
				[self removeFile:self.file fromDisk:true];
			};
		}
			break;
		default:
			NSLog(@"No handlers for action: %li", (long)row);
			break;
	}
	return cellView;
}

- (NSView *)fileInfoView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	FIAFileInfoTableCellView *cellView = [tableView makeViewWithIdentifier:@"fileInfoCell" owner:self];
	cellView.backgroundStyle = NSBackgroundStyleDark;
	BOOL hasFile = self.file != nil;
	switch ((FileInfoCell)row) {
		case FileName:
			cellView.type = FileName;
			cellView.isRefreshable = false;
			cellView.infoKeyLabel.stringValue = @"Filename:";
			cellView.infoValueLabel.stringValue = hasFile ? [[self.file.filePath lastPathComponent] stringByDeletingPathExtension] : @"-";
			break;
		case FilePath:
			cellView.type = FilePath;
			cellView.isRefreshable = false;
			cellView.infoKeyLabel.stringValue = @"Path:";
			cellView.infoValueLabel.stringValue = hasFile ? self.file.filePath : @"-";
			break;
		case FileSize:
			cellView.type = FilePath;
			cellView.isRefreshable = true;
			cellView.infoKeyLabel.stringValue = @"Size";
			cellView.infoValueLabel.stringValue = hasFile ? self.file.size.integerValue != 0 ? [self formattedSize:self.file.size] : @"Need calculation..." : @"-";
			break;
		case FileSHA1Hash:
			cellView.type = FilePath;
			cellView.isRefreshable = true;
			cellView.infoKeyLabel.stringValue = @"SHA1 hash:";
			cellView.infoValueLabel.stringValue = hasFile ? self.file.sha1Hash ?: @"Need calculation..." : @"-";
			break;
	}
	
	if (!hasFile) {
		// Remove image for empty file.
		cellView.refreshDataButton.image = nil;
	}
	
	if (cellView.isRefreshable) {
		cellView.refreshDataBlock = [self refreshBlockForCell:cellView row:row];
	}
	return cellView;
}

#pragma mark - Helpers
- (RefreshBlock)refreshBlockForCell:(FIAFileInfoTableCellView *)cellView row:(NSInteger)row {
	void (^getDataBlock)(FIAFileInfoTableCellView *__weak weakCellView) = ^(FIAFileInfoTableCellView *__weak weakCellView) {
		[weakCellView.progressIndicator startAnimation:nil];
		switch ((FileInfoCell)row) {
			case FileSize: {
				[self.fileProcessorMediator getSizeForFile:self.file.filePath withCompletionBlock:^(NSNumber *size, NSError *error) {
					dispatch_async(dispatch_get_main_queue(), ^{
						self.file.size = size;
						weakCellView.infoValueLabel.stringValue = size ? [self formattedSize:size] : @"-";
						[weakCellView.progressIndicator stopAnimation:nil];
					});
				}];
			}
				break;
			case FileSHA1Hash: {
				[self.fileProcessorMediator getSHA1HashForFile:self.file.filePath withCompletionBlock:^(NSString *SHA1Hash, NSError *error) {
					dispatch_async(dispatch_get_main_queue(), ^{
						self.file.sha1Hash = SHA1Hash;
						weakCellView.infoValueLabel.stringValue = SHA1Hash.length ? SHA1Hash : @"-";
						[weakCellView.progressIndicator stopAnimation:nil];
					});
				}];
			}
				break;
			default:
				NSLog(@"No handlers for refresh action: %li", (long)row);
				break;
		}
	};
	
	// Check FP first. It should be runned and mediator should be connected.
	FIAFileInfoTableCellView *__weak weakCellView = cellView;
	RefreshBlock refreshDataBlock = ^(FIAFileInfoTableCellView *cell) {
		if (!self.fileProcessorMediator.running) {
			[self.fileProcessorMediator runMediatorWithCompletionBlock:^(BOOL running, NSError *error) {
				if (running) {
					getDataBlock(weakCellView);
				}
			}];
		} else {
			getDataBlock(weakCellView);
		}
	};
	return refreshDataBlock;
}

- (void)removeFile:(FIAFileDatabaseFile *)file fromDisk:(BOOL)flag {
	void (^removeFromDB)(FIAFileDatabaseFile *file) = ^(FIAFileDatabaseFile *file) {
		[self.fileDatabaseAccessor removeFileFromDB:self.file];
		[self.fileDatabaseAccessor save:nil];
		self.file = nil;
		if (self.fileRemoveBlock) {
			self.fileRemoveBlock();
		}
	};
	
	if (flag) {
		void (^fullFileRemove)(FIAFileDatabaseFile *file) = ^(FIAFileDatabaseFile *file) {
			[self.fileProcessorMediator removeFile:file.filePath withCompletionBlock:^(BOOL removed, NSError *error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (removed) {
						removeFromDB(file);
					} else {
						NSLog(@"File: '%@', wasn't removed. Error %@", file.filePath, error);
					}
				});
			}];
		};
		
		if (!self.fileProcessorMediator.running) {
			[self.fileProcessorMediator runMediatorWithCompletionBlock:^(BOOL running, NSError *error) {
				if (running) {
					fullFileRemove(file);
				}
			}];
		} else {
			fullFileRemove(file);
		}
	} else {
		removeFromDB(file);
	}
}

- (NSString *)formattedSize:(NSNumber *)size {
	double sizeInBytes = [size doubleValue];
	float sizeInKb = sizeInBytes / 1024;
	if (sizeInKb < 1) {
		// less then byte
		return [NSString stringWithFormat:@"%.f b", sizeInBytes];
	}
	
	float sizeInMb = sizeInBytes / 1024 / 1024;
	if (sizeInMb < 1) {
		return [NSString stringWithFormat:@"%.2f Kb", sizeInKb];
	}
	
	float sizeInGb = sizeInBytes / 1024 / 1024 / 1024;
	if (sizeInGb < 1) {
		return [NSString stringWithFormat:@"%.2f Mb", sizeInMb];
	}
	return [NSString stringWithFormat:@"%.2f Gb", sizeInGb];
}

- (NSUInteger)infoCellCount {
	//size of FileInfoCell enum
	return 4;
}

- (NSUInteger)actionCellCount {
	//size of FileActionCell enum
	return 2;
}

#pragma mark - NSTableViewDelegate
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)rowIndex {
	return false;
}

@end
