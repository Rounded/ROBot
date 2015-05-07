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

- (BOOL)setDictionaryToCoreDataEntity:(NSDictionary *)json {
    if (json.count == 0)
        return false;
    
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
            
            if (json[relationshipDescription.name] == (id)[NSNull null]) {
                // if the object we receive is null, don't setup the relationship

            } else {
                
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
    return true;
}

- (NSManagedObject *)findObjectFromDictionary:(NSDictionary *)dictionary forEntityName:(NSString *)entityName {
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", [[self class] primaryKey], dictionary[[[self class] primaryKey]]]];
    
    NSArray *objects;
    
    if (!self.managedObjectContext) {
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        context.persistentStoreCoordinator = [[ROBotManager sharedInstance] persistentStoreCoordinator];
        objects = [context executeFetchRequest:fetchRequest error:&error];
        if (objects.count > 0) {
            NSManagedObject *object = objects[0];
            NSLog(@"%@",[((NSManagedObject *)object) valueForKey:@"id"]);
            return object;
        }
    } else {
        objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (objects.count > 0) {
            return [objects objectAtIndex:0];
        }
    }
    
    return nil;
}

- (NSManagedObject *)createOrUpdateObject:(NSDictionary *)childObject forEntityName:(NSString *)entityName {
    
    NSManagedObject *object = [self findObjectFromDictionary:childObject forEntityName:entityName];
    
    if (object != nil) {
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
    if (self.managedObjectContext) {
        if ([self setDictionaryToCoreDataEntity:json]) {
            return [self saveContext];
        } else {
            return false;
        }
    } else {
        
        // Holy fuck we should refactor this later!
        
        // object doesnt have a managedobjectcontext, so it's likely a scratch object
        // check to see if the object already exists in our database by checking primaryKey
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", [[self class] primaryKey], json[[[self class] primaryKey]]]];
        NSArray *objects;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        context.persistentStoreCoordinator = [[ROBotManager sharedInstance] persistentStoreCoordinator];
        objects = [context executeFetchRequest:fetchRequest error:&error];
        NSManagedObject *object = objects[0];

        if (objects.count > 0) {
            // assign the object found to the values of the scratchObject
            // object already exists in our database, so let's just update / save that one
            if ([object setDictionaryToCoreDataEntity:json]) {
                return [object saveContext];
            } else {
                return false;
            }
        } else {
            // the scratch object doesn't exist in our database yet, so let's just save it
            if([self setDictionaryToCoreDataEntity:json]) {
                [self saveContext];
            } else {
                return FALSE;
            }
        }
    }
    return FALSE;
}

- (NSDictionary *)asDictionary {
    return [self dictionaryWithValuesForKeys:[[[self entity] attributesByName] allKeys]];
}


+ (NSManagedObject *)newInScratchContext {
    // FIX: Should attempt to get the actual main context, not just creating a new one!
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = [[ROBotManager sharedInstance] persistentStoreCoordinator];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    return [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
}

- (instancetype)copyToSameContext {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:self.objectID.entity.name inManagedObjectContext:self.managedObjectContext];
    [self duplicateObject:object];
    return object;
}

- (instancetype)copyToScratchContext {
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:self.entity insertIntoManagedObjectContext:nil];
    [self duplicateObject:object];
    return object;
}

- (void)duplicateObject:(NSManagedObject *)object {
    NSEntityDescription *entityDescription = self.objectID.entity;
    NSArray *attributeKeys = entityDescription.attributesByName.allKeys;
    NSDictionary *attributeKeysAndValues = [self dictionaryWithValuesForKeys:attributeKeys];
    [object setValuesForKeysWithDictionary:attributeKeysAndValues];
}

@end
