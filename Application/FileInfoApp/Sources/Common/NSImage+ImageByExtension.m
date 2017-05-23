//
//  NSImage+ImageByExtension.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "NSImage+ImageByExtension.h"


@implementation NSImage (ImageByExtension)

+ (instancetype)imageByExtension:(NSString *)extension {
	NSImage *image = [NSImage imageNamed:extension];
	if (!image) {
		image = [NSImage imageNamed:@"unknown"];
	}
	return image;
}

@end
