//
//  ROBotManager.m
//  scoutlook
//
//  Created by bw on 4/13/15.
//  Copyright (c) 2015 rounded. All rights reserved.
//

#import "ROBotManager.h"

static ROBotManager *ROBotManagerInstance = nil;

@implementation ROBotManager

@synthesize baseURL = _baseURL;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ROBotManagerInstance = [[ROBotManager alloc] init];
    });
    
    return ROBotManagerInstance;
}

+ (void)initializeWithBaseURL:(NSString *)baseURL {
    [ROBotManager sharedInstance].baseURL = baseURL;
}

- (NSString *)baseURL {
    NSAssert(_baseURL, @"You did not set your baseURL");
    return _baseURL;
}

- (BOOL)verboseLogging {
    if (!_verboseLogging) {
        _verboseLogging = FALSE;
    }
    return _verboseLogging;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    NSAssert(_persistentStoreCoordinator, @"You did not set your persistent store coordinator");
    return _persistentStoreCoordinator;
}

@end
