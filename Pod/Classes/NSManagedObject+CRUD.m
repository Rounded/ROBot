//
//  NSManagedObject+CRUD.m
//  Pods
//
//  Created by Heather Snepenger on 4/27/15.
//
//

#import "NSManagedObject+CRUD.h"
#import "NSManagedObject+ROSerializer.h"
#import "ROBotManager.h"

@implementation NSManagedObject (CRUD)

+ (NSString *)indexURL {
    NSAssert(false, @"You did not set your indexURL");
    return nil;
}

- (NSString *)createURL {
    NSAssert(false, @"You did not set your createURL");
    return nil;
}

- (NSString *)readURL {
    NSAssert(false, @"You did not set your readURL");
    return nil;
}

- (NSString *)updateURL {
    NSAssert(false, @"You did not set your updateURL");
    return nil;
}

- (NSString *)deleteURL {
    NSAssert(false, @"You did not set your deleteURL");
    return nil;
}

#pragma mark — CRUD

- (void)create:(void (^)(void))complete failure:(void (^)(ROBotError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ROBotManager sharedInstance].baseURL, self.createURL]];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSError *error;
    [mutableURLRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[self asDictionary] options:0 error:&error]];
    [mutableURLRequest setHTTPMethod:@"POST"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:[NSString stringWithFormat:@"Bearer %@", [ROBotManager sharedInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL success = false;
        
        if ([self validateResponseForData:data andResponse:response andError:error]) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (jsonError != nil) {
                if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                    NSLog(@"Could not parse JSON: %@", jsonError.localizedDescription);
                }
            } else {
                success = [self saveToDatabase:json];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && complete) {
                // if successfully saved to the database and the success callback isn't nil
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    complete();
                }];
            } else if (failure) {
                // if the failure callback isn't nil, set the roboterror
                ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failure(error);
                }];
            }
        });
        
    }] resume];
}

- (void)read:(void (^)(void))complete failure:(void (^)(ROBotError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ROBotManager sharedInstance].baseURL, self.readURL]];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:[NSString stringWithFormat:@"Bearer %@", [ROBotManager sharedInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL success = false;
        
        if ([self validateResponseForData:data andResponse:response andError:error]) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (jsonError != nil) {
                if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                    NSLog(@"Could not parse JSON: %@", jsonError.localizedDescription);
                }
            } else {
                success = [self saveToDatabase:json];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && complete) {
                // if successfully saved to the database and the success callback isn't nil
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    complete();
                }];
            } else if (failure) {
                // if the failure callback isn't nil, set the roboterror
                ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failure(error);
                }];
            }
        });
        
    }] resume];
}

- (void)update:(void (^)(void))complete failure:(void (^)(ROBotError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ROBotManager sharedInstance].baseURL, self.updateURL]];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSError *error;
    [mutableURLRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[self asDictionary] options:0 error:&error]];
    [mutableURLRequest setHTTPMethod:@"PUT"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:[NSString stringWithFormat:@"Bearer %@", [ROBotManager sharedInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL success = false;
        
        if ([self validateResponseForData:data andResponse:response andError:error]) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (jsonError != nil) {
                if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                    NSLog(@"Could not parse JSON: %@", jsonError.localizedDescription);
                }
            } else {
                success = [self saveToDatabase:json];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && complete) {
                // if successfully saved to the database and the success callback isn't nil
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    complete();
                }];
            } else if (failure) {
                // if the failure callback isn't nil, set the roboterror
                ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    failure(error);
                }];
            }
        });
        
    }] resume];
}

- (void)delete:(void (^)(void))complete failure:(void (^)(ROBotError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ROBotManager sharedInstance].baseURL, self.deleteURL]];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSError *error;
    [mutableURLRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[self asDictionary] options:0 error:&error]];
    [mutableURLRequest setHTTPMethod:@"DELETE"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:[NSString stringWithFormat:@"Bearer %@", [ROBotManager sharedInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if ([self validateResponseForData:data andResponse:response andError:error]) {
            [self.managedObjectContext deleteObject:self];
            [self saveContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        complete();
                    }];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        failure(error);
                    }];
                }
            });
        }
        
    }] resume];
}

#pragma mark - CRUD Add-on Convenience Methods

+ (void)index:(void (^)(void))complete failure:(void (^)(ROBotError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ROBotManager sharedInstance].baseURL, [[self class] indexURL]]];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:[NSString stringWithFormat:@"Bearer %@", [ROBotManager sharedInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",responseString);
            NSLog(@"%@",response);
            NSLog(@"%@",error);
        }
        
        NSError *jsonError = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if (jsonError != nil) {
            if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                NSLog(@"Could not parse JSON: %@", jsonError.localizedDescription);
            }
        } else {
            // Create the context outside the enumeration block
            NSManagedObjectContext *context = [NSManagedObjectContext new];
            context.persistentStoreCoordinator = [[ROBotManager sharedInstance] persistentStoreCoordinator];
            [jsonArray enumerateObjectsUsingBlock:^(NSDictionary *jsonObject, NSUInteger idx, BOOL *stop) {
                
                // Check the database to see if the object in the JSON response exists already (based on the primary key)
                NSError *error = nil;
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", [[self class] primaryKey], jsonObject[[[self class] primaryKey]]]];
                
                NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
                if (objects.count > 0) {
                    // The object already exists in the database, so let's just update it
                    [[objects objectAtIndex:0] setDictionaryToCoreDataEntity:jsonObject];
                } else {
                    // The object doesn't exist in the database, so we need to create it
                    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
                    [newObject setDictionaryToCoreDataEntity:jsonObject];
                }
            }];
            // Save the context after all the objects have been created
            [NSManagedObject saveContext:context];
            if (complete) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    complete();
                }];
            }
        }
    }] resume];
}

+ (void)customRequestAtURL:(NSString *)urlString andMethod:(NSString *)httpMethod withCompletion:(void (^)(void))complete andFailure:(void (^)(ROBotError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ROBotManager sharedInstance].baseURL, urlString]];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    [mutableURLRequest setHTTPMethod:httpMethod.uppercaseString];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:[NSString stringWithFormat:@"Bearer %@", [ROBotManager sharedInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",responseString);
            NSLog(@"%@",response);
            NSLog(@"%@",error);
        }
        
        NSError *jsonError = nil;
        [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if (jsonError != nil) {
            if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                NSLog(@"Could not parse JSON: %@", jsonError.localizedDescription);
            }
        } else {
            NSMutableArray *jsonArray = [NSMutableArray new];
            if ([[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError] isKindOfClass:[NSArray class]]) {
                // the response is an array, so set it equal to jsonArray
                jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            } else {
                // if the response is not an array, let's just put it in an array and have it be an array of size 1
                [jsonArray addObject:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError]];
            }
            
            [jsonArray enumerateObjectsUsingBlock:^(NSDictionary *jsonObject, NSUInteger idx, BOOL *stop) {
                NSManagedObjectContext *context = [NSManagedObjectContext new];
                context.persistentStoreCoordinator = [[ROBotManager sharedInstance] persistentStoreCoordinator];
                
                // Check the database to see if the object in the JSON response exists already (based on the primary key)
                NSError *error = nil;
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"id", jsonObject[@"id"]]];
                
                NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
                if (objects.count > 0) {
                    // The object already exists in the database, so let's just update it
                    [[objects objectAtIndex:0] saveToDatabase:jsonObject];
                } else {
                    // The object doesn't exist in the database, so we need to create it
                    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
                    [newObject saveToDatabase:jsonObject];
                }
            }];
            if (complete) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    complete();
                }];
            }
        }
        
    }] resume];
}




#pragma mark — Helpers

- (BOOL)validateResponseForData:(NSData *)data andResponse:(NSURLResponse *)response andError:(NSError *)error {
    if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",responseString);
        NSLog(@"%@",response);
        NSLog(@"%@",error);
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode]==200 || [httpResponse statusCode]==201 || [httpResponse statusCode]==304) {
        return TRUE;
    }
    
    return FALSE;
}

- (BOOL)saveToDatabase:(NSDictionary *)json {
    [self setDictionaryToCoreDataEntity:json];
    return [self saveContext];
}

//- (void)setDictionaryToCoreDataEntity:(NSDictionary *)json {
//    NSArray *entityAttributes = [[[self entity] attributesByName] allKeys];
//    
//    // Get all the entity attributes and loop through them, setting the JSON data to the values if they exist
//    [entityAttributes enumerateObjectsUsingBlock:^(NSString *entityAttribute, NSUInteger idx, BOOL *stop) {
//        if ([json objectForKey:entityAttribute] && [json objectForKey:entityAttribute] != [NSNull null]) {
//            [self setValue:[json objectForKey:entityAttribute] forKey:entityAttribute];
//        }
//    }];
//}



- (NSDictionary *)asDictionary {
    return [self dictionaryWithValuesForKeys:[[[self entity] attributesByName] allKeys]];
}

@end