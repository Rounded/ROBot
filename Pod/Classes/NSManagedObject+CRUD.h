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

+ (NSString *)indexURL;
+ (void)index:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;
- (NSString *)createURL;
- (NSString *)readURL;
- (NSString *)updateURL;
- (NSString *)deleteURL;

- (void)create:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;
- (void)read:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;
- (void)update:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;
- (void)delete:(void (^)(void))complete failure:(void (^)(ROBotError *))failure;

@end
