//
//  FPToolDefines.h
//  FileProcessorTool
//
//  Created by Alex Ostrynskyi on 07/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPFileProcessorService.h"


extern NSString *const kFileProcessorSeriveName;

@interface NSXPCInterface (FPToolDefines)

+ (NSXPCInterface *)fileProcessorServiceInterface;

@end

