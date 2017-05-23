//
//  FIAFileProcessorMediator.m
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 03/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import "FIAFileProcessorMediator.h"
#include <ServiceManagement/ServiceManagement.h>


typedef enum {
	kFPMediatorOutOfConnection,
	kFPMediatorInConnectionProcess,
	kFPMediatorInConnection,
} FPMediatorConnectionStatus;

@interface FIAFileProcessorMediator ()

// Helpers
@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) FPMediatorConnectionStatus connectionStatus;

// Auth
@property (nonatomic, assign) AuthorizationRef authorizationRef;

// FP and Connection
@property (nonatomic, strong) NSXPCConnection *fileProcessorConnection;
@property (nonatomic, strong) id<FPFileProcessorService> fileProcessor;

@end


@implementation FIAFileProcessorMediator

#pragma mark - Overridden
- (instancetype)init {
	self = [super init];
	if (self) {
		self.running = false;
	}
	return self;
}

#pragma mark - Public
- (void)runMediatorWithCompletionBlock:(void (^)(BOOL, NSError *))block {
	if (self.running) {
		MDTLog(@"Already running.");
		return;
	}
	
	// Connect to AuthService.
	if (!_authorizationRef) {
		AuthorizationItem authItem = { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
		AuthorizationRights authRights = { 1, &authItem };
		AuthorizationFlags flags =	kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
		
		// Obtain the right to install privileged helper tools (kSMRightBlessPrivilegedHelper).
		OSStatus err = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &self->_authorizationRef);
		
		// Just for logs.
		if (self->_authorizationRef && err == errAuthorizationSuccess) {
			MDTLog(@"Successfully connected to Authorization Services.");
			
			// Install FP Tool
			[self installFileProcessorWithCompletionBlock:block];
		} else {
			MDTLog(@"Wasn't connected to Authorization Services, error %i", err);
			if (block) {
				block(false, nil); // TODO: Create error
			}
		}
	} else {
		MDTLog(@"Has connect to Authorization Services.");
		[self installFileProcessorWithCompletionBlock:block];
	}
}

#pragma mark - FP Initialization stack
- (void)installFileProcessorWithCompletionBlock:(void (^)(BOOL, NSError *))block {
	CFErrorRef error = nil;
	Boolean blessed = SMJobBless(kSMDomainSystemLaunchd,
								 (__bridge CFStringRef)kFileProcessorSeriveName,
								 self->_authorizationRef,
								 &error);
	if (blessed) {
		MDTLog(@"FP was successfully installed.");
		[self connectToFileProcessorWithCompletionBlock:block];
	} else {
		MDTLog(@"FP was'nt installed, error: %@ | decoded error: %@", error,
			  [self humanReadableReasonForSMJobBlessErrorCode:[(__bridge NSError *)error code]]);
		CFRelease(error);
	}
}

- (void)connectToFileProcessorWithCompletionBlock:(void (^)(BOOL, NSError *))block {
	if (self.connectionStatus == kFPMediatorOutOfConnection) {
		block = [block copy];
		self.connectionStatus = kFPMediatorInConnectionProcess;
		MDTLog(@"Mediator: Starting connection to FP.");
		
		self.fileProcessorConnection = [[NSXPCConnection alloc] initWithMachServiceName:kFileProcessorSeriveName options:NSXPCConnectionPrivileged];
		self.fileProcessorConnection.remoteObjectInterface = [NSXPCInterface fileProcessorServiceInterface];
		
		__weak FIAFileProcessorMediator *weakSelf = self;
		[self.fileProcessorConnection setInvalidationHandler:^ {
			@synchronized (weakSelf) {
				if (weakSelf.running) {
					MDTLog(@"FP connection has been invalidated.");
					weakSelf.connectionStatus = kFPMediatorOutOfConnection;
				}
			}
		}];
		
		[self.fileProcessorConnection setInterruptionHandler:^ {
			@synchronized (weakSelf) {
				if (weakSelf.running) {
					MDTLog(@"FP connection has been interrupted.");
					weakSelf.connectionStatus = kFPMediatorOutOfConnection;
				}
			}
		}];
		
		[self.fileProcessorConnection resume];
		
		if (self.connectionStatus == kFPMediatorInConnectionProcess) {
			self.fileProcessor = [self.fileProcessorConnection remoteObjectProxyWithErrorHandler:^(NSError *iError) {
				MDTLog(@"Error -> Getting remote object proxy error %@", iError);
			}];
			
			if (self.fileProcessor) {
				[self.fileProcessor getVersionWithCompletionBlock:^(NSString *value, NSError *error) {
					MDTLog(@"Successfull connect to FP, version: %@", value);
					dispatch_async(dispatch_get_main_queue(), ^{
						self.connectionStatus = kFPMediatorInConnection;
						self.running = true;
						if (block) {
							block(true, nil);
						}
					});
				}];
				
			} else {
				MDTLog(@"Wasn't connected to FP: %@", self.fileProcessor);
				if (block) {
					block(false, nil); // TODO: Create error
				}
			}
		}
	} else if (self.connectionStatus == kFPMediatorInConnection) {
		MDTLog(@"Already connected to FP.");
		block(true, nil);
	} else {
		MDTLog(@"In connection process.");
		block(false, nil); // TODO: Create error
	}
}

#pragma mark - Private
- (NSString *)humanReadableReasonForSMJobBlessErrorCode:(NSInteger)errCode {
	NSString *errorString = nil;
	switch (errCode) {
		case kSMErrorInternalFailure:
			errorString = [NSString stringWithFormat:@"An internal failure has occurred."];
			break;
		case kSMErrorInvalidSignature:
			errorString = [NSString stringWithFormat:@"The Application's code signature does not meet the requirements to perform the operation."];
			break;
		case kSMErrorAuthorizationFailure:
			errorString = [NSString stringWithFormat:@"The request required authorization (i.e. adding a job to the {@link kSMDomainSystemLaunchd} domain) but the AuthorizationRef did not contain the required right."];
			break;
		case kSMErrorToolNotValid:
			errorString = [NSString stringWithFormat:@"The specified path does not exist or the tool at the specified path is not valid."];
			break;
		case kSMErrorJobNotFound:
			errorString = [NSString stringWithFormat:@"A job with the given label could not be found."];
			break;
		case kSMErrorServiceUnavailable:
			errorString = [NSString stringWithFormat:@"The service required to perform this operation is unavailable or is no longer accepting requests."];
			break;
		case kSMErrorJobPlistNotFound:
			errorString = [NSString stringWithFormat:@"Job plist not found"];
			break;
		case kSMErrorJobMustBeEnabled:
			errorString = [NSString stringWithFormat:@"Job must be enabled"];
			break;
		case kSMErrorInvalidPlist:
			errorString = [NSString stringWithFormat:@"Invalid plist"];
			break;
		default:
			errorString = [NSString stringWithFormat:@"Unknown error."];
			break;
	}
	return errorString;
}

- (BOOL)hasConnectionWithTool {
	BOOL result = true;
	if (!self.running) {
		MDTLog(@"Don't running.");
		result = false;
	} else if (self.connectionStatus != kFPMediatorInConnection) {
		MDTLog(@"Hasn't connection with FP.");
		result = false;
	}
	return result;
}

#pragma mark - FPFileProcessorService
- (void)getVersionWithCompletionBlock:(StringValueBlock)block {
	if (![self hasConnectionWithTool]) {
		return;
	}
	MDTLog(@"Get FP version.");
	[self.fileProcessor getVersionWithCompletionBlock:block];
}

- (void)getSHA1HashForFile:(NSString *)filePath withCompletionBlock:(StringValueBlock)block {
	if (![self hasConnectionWithTool]) {
		return;
	}
	MDTLog(@"Get SHA1 Hash for: %@", filePath);
	[self.fileProcessor getSHA1HashForFile:filePath withCompletionBlock:block];
}

- (void)getSizeForFile:(NSString *)filePath withCompletionBlock:(NumberValueBlock)block {
	if (![self hasConnectionWithTool]) {
		return;
	}
	MDTLog(@"Get size for: %@", filePath);
	[self.fileProcessor getSizeForFile:filePath withCompletionBlock:block];
}

- (void)removeFile:(NSString *)filePath withCompletionBlock:(void(^)(BOOL removed, NSError *error))block {
	if (![self hasConnectionWithTool]) {
		return;
	}
	MDTLog(@"Get size for: %@", filePath);
	[self.fileProcessor removeFile:filePath withCompletionBlock:block];
}

#pragma mark - LogsWrapper
void MDTLog(NSString *format, ...) {
	va_list args;
	va_start(args, format);
	NSLogv([NSString stringWithFormat:@"Mediator: %@", format], args);
	va_end(args);
}

@end
