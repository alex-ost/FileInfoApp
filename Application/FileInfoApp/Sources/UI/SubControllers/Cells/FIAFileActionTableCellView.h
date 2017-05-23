//
//  FIAFileActionTableCellView.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 08/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class FIAFileActionTableCellView;
typedef void (^FileActionBlock)(FIAFileActionTableCellView *cell);

@interface FIAFileActionTableCellView : NSTableCellView

@property (weak) IBOutlet NSButton *actionButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, copy) FileActionBlock actionBlock;

@end
