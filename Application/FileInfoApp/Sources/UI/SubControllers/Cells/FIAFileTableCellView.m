//
//  FIAFileTableCellView.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FIAFileTableCellView.h"


@implementation FIAFileTableCellView

- (IBAction)showInFinderAction:(id)sender {
	NSString *filePath = self.filePath.stringValue;
	if (filePath.length) {
		NSLog(@"Show in Finder: %@", filePath);
		NSArray *fileURLs = @[[NSURL fileURLWithPath:filePath]];
		[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
	}
}

@end
