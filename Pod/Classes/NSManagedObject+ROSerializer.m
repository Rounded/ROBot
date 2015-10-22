//
//  NSManagedObject+ROSerializer.m
//  Pods
//
//  Created by Heather Snepenger on 4/27/15.
//
//

#import "NSManagedObject+ROSerializer.h"
#import "ROBotManager.h"
#import <objc/runtime.h>

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

+ (NSArray *)serializableRelationships {
    return [NSArray new];
}

- (BOOL)setDictionaryToCoreDataEntity:(NSDictionary *)json {
    return [self setDictionaryToCoreDataEntity:json inScratchContext:FALSE];
}

- (BOOL)setDictionaryToCoreDataEntity:(NSDictionary *)json inScratchContext:(BOOL)inScratchContext {
    if (json.count == 0)
        return false;
    
    if (!inScratchContext) {
        NSManagedObjectContext *context = [NSManagedObjectContext new];
        if (!self.managedObjectContext) {
            context.persistentStoreCoordinator = [[ROBotManager sharedInstance] persistentStoreCoordinator];
            [context insertObject:self];
        }
    }

    // pull out the attributes that exist in the database
    NSEntityDescription *entity = self.entity;
    NSDictionary *attributes = entity.attributesByName;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:nil];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    // Update all the key / values for the object
    [json enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        // If it's a date and the object coming down is a string, convert it to a NSDate
        if ([[attributes[key] attributeValueClassName] isEqualToString:@"NSDate"] && [obj isKindOfClass:[NSString class]]) {
            // use detector to figure out what format its in and convert it
            // will convert to NULL if it can't convert (which is good since it was a string, which will cause it to error below)
            __block id newDateObj = NULL;
            // [detector enumerateMatchesInString:obj options:kNilOptions range:NSMakeRange(0, [obj length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            //     if ([result resultType] == NSTextCheckingTypeDate) {
            //         newDateObj = result.date;
            //     }
            // }];
            if (newDateObj == nil) {
                // couldn't use the match, maybe its a Rails 4.0 format
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                newDateObj = [dateFormatter dateFromString:obj];
            }
            if (newDateObj == nil) {
                // it's still nil, let's try one other JSON format
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                newDateObj = [dateFormatter dateFromString:obj];
            }
            obj = newDateObj;
        }
        
        // If it's a date and the object coming down is a string, convert it to a NSDate
        if ([[attributes[key] attributeValueClassName] isEqualToString:@"NSDecimalNumber"] && [obj isKindOfClass:[NSString class]]) {
            obj = [NSDecimalNumber decimalNumberWithString:obj];
        }
        
        // If the object exists in the mapping, use the mapping
        if ([[self class] mapping] && [[[self class] mapping] objectForKey:key]) {
            [self setValue:obj forKey:[[[self class] mapping] objectForKey:key]];
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
    NSArray *entities;
    if (self.managedObjectContext) {
        entities = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel.entities;
    } else {
        // In case of a scratch object
        entities = [ROBotManager sharedInstance].persistentStoreCoordinator.managedObjectModel.entities;
    }
    for (NSEntityDescription *entity in entities) {
        NSArray *relationships = [self.entity relationshipsWithDestinationEntity:entity];
        for (NSRelationshipDescription *relationshipDescription in relationships) {
            
            if (json[relationshipDescription.name] == (id)[NSNull null]) {
                // if the object we receive is null, don't setup the relationship

            } else {
                
                // If the json has the relationship already
                if (json[relationshipDescription.name] && json[relationshipDescription.name] != [NSNull null]) {
                    if (relationshipDescription.isToMany) {
                        // If the relationship is toMany, make sure that the corresponding json object is an array
                        assert([json[relationshipDescription.name] isKindOfClass:[NSArray class]]);
                        
                        NSMutableSet *relationshipObjects = [NSMutableSet new];
                        for (NSDictionary *childObject in json[relationshipDescription.name]) {
                            NSManagedObject *object = [self createOrUpdateObject:childObject forEntityName:entity.name];
                            [relationshipObjects addObject:object];
                            // if the relationship is many-to-many, add "self" to the set of current objects in the inverse relationship
//                            if (relationshipDescription.inverseRelationship.toMany) {
//                                NSMutableSet *currentObjectsInRelationship = [[object valueForKeyPath:relationshipDescription.inverseRelationship.name] mutableCopy];
//                                [currentObjectsInRelationship addObject:self];
//                                [object setValue:currentObjectsInRelationship forKey:relationshipDescription.inverseRelationship.name];
//                            } else {
                                // Set the to-many relationship
                                [self setValue:relationshipObjects forKey:relationshipDescription.name];
//                            }
                        }
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

    // find the NSEntityDescription by entityName
    __block NSEntityDescription *entity;
    [[[[ROBotManager sharedInstance].persistentStoreCoordinator managedObjectModel] entitiesByName] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:entityName]) {
            entity = obj;
        }
    }];
    
    // check to see if the entity has the primary key as an attribute (it *should* but might not in edge cases)
    BOOL entityContainsDictionaryPrimaryKey = [[entity.attributesByName allKeys] containsObject:[[self class] primaryKey]];
    // check to see if the dictionary contains the primary key
    BOOL dictionaryContainsClassPrimaryKey = [[dictionary allKeys] containsObject:[[self class] primaryKey]];
    
    if(dictionaryContainsClassPrimaryKey == FALSE || entityContainsDictionaryPrimaryKey == FALSE) {
        // if the dictionary doesn't include the Entity primaryKey
        // or the class doesn't have the default primaryKey ("id") as listed in the dictionary (this is an edge case)
        // then we skip it the find, and we clear out all the relationships and just replace the objects
        return nil;
    }
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", [[self class] primaryKey], dictionary[[[self class] primaryKey]]]];
    
    NSArray *objects;
    
    if (!self.managedObjectContext) {
        NSManagedObjectContext *context = [ROBot newChildContext];
        context.persistentStoreCoordinator = [[ROBotManager sharedInstance] persistentStoreCoordinator];
        objects = [context executeFetchRequest:fetchRequest error:&error];
        if (objects.count > 0) {
            NSManagedObject *object = objects[0];
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
        if (self.managedObjectContext) {
            object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
        } else {
            // Handle the case where the parent is a scratch object
            object = [NSClassFromString(entityName) newInScratchContext:[ROBot newChildContext]];
        }
        [object setDictionaryToCoreDataEntity:childObject];
    }
    return object;
}

- (BOOL)saveContext {
    NSManagedObjectContext *context;
    if (self.managedObjectContext) {
        context = self.managedObjectContext;
    } else {
        context = [ROBot newChildContext];
        [context insertObject:self];
    }
    
    [NSManagedObject saveContext:context];
    return true;
}

+ (BOOL)saveContext:(NSManagedObjectContext *)context {
    
    __block BOOL returnFlag = TRUE;
    
    [context performBlockAndWait:^{
        NSError *error = nil;
        if (context.hasChanges && ![context save:&error]) {
            if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                NSLog(@"Could not save context: %@", error.localizedDescription);
            }
            returnFlag = FALSE;
        }
    }];
    
    
    if (context.parentContext) {
//        [context.parentContext performBlockAndWait:^{
            NSError *error = nil;
            if (context.parentContext.hasChanges && ![context.parentContext save:&error]) {
                if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                    NSLog(@"Could not save context: %@", error.localizedDescription);
                }
                returnFlag = FALSE;
            }
//        }];
    }
    
    return returnFlag;
}

- (BOOL)saveToDatabase:(NSDictionary *)json {
    if (self.managedObjectContext) {
        if ([self setDictionaryToCoreDataEntity:json]) {
            return [self saveContext];
        } else {
            return false;
        }
    } else {
        // object doesnt have a managedobjectcontext, so it's likely a scratch object
        // check to see if the object already exists in our database by checking primaryKey
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", [[self class] primaryKey], json[[[self class] primaryKey]]]];
        NSArray *objects;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        context.persistentStoreCoordinator = [[ROBotManager sharedInstance] persistentStoreCoordinator];
        objects = [context executeFetchRequest:fetchRequest error:&error];
        
        if (objects.count > 0) {
            // assign the object found to the values of the scratchObject
            // object already exists in our database, so let's just update / save that one
            if ([objects[0] setDictionaryToCoreDataEntity:json]) {
                return [objects[0] saveContext];
            } else {
                return false;
            }
        } else {
            // the scratch object doesn't exist in our database yet, so let's just save it
            if([self setDictionaryToCoreDataEntity:json]) {
                return [self saveContext];
            } else {
                return FALSE;
            }
        }
    }
    return FALSE;
}

- (NSDictionary *)asDictionary {
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormmater setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDictionary *attribDict = [self dictionaryWithValuesForKeys:[[[self entity] attributesByName] allKeys]];
    NSMutableDictionary *objectDict = [NSMutableDictionary dictionaryWithDictionary:attribDict];
    [objectDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        // Can't handle NSData yet...
        if ([obj isKindOfClass:[NSData class]]) {
            [objectDict removeObjectForKey:key];
        }
        
        // handle NSDates to JSON
        if ([obj isKindOfClass:[NSDate class]]) {
            [objectDict setValue:[dateFormmater stringFromDate:obj] forKey:key];
        }
        
        
    }];
    
    NSDictionary *relationshipDict = [self dictionaryWithValuesForKeys:[[[self entity] relationshipsByName] allKeys]];
    [[[self class] serializableRelationships] enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        id obj = relationshipDict[key];
        // if the relationship is one to one, serialize the object
        if ([obj isKindOfClass:[NSManagedObject class]]) {
            objectDict[key] = [((NSManagedObject *)obj) asDictionary];
        } else if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSSet class]]) {
            // If the relationship is one to many, serialize the array
            NSMutableArray *childObjects = [NSMutableArray new];
            NSSet *toManyRel = obj;
            [toManyRel enumerateObjectsUsingBlock:^(NSManagedObject *childObject, BOOL *stop) {
                [childObjects addObject:[childObject asDictionary]];
            }];
            
            objectDict[key] = childObjects;
        }
    }];
    return objectDict;
}

- (BOOL)isNew {
    NSDictionary *vals = [self committedValuesForKeys:nil];
    return [vals count] == 0;
}

+ (NSManagedObject *)newInScratchContext:(NSManagedObjectContext *)context {
    // FIX: Should attempt to get the actual main context, not just creating a new one!
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    return [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
}

- (id)inContext:(NSManagedObjectContext *)otherContext {
    NSError *error = nil;
    
    if ([[self objectID] isTemporaryID]) {
        BOOL success = [[self managedObjectContext] obtainPermanentIDsForObjects:@[self] error:&error];
        if (!success) {
            return nil;
        }
    }
    
    error = nil;
    
    // Fetch the object from the database
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", [[self class] primaryKey], [self valueForKey:[[self class] primaryKey]]]];
    NSArray *objects;
    objects = [otherContext executeFetchRequest:fetchRequest error:&error];
    if (objects.count > 0) {
        return objects[0];
    } else {
        // if the object hasn't been saved yet, and isn't in the database, create a new instance and return
        return [[self class] newInScratchContext:otherContext];
    }
}

@end
