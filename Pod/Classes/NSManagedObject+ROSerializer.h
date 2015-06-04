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
+ (NSArray *)serializableRelationships;
- (BOOL)setDictionaryToCoreDataEntity:(NSDictionary *)json;
- (BOOL)setDictionaryToCoreDataEntity:(NSDictionary *)json inScratchContext:(BOOL)inScratchContext;
- (BOOL)saveContext;
+ (BOOL)saveContext:(NSManagedObjectContext *)context;
- (BOOL)saveToDatabase:(NSDictionary *)json;
- (NSDictionary *)asDictionary;

- (BOOL)isNew;
+ (NSManagedObject *)newInScratchContext:(NSManagedObjectContext *)context;
- (instancetype)copyToScratchContext;
- (id) inContext:(NSManagedObjectContext *)otherContext;

@end
