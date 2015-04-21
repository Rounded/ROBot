//
//  ROBotManagedObject.h
//  scoutlook
//
//  Created by bw on 4/13/15.
//  Copyright (c) 2015 rounded. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ROBotError.h"

@interface ROBotManagedObject : NSManagedObject

@property (nonatomic, retain) NSString *primaryKey;

+ (NSString *)indexURL;

- (void)create:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;
- (void)read:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;
- (void)update:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;
- (void)delete:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;

// These three methods aren't using the failure callback yet!
+ (void)index:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;
- (void)save:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;
+ (void)customRequestAtURL:(NSString *)urlString andMethod:(NSString *)httpMethod withCompletion:(void (^)(void))complete andFailure:(void (^)(ROBotError *))failure;


@end
