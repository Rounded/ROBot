//
//  NSManagedObject+CRUD.h
//  Pods
//
//  Created by Heather Snepenger on 4/27/15.
//
//

#import <CoreData/CoreData.h>
#import "ROBotError.h"

@interface NSManagedObject (CRUD)

- (NSString *)createURL;
- (NSString *)readURL;
- (NSString *)updateURL;
- (NSString *)deleteURL;

+ (NSString *)indexURL;

- (void)create:(void (^)(void))complete failure:(void (^)(ROBotError *error))failure;
- (void)read:(void (^)(void))complete failure:(void (^)(ROBotError *error))failure;
- (void)update:(void (^)(void))complete failure:(void (^)(ROBotError *error))failure;
- (void)delete:(void (^)(void))complete failure:(void (^)(ROBotError *error))failure;

- (void)save:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;

+ (void)index:(void (^)(void))complete failure:(void (^)(ROBotError *error))failure;
+ (void)indexWithDeletePredicate:(NSString *)deletePredicate complete:(void (^)(void))complete failure:(void (^)(ROBotError *error))failure;

+ (void)customRequestAtURL:(NSString *)urlString andBody:(NSDictionary *)body andMethod:(NSString *)httpMethod withCompletion:(void (^)(NSData *data, NSURLResponse *response))complete andFailure:(void (^)(ROBotError *))failure;
+ (void)customRequestAtURL:(NSString *)urlString andBody:(NSDictionary *)body andMethod:(NSString *)httpMethod andShouldPersist:(BOOL)shouldPersist withCompletion:(void (^)(NSData *data, NSURLResponse *response))complete andFailure:(void (^)(ROBotError *))failure;
+ (void)customRequestAtURL:(NSString *)urlString andHeaders:(NSDictionary *)headers andBody:(NSDictionary *)body andMethod:(NSString *)httpMethod withCompletion:(void (^)(NSData *data, NSURLResponse *response))complete andFailure:(void (^)(ROBotError *))failure;
+ (void)customRequestAtURL:(NSString *)urlString andHeaders:(NSDictionary *)headers andBody:(NSDictionary *)body andMethod:(NSString *)httpMethod andDeletePredicate:(NSString *)deletePredicate withCompletion:(void (^)(NSData *data, NSURLResponse *response))complete andFailure:(void (^)(ROBotError *))failure;

@end
