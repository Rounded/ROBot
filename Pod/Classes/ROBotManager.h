//
//  ROBotManager.h
//  scoutlook
//
//  Created by bw on 4/13/15.
//  Copyright (c) 2015 rounded. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ROBot.h"

typedef NS_ENUM(NSInteger, CRUD) {
    CREATE,
    READ,
    UPDATE,
    DELETE,
    CUSTOM
};

@interface ROBotManager : NSObject

+ (instancetype)sharedInstance;
+ (void)initializeWithBaseURL:(NSString *)baseURL;
+ (void)initializeWithBaseURL:(NSString *)baseURL andPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator;

+ (NSString *) cacheType:(CRUD)crudType;

- (void)addHeaderValue:(NSString *)headerValue forHeaderField:(NSString *)headerField;

@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSMutableArray *headers;
@property (nonatomic) BOOL verboseLogging;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSManagedObjectContext *mainContext;

- (void)cancelAllTasks;

@end
