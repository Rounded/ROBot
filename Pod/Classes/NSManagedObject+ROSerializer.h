//
//  NSManagedObject+ROSerializer.h
//  Pods
//
//  Created by Heather Snepenger on 4/27/15.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ROSerializer)

+ (NSDictionary *)mapping;
+ (void)setMapping:(NSDictionary *)mapping;
+ (NSString *)primaryKey;
+ (void)setPrimaryKey:(NSString *)primaryKey;
- (BOOL)setDictionaryToCoreDataEntity:(NSDictionary *)json;
- (BOOL)saveContext;
+ (BOOL)saveContext:(NSManagedObjectContext *)context;
- (BOOL)saveToDatabase:(NSDictionary *)json;
- (NSDictionary *)asDictionary;

- (BOOL)isNew;
+ (NSManagedObject *)newInScratchContext;
- (instancetype)copyToScratchContext;

@end
