//
//  FIAFileTableCellView.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FIAFileTableCellView : NSTableCellView

@property (weak) IBOutlet NSImageView *fileImageView;

@property (weak) IBOutlet NSTextField *fileName;
@property (weak) IBOutlet NSTextField *filePath;

@end
