//
//  NSManagedObject+ROSerializer.m
//  Pods
//
//  Created by Heather Snepenger on 4/27/15.
//
//

#import "NSManagedObject+ROSerializer.h"
#import "ROBotManager.h"

@implementation NSManagedObject (ROSerializer)

static NSDictionary *customMapping;
static NSString *pk = @"id";

+ (NSDictionary *)mapping {
    return customMapping;
}

+ (void)setMapping:(NSDictionary *)mapping {
    customMapping = mapping;
}

+ (NSString *)primaryKey {
    return pk;
}

+ (void)setPrimaryKey:(NSString *)primaryKey {
    pk = primaryKey;
}

- (void)setDictionaryToCoreDataEntity:(NSDictionary *)json {
    // pull out the attributes that exist in the database
    NSEntityDescription *entity = self.entity;
    NSDictionary *attributes = entity.attributesByName;
    
    
    // Update all the key / values for the object
    [json enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        // If the object exists in the mapping, use the mapping
        if ([NSManagedObject mapping] && [[NSManagedObject mapping] objectForKey:key]) {
            [self setValue:obj forKey:[[NSManagedObject mapping] objectForKey:key]];
        }
        // Otherwise assign the value to the corresponding value in the db
        else {
            // If the key is an element in the db, and if the object isn't null
            if (attributes[key] && obj && obj && obj != (id)[NSNull null]) {
                [self setValue:obj forKey:key];
            }
        }
    }];

    
    
    // Handle relationships
    NSArray *entities = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities;
    for (NSEntityDescription *entity in entities) {
        NSArray *relationships = [self.entity relationshipsWithDestinationEntity:entity];
        for (NSRelationshipDescription *relationshipDescription in relationships) {

            // If the json has the relationship already
            if (json[relationshipDescription.name]) {
                if (relationshipDescription.isToMany) {
                    // If the relationship is toMany, make sure that the corresponding json object is an array
                    assert([json[relationshipDescription.name] isKindOfClass:[NSArray class]]);

                    NSMutableSet *relationshipObjects = [NSMutableSet new];
                    for (NSDictionary *childObject in json[relationshipDescription.name]) {
                        [relationshipObjects addObject:[self createOrUpdateObject:childObject forEntityName:entity.name]];
                    }
                    // Set the to-many relationship
                    [self setValue:relationshipObjects forKey:relationshipDescription.name];
                } else {
                    // If the relationship isn't toMany, make sure that the corresponding json object is a dictionary
                    assert([json[relationshipDescription.name] isKindOfClass:[NSDictionary class]]);
                    // Set the relationship
                    [self setValue:[self createOrUpdateObject:json[relationshipDescription.name] forEntityName:entity.name] forKey:relationshipDescription.name];
                }
            }
        }
    }
}

- (NSManagedObject *)createOrUpdateObject:(NSDictionary *)childObject forEntityName:(NSString *)entityName {
    
    NSManagedObject *object;
    
    // Check the database to see if the object in the JSON response exists already (based on the primary key)
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", [[self class] primaryKey], childObject[[[self class] primaryKey]]]];
    
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (objects.count > 0) {
        object = [objects objectAtIndex:0];
        // The object already exists in the database, so let's just update it
        [object setDictionaryToCoreDataEntity:childObject];
    } else {
        // The object doesn't exist in the database, so we need to create it
        object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
        [object setDictionaryToCoreDataEntity:childObject];
    }
    return object;
}

- (BOOL)saveContext {
    NSManagedObjectContext *context;
    if (self.managedObjectContext) {
        context = self.managedObjectContext;
    } else {
        context = [NSManagedObjectContext new];
        context.persistentStoreCoordinator = [[ROBotManager sharedInstance] persistentStoreCoordinator];
        [context insertObject:self];
    }
    NSError *error = nil;
    
    if (context.hasChanges && ![context save:&error]) {
        if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
            NSLog(@"Could not save context: %@", error.localizedDescription);
        }
        return FALSE;
    }
    
    if (context.parentContext) {
        if (context.parentContext.hasChanges && ![context.parentContext save:&error]) {
            if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                NSLog(@"Could not save context: %@", error.localizedDescription);
            }
            return FALSE;
        }
    }
    
    return TRUE;
}

+ (BOOL)saveContext:(NSManagedObjectContext *)context {

    NSError *error = nil;
    
    if (context.hasChanges && ![context save:&error]) {
        if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
            NSLog(@"Could not save context: %@", error.localizedDescription);
        }
        return FALSE;
    }
    
    if (context.parentContext) {
        if (context.parentContext.hasChanges && ![context.parentContext save:&error]) {
            if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                NSLog(@"Could not save context: %@", error.localizedDescription);
            }
            return FALSE;
        }
    }
    
    return TRUE;
}

- (BOOL)saveToDatabase:(NSDictionary *)json {
    [self setDictionaryToCoreDataEntity:json];
    return [self saveContext];
}

- (NSDictionary *)asDictionary {
    return [self dictionaryWithValuesForKeys:[[[self entity] attributesByName] allKeys]];
}

@end
