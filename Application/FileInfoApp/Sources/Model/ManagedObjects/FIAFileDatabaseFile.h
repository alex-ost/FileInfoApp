//
//  FIAFileDatabaseFile.h
//  FileInfoApp
//
//  Created by Alex Ostrynskyi on 02/01/2017.
//  Copyright © 2017 AlexOst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FIAFileDatabaseFile : NSManagedObject

@property (nonatomic, retain) NSDate *addTime;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *sha1Hash;
@property (nonatomic, retain) NSNumber *size;

@end
