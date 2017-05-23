//
//  FIAFileActionTableCellView.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 08/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FIAFileActionTableCellView.h"


@implementation FIAFileActionTableCellView

#pragma mark - Actions
- (IBAction)cellAction:(id)sender {
	if (self.actionBlock) {
		self.actionBlock(self);
	}
}

@end
