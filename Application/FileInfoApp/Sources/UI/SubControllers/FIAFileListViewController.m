//
//  FIAFileListViewController.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FIAFileListViewController.h"
#import "FIAAppDelegate.h"
#import "FIAFileDatabaseFile.h"
#import "FIAFileTableCellView.h"
#import "NSImage+ImageByExtension.h"


@interface FIAFileListViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) NSArray <FIAFileDatabaseFile *>*files;
@property (weak) IBOutlet NSTableView *tableView;

@end


@implementation FIAFileListViewController

#pragma mark - Overridden
- (void)setFileDatabaseAccessor:(FIAFileDatabase *)fileDatabaseAccessor {
	_fileDatabaseAccessor = fileDatabaseAccessor;
	[self reloadFielsList];
}

#pragma mark - Private 
- (void)reloadFielsList {
	self.files = [self.fileDatabaseAccessor allFiles] ?: [NSArray new];
	[self.tableView reloadData];
}

#pragma mark - Actions / Handlers
- (IBAction)addFileAction:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel beginWithCompletionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			NSURL *fileURL = [panel URLs].firstObject;
			FIAFileDatabaseFile *file = [self.fileDatabaseAccessor addFileByPath:fileURL.path];
			if (file) {
				//Save here just for test app, in normal app it shouldn't be here
				[self.fileDatabaseAccessor save:nil];
				
				NSLog(@"File was added: %@", fileURL);
				NSMutableArray *mutFiles = [self.files mutableCopy];
				[mutFiles addObject:file];
				self.files = [mutFiles copy];
				
				// TODO: OA: Try to find method like addCell:toColumn:
				[self.tableView reloadData];
			}
		}
	}];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return self.files.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	FIAFileDatabaseFile *file = self.files[row];
	
	FIAFileTableCellView *cellView = [tableView makeViewWithIdentifier:@"fileCell" owner:self];
	cellView.backgroundStyle = NSBackgroundStyleDark;
	cellView.fileImageView.image = [NSImage imageByExtension:file.filePath.pathExtension];
	cellView.fileName.stringValue = file.filePath.lastPathComponent;
	cellView.filePath.stringValue = file.filePath;
	return cellView;
}

#pragma mark - NSTableViewDelegate
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	NSTableView *tableView = notification.object;
	NSInteger rowIndex = tableView.selectedRow;
	if (self.fileSelectionBlock) {
		self.fileSelectionBlock(rowIndex < 0 ? nil : self.files[rowIndex]);
	}
}

@end
