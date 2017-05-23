//
//  NSImage+ImageByExtension.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (ImageByExtension)

+ (instancetype)imageByExtension:(NSString *)extension;

@end
