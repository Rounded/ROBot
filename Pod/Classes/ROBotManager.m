//
//  ROBotManager.m
//  scoutlook
//
//  Created by bw on 4/13/15.
//  Copyright (c) 2015 rounded. All rights reserved.
//

#import "ROBotManager.h"
#import "NSManagedObject+CRUD.h"
#import "ROReachability.h"

static ROBotManager *ROBotManagerInstance = nil;

@implementation ROBotManager

@synthesize baseURL = _baseURL;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ROBotManagerInstance = [[ROBotManager alloc] init];
        
        // Allocate a reachability object
        ROReachability* reach = [ROReachability reachabilityForInternetConnection];
        
        // Set the blocks
        reach.reachableBlock = ^(ROReachability*reach)
        {
            [ROBotManagerInstance uploadCachedData];
        };
        
        reach.unreachableBlock = ^(ROReachability*reach)
        {

        };
        
        // Start the notifier, which will cause the reachability object to retain itself!
        [reach startNotifier];
    });
    
    return ROBotManagerInstance;
}

+ (void)initializeWithBaseURL:(NSString *)baseURL {
    [ROBotManager sharedInstance].baseURL = baseURL;
}

+ (void)initializeWithBaseURL:(NSString *)baseURL andPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator{
    [ROBotManager sharedInstance].baseURL = baseURL;
    [ROBotManager sharedInstance].persistentStoreCoordinator = coordinator;
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

+ (NSString *) cacheType:(CRUD)crudType {
    switch (crudType) {
        case CREATE:
            return @"create_cache";
            break;
        case READ:
            return @"read_cache";
            break;
        case UPDATE:
            return @"update_cache";
            break;
        case DELETE:
            return @"delete_cache";
            break;
        default:
            break;
    }
    return @"";
}

- (void)uploadCachedData {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSManagedObjectContext *context = [NSManagedObjectContext new];
    context.persistentStoreCoordinator = self.persistentStoreCoordinator;

    NSArray *create_ids = [defaults stringArrayForKey:[ROBotManager cacheType:CREATE]];
    if (create_ids) {
        for (NSString *id in create_ids) {
            NSManagedObjectID *moId = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:id]];
            NSManagedObject *object = [context objectWithID:moId];
            [object create:nil failure:nil];
            
            if (self.verboseLogging) {
                NSLog(@"creating object: %@", object);
            }
        }
    }
    
    NSArray *update_ids = [defaults stringArrayForKey:[ROBotManager cacheType:UPDATE]];
    if (update_ids) {
        for (NSString *id in update_ids) {
            NSManagedObjectID *moId = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:id]];
            NSManagedObject *object = [context objectWithID:moId];
            [object update:nil failure:nil];
            
            if (self.verboseLogging) {
                NSLog(@"updating object: %@", object);
            }
        }
    }
    
    NSArray *delete_ids = [defaults stringArrayForKey:[ROBotManager cacheType:DELETE]];
    if (delete_ids) {
        for (NSString *id in delete_ids) {
            NSManagedObjectID *moId = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:id]];
            NSManagedObject *object = [context objectWithID:moId];
            [object create:nil failure:nil];
            
            if (self.verboseLogging) {
                NSLog(@"deleting object: %@", object);
            }
        }
    }
    
    [defaults removeObjectForKey:[ROBotManager cacheType:CREATE]];
    [defaults removeObjectForKey:[ROBotManager cacheType:UPDATE]];
    [defaults removeObjectForKey:[ROBotManager cacheType:DELETE]];
    [defaults synchronize];

}



@end
