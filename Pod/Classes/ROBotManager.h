//
//  ROBotManager.h
//  scoutlook
//
//  Created by bw on 4/13/15.
//  Copyright (c) 2015 rounded. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ROBotManager : NSObject

+ (instancetype)sharedInstance;
+ (void)initializeWithBaseURL:(NSString *)baseURL;

@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic) BOOL verboseLogging;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
