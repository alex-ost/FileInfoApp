//
//  FIAFileInfoTableCellView.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FIAFileInfoTableCellView.h"


@implementation FIAFileInfoTableCellView

#pragma mark - Overridden
- (void)setIsRefreshable:(BOOL)isRefreshable {
	_isRefreshable = isRefreshable;
	self.refreshDataButton.enabled = isRefreshable;
	self.refreshDataButton.image = isRefreshable ? [NSImage imageNamed:@"refresh"] : nil;
}

#pragma mark - Actions
- (IBAction)refreshData:(id)sender {
	if (self.refreshDataBlock) {
		self.refreshDataBlock(self);
	}
}

@end
