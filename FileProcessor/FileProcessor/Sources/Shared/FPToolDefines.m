//
//  FPToolDefines.m
//  FileProcessorTool
//
//  Created by Alex Ostrynskyi on 07/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FPToolDefines.h"


NSString *const kFileProcessorSeriveName = @"com.alexost.fileinfoapp.FileProcessorTool";

@implementation NSXPCInterface (FPToolDefines)

+ (NSXPCInterface *)fileProcessorServiceInterface {
	NSXPCInterface *serviceInterface = [NSXPCInterface interfaceWithProtocol:@protocol(FPFileProcessorService)];
	return serviceInterface;
}

@end
