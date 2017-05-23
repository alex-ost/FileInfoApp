//
//  FIAFileDatabase.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FIAFileDatabase.h"


@implementation FIAFileDatabase

#pragma mark - Overridden
+ (NSString *)databaseModelName {
	return @"FIAFileDataModel";
}

#pragma mark - Public
// CRUD
- (NSArray *)allFiles {
	return [self filesByPredicate:nil usingSortDescriptor:nil];
}

- (FIAFileDatabaseFile *)addFileByPath:(NSString *)filePath {
	return [self databaseFileByPath:filePath createIfNeeded:true];
}

- (BOOL)removeFileFromDBByPath:(NSString *)filePath {
	return [self removeDatabaseFileByPath:filePath];
}

- (BOOL)removeFileFromDB:(FIAFileDatabaseFile *)file {
	[self.mainContext deleteObject:file];
	NSLog(@"File was deleted, filePath:%@", file.filePath);
	return true;
}

#pragma mark - Private
- (BOOL)removeDatabaseFileByPath:(NSString *)filePath {
	BOOL fileWaRemoved = false;
	FIAFileDatabaseFile *databaseFile = [self databaseFileByPath:filePath createIfNeeded:false];
	if (databaseFile) {
		[self.mainContext deleteObject:databaseFile];
		NSLog(@"File was deleted, filePath:%@", databaseFile.filePath);
		fileWaRemoved = true;
	}
	else {
		NSLog(@"Trying remove nonexistent in database file, filePath:%@", databaseFile.filePath);
	}
	return fileWaRemoved;
}

- (FIAFileDatabaseFile *)databaseFileByPath:(NSString *)filePath createIfNeeded:(BOOL)flag {
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"File"];
	request.fetchLimit = 1;
	request.predicate = [NSPredicate predicateWithFormat:@"filePath == %@", filePath];
	
	NSError *error;
	NSArray *fetchResult = [self.mainContext executeFetchRequest:request error:&error];
	if (error) {
		NSLog(@"Did fail fetch file by path:%@, error:%@", filePath, error);
	}
	FIAFileDatabaseFile *databaseFile = fetchResult.lastObject;
	if (!databaseFile && flag) {
		databaseFile = (FIAFileDatabaseFile *)[NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:self.mainContext];
		databaseFile.filePath = filePath;
		databaseFile.addTime = [NSDate date];
	}
	return databaseFile;
}

- (NSArray *)filesByPredicate:(NSPredicate *)predicate usingSortDescriptor:(NSArray *)sortDescriptors {
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"File"];
	request.sortDescriptors = sortDescriptors;
	request.predicate = predicate;
	
	NSError *error;
	NSArray *result = [self.mainContext executeFetchRequest:request error:&error];
	if (error) {
		NSLog(@"Did fail fetch database files, error:%@", error);
	}
	return result;
}

@end
