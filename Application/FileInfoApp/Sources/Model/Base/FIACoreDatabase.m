//
//  FIACoreDatabase.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FIACoreDatabase.h"


NSString *const FIADatabaseOpenedNotification = @"FIADatabaseOpenedNotification";
NSString *const FIADatabaseClosedNotification = @"FIADatabaseClosedNotification";

//
static NSString *const FIADatabaseFilename = @"FIADatabase";

@interface FIACoreDatabase ()

@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *modelPath;

@end


@implementation FIACoreDatabase

+ (instancetype)databaseWithPath:(NSString *)path modelPath:(NSString *)modelPath {
	return [[self alloc] initWithPath:path modelPath:modelPath];
}

- (instancetype)initWithPath:(NSString *)path modelPath:(NSString *)modelPath {
	self = [super init];
	if (self) {
		self.isOpen = false;
		self.path = path;
		self.modelPath = modelPath;
	}
	return self;
}

+ (NSString *)databaseModelName {
	return nil;
}

#pragma mark - DB Operations
- (BOOL)open {
	if (self.isOpen) {
		CDBLog(@"Is already open");
		return true;
	}
	
	NSManagedObjectContext *context = [self _mainContext];
	if (!context) {
		CDBLog(@"Opening failed.");
		return false;
	}
	
	self.mainContext = context;
	self.persistentStoreCoordinator = context.persistentStoreCoordinator;
	self.managedObjectModel = context.persistentStoreCoordinator.managedObjectModel;
	self.isOpen = true;
	CDBLog(@"Successfully opened.");
	[[NSNotificationCenter defaultCenter] postNotificationName:FIADatabaseOpenedNotification object:self];
	return true;
}

- (BOOL)save:(NSError **)error {
	if (!self.isOpen) {
		CDBLog(@"Is not open");
		return false;
	}
	return [self.mainContext save:error];
}

- (void)close {
	if (!self.isOpen) {
		CDBLog(@"Is not open");
		return;
	}
	self.mainContext = nil;
	self.persistentStoreCoordinator = nil;
	self.managedObjectModel = nil;
	self.isOpen = false;
	[[NSNotificationCenter defaultCenter] postNotificationName:FIADatabaseClosedNotification object:self];
	CDBLog(@"Successfully closed.");
}

- (void)cleanDatabase {
	NSMutableSet *parentEntities = [NSMutableSet new];
	for (NSEntityDescription *entity in self.managedObjectModel.entities) {
		if (!entity.superentity) {
			[parentEntities addObject:entity];
		}
	}
	
	for (NSEntityDescription *parentEntity in parentEntities) {
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:parentEntity.name];
		
		NSError *error;
		NSArray *result = [self.mainContext executeFetchRequest:request error:&error];
		if (error) {
			CDBLog(@"Did fail fetch entities with name:%@, error:%@", parentEntity.name, error);
		}
		
		NSUInteger totalCount = result.count;
		for (NSManagedObject *policyRule in result) {
			[self.mainContext deleteObject:policyRule];
		}
		CDBLog(@"Database '%@' was cleaned, removed %lu managed objects.", NSStringFromClass([self class]), totalCount);
	}
}

- (void)performBlock:(void (^)())block {
	block = [block copy];
	[self.mainContext performBlock:^ {
		block();
	}];
}

#pragma mark - Accessor
- (NSManagedObjectContext *)_mainContext {
	NSPersistentStoreCoordinator *coorinator = [self _persistentStoreCoordinator];
	NSManagedObjectContext *mainContext = nil;
	if (coorinator) {
		mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[mainContext setPersistentStoreCoordinator:coorinator];
	}
	return mainContext;
}

- (NSPersistentStoreCoordinator *)_persistentStoreCoordinator {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	
	NSURL *pathURL = [NSURL fileURLWithPath:self.path];
	NSDictionary *properties = [pathURL resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
	if (properties) {
		if (![properties[NSURLIsDirectoryKey] boolValue]) {
			CDBLog(@"Expected a folder to store application data, found a file (%@).", pathURL);
			error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOTDIR userInfo:@{@"URL": pathURL}];
		}
	}
	else if ([error code] == NSFileReadNoSuchFileError) {
		error = nil;
		[fileManager createDirectoryAtPath:self.path withIntermediateDirectories:true attributes:nil error:&error];
	}
	
	NSPersistentStoreCoordinator *coordinator = nil;
	if (!error) {
		NSManagedObjectModel *managedObjectModel = [self _managedObjectModel];
		if (!error && managedObjectModel) {
			@try {
				coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
				NSURL *databaseURL = [pathURL URLByAppendingPathComponent:FIADatabaseFilename];
				if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:databaseURL options:nil error:&error]) {
					coordinator = nil;
					CDBLog(@"Error initilizing store at %@, error %@", databaseURL, error);
				} else {
					CDBLog(@"Store was initialized by path: %@", databaseURL);
				}
			}
			@catch (NSException *exception) {
				CDBLog(@"Exception during persistent store initilizing at %@, exception %@", pathURL, exception);
				coordinator = nil;
				error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{@"URL": pathURL, NSLocalizedDescriptionKey: exception.reason}];
			}
		}
	}
	return error ? nil : coordinator;
}

- (NSManagedObjectModel *)_managedObjectModel {
	NSManagedObjectModel *mainManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.modelPath]];
	if (mainManagedObjectModel) {
		CDBLog(@"%@ main datamodel was loaded, with path %@", [self class], self.modelPath);
	}
	else {
		CDBLog(@"Error loading datamodel by path %@", self.modelPath);
	}
	return mainManagedObjectModel;
}

#pragma mark - LogWrapper
void CDBLog(NSString *format, ...) {
	va_list args;
	va_start(args, format);
	NSLogv([NSString stringWithFormat:@"Database: %@", format], args);
	va_end(args);
}


@end
