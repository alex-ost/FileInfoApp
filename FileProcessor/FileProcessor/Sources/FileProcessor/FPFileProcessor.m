//
//  FPFileProcessor.m
//  FileProcessor
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FPFileProcessor.h"
#import <sys/stat.h>
#import <CommonCrypto/CommonDigest.h>


@interface FPFileProcessor () <NSXPCListenerDelegate>

@property (nonatomic, strong) NSMutableArray *serviceConnections;
@property (nonatomic, strong) NSXPCListener *serviceConnectionListener;

@property (nonatomic) BOOL running;

@end


@implementation FPFileProcessor

#pragma mark - Public
- (void)run {
	if (self.running) {
		NSLog(@"FileProcessor is already run");
		return;
	}
	
	// Service listener
	self.serviceConnections = [NSMutableArray arrayWithCapacity:0];
	self.serviceConnectionListener = [[NSXPCListener alloc] initWithMachServiceName:kFileProcessorSeriveName];
	self.serviceConnectionListener.delegate = self;
	[self.serviceConnectionListener resume];
	self.running = true;
	
	// Run the run loop forever.
	[[NSRunLoop currentRunLoop] run];
	NSLog(@"Run FP.");
	while (self.running && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	
	NSLog(@"Exiting FP...");
}

- (void)stopWithCompletionBlock:(void (^)())block {
	@synchronized (self) {
		if (!self.running) {
			NSLog(@"FileProcessor is not run");
			return;
		}
		
		// Inavlidate connections
		for (NSXPCConnection *connection in self.serviceConnections) {
			[connection invalidate];
		}
		
		// Stop listening.
		[self.serviceConnectionListener invalidate];
		self.serviceConnections = nil;
		
		self.running = false;
		// Callback
		if (block) {
			block();
		}
	}
}

#pragma mark - FPFileProcessorService
- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
	@synchronized (self) {
		NSLog(@"Incoming service connection %p", newConnection);
		[self.serviceConnections addObject:newConnection];
		
		NSXPCInterface *serviceInterface = [NSXPCInterface fileProcessorServiceInterface];
		NSLog(@"Service interface: %@", serviceInterface.debugDescription);
		
		newConnection.exportedInterface = serviceInterface;
		newConnection.exportedObject = self;
		__weak NSXPCConnection *weakConnection = newConnection;
		newConnection.invalidationHandler = ^ {
			NSLog(@"Service connection %p has been invalidated", weakConnection);
			@synchronized (self) {
				[self.serviceConnections removeObject:weakConnection];
			}
		};
		[newConnection resume];
	}
	return true;
}

#pragma mark - FileProcessorService
- (void)getVersionWithCompletionBlock:(StringValueBlock)block {
	if (block) {
		block([self fullVersionDisplayString], nil);
	}
}

- (void)getSHA1HashForFile:(NSString *)filePath withCompletionBlock:(StringValueBlock)block {
	if (block) {
		block([self SHA1HashForFile:filePath], nil);
	}
}

- (void)getSizeForFile:(NSString *)filePath withCompletionBlock:(NumberValueBlock)block {
	if (block) {
		block([self sizeForFile:filePath], nil);
	}
}

- (void)removeFile:(NSString *)filePath withCompletionBlock:(void(^)(BOOL removed, NSError *error))block {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	BOOL success = [fileManager removeItemAtPath:filePath error:&error];
	if (block) {
		block(success, error);
	}
}

#pragma mark - Helpers
- (NSString *)SHA1HashForFile:(NSString *)filePath {
	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
	if (!handle) {
		return nil;
	}
	
	NSData *data = [handle readDataToEndOfFile];
	if (!data) {
		NSLog(@"Error: Can't read file: %@", filePath);
		return nil;
	}
	
	// Encrypt
	NSMutableString *encryptedString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
	
	for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[encryptedString appendFormat:@"%02x", digest[i]];
	}
	return encryptedString;
}

- (NSNumber *)sizeForFile:(NSString *)filePath {
	NSNumber *result = nil;
	struct stat stat_res;
	int res = stat([[NSFileManager defaultManager] fileSystemRepresentationWithPath:filePath], &stat_res);
	if (res == 0) {
		result = [NSNumber numberWithLongLong:(long long)stat_res.st_size];
	}
	return result;
}

- (NSString *)fullVersionDisplayString {
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
	NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
	return [NSString stringWithFormat:@"%@.%@", majorVersion, minorVersion];
}

@end
