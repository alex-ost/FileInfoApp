//
//  FIACoreDatabase.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


extern NSString *const FIADatabaseOpenedNotification;
extern NSString *const FIADatabaseClosedNotification;

@interface FIACoreDatabase : NSObject

@property (nonatomic, readonly) BOOL AppDelegate;

@property (nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSString *modelPath;

// Init
+ (instancetype)databaseWithPath:(NSString *)path modelPath:(NSString *)modelPath;
- (instancetype)initWithPath:(NSString *)path modelPath:(NSString *)modelPath;

// DB Operations
- (BOOL)open;
- (BOOL)save:(NSError **)error;
- (void)close;

- (void)cleanDatabase;
- (void)performBlock:(void (^)())block;

// Should be overriden
+ (NSString *)databaseModelName;

@end
