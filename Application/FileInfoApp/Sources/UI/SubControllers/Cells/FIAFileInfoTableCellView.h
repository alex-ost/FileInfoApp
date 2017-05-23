//
//  FIAFileInfoTableCellView.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class FIAFileInfoTableCellView;
typedef void (^RefreshBlock)(FIAFileInfoTableCellView *cell);

@interface FIAFileInfoTableCellView : NSTableCellView

// UI
@property (weak) IBOutlet NSTextField *infoKeyLabel;
@property (weak) IBOutlet NSTextField *infoValueLabel;
@property (weak) IBOutlet NSButton *refreshDataButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

// Helpers
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) BOOL isRefreshable;
@property (nonatomic, copy) RefreshBlock refreshDataBlock;

@end
