//
//  FIAFileDatabase.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FIACoreDatabase.h"
#import "FIAFileDatabaseFile.h"


@interface FIAFileDatabase : FIACoreDatabase

// CRUD
- (NSArray *)allFiles; // Convinient method
- (NSArray *)filesByPredicate:(NSPredicate *)predicate usingSortDescriptor:(NSArray *)sortDescriptors;

- (FIAFileDatabaseFile *)addFileByPath:(NSString *)filePath;

- (BOOL)removeFileFromDBByPath:(NSString *)filePath;
- (BOOL)removeFileFromDB:(FIAFileDatabaseFile *)file;

@end
