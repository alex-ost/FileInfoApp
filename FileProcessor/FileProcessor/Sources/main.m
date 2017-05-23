//
//  main.m
//  FileProcessor
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPFileProcessor.h"
#import <syslog.h>


int main(int argc, const char *argv[]) {
	syslog(LOG_NOTICE, " ************************  NOTICE: FP launched! uid = %d, euid = %d, pid = %d\n", (int) getuid(), (int) geteuid(), (int) getpid());
	
	FPFileProcessor *fileProcessor = [FPFileProcessor new];
	[fileProcessor run];
	
    return 0;
}
