//
//  FPFileProcessor.h
//  FileProcessor
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileProcessorInterface.h"


@interface FPFileProcessor : NSObject <FPFileProcessorService>

// Thread safe methods.
- (void)run;
- (void)stopWithCompletionBlock:(void (^)())block;

@end
