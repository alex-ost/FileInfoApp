//
//  FIAAppDelegate.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 31/12/2016.
//  Copyright © 2016 AlexOst. All rights reserved.
//

#import "FIAAppDelegate.h"
#import "FIAMainViewController.h"


@interface FIAAppDelegate ()

@property (nonatomic, strong) FIAFileDatabase *fileDatabaseAccessor;
@property (nonatomic, strong) FIAFileProcessorMediator *fileProcessorMediator;

@end


@implementation FIAAppDelegate

#pragma mark - AppDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
	// Load Files DB
	NSString *modelPath = [[NSBundle mainBundle] pathForResource:[FIAFileDatabase databaseModelName] ofType:@"momd"];
	
	self.fileDatabaseAccessor = [FIAFileDatabase databaseWithPath:[self applicationDocumentsDirectory].path modelPath:modelPath];
	[self.fileDatabaseAccessor open];
	
	// Init FP Mediator
	self.fileProcessorMediator = [FIAFileProcessorMediator new];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Tree-based hierarchy. Vivat dependency injections!
    FIAMainViewController *mainViewContoller = (FIAMainViewController *)[[[NSApplication sharedApplication] mainWindow] contentViewController];
    mainViewContoller.fileDatabaseAccessor = self.fileDatabaseAccessor;
    mainViewContoller.fileProcessorMediator = self.fileProcessorMediator;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[self.fileDatabaseAccessor save:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return true;
}

#pragma mark - Helpers
- (NSURL *)applicationDocumentsDirectory {
	NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	return [appSupportURL URLByAppendingPathComponent:@"com.alexost.fileinfoapp"];
}

@end
