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

+ (NSString *)indexURL {
    NSAssert(false, @"You did not set your indexURL");
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
    [[ROBotManager sharedInstance].headers enumerateObjectsUsingBlock:^(NSDictionary *headerDictionary, NSUInteger idx, BOOL *stop) {
        [mutableURLRequest setValue:[headerDictionary valueForKey:@"headerValue"] forHTTPHeaderField:[headerDictionary valueForKey:@"headerField"]];
    }];
    [NSManagedObject printLogsForRequest:mutableURLRequest];
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL success = false;

        [NSManagedObject printLogsForResponse:response data:data error:error];
        
        if ([self didCacheOffline:response crudType:CREATE]) {
            success = TRUE;
        } else if ([NSManagedObject validateStatusCodeForResponse:response withCrudType:CREATE]) {
            
            if (data == nil) {
                // if the data is nil, don't try to parse it
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                        failure(error);
                    }
                });
                return;
            }
            
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (jsonError != nil) {
                if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                    NSLog(@"Could not parse JSON: %@", jsonError.localizedDescription);
                }
            } else {
                if (self.managedObjectContext) {
                    success = [self saveToDatabase:json];
                } else {
                    NSManagedObjectContext *context = [ROBot newChildContext];
                    success = [[self inContext:context] saveToDatabase:json];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && complete) {
                // if successfully saved to the database and the success callback isn't nil
                complete();
            } else if (failure) {
                // if the failure callback isn't nil, set the roboterror
                ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                failure(error);
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
    NSString *etag = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"etag%@", [self readURL]]];
    [mutableURLRequest addValue:etag forHTTPHeaderField:@"If-None-Match"];
    [[ROBotManager sharedInstance].headers enumerateObjectsUsingBlock:^(NSDictionary *headerDictionary, NSUInteger idx, BOOL *stop) {
        [mutableURLRequest setValue:[headerDictionary valueForKey:@"headerValue"] forHTTPHeaderField:[headerDictionary valueForKey:@"headerField"]];
    }];
    [NSManagedObject printLogsForRequest:mutableURLRequest];
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // If the server returned a 304, leave the method
        if (((NSHTTPURLResponse *)response).statusCode == 304) {
            if (complete) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete();
                });
            }
            return;
        }
        
        // If the response is valid, save the etag
        NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[headers valueForKey:@"Etag"] forKey:[NSString stringWithFormat:@"etag%@", [self readURL]]];
        [defaults synchronize];
        
        BOOL success = false;

        [NSManagedObject printLogsForResponse:response data:data error:error];
        
        if ([NSManagedObject validateStatusCodeForResponse:response withCrudType:READ]) {
            
            if (data == nil) {
                // if the data is nil, don't try to parse it
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                        failure(error);
                    }
                });
                return;
            }

            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (jsonError != nil) {
                if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                    NSLog(@"Could not parse JSON: %@", jsonError.localizedDescription);
                }
            } else {
                // Save in the background context
                NSManagedObjectContext *context = [ROBot newChildContext];
                success = [[self inContext:context] saveToDatabase:json];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && complete) {
                // if successfully saved to the database and the success callback isn't nil
                complete();
            } else if (failure) {
                // if the failure callback isn't nil, set the roboterror
                ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                failure(error);
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
    [[ROBotManager sharedInstance].headers enumerateObjectsUsingBlock:^(NSDictionary *headerDictionary, NSUInteger idx, BOOL *stop) {
        [mutableURLRequest setValue:[headerDictionary valueForKey:@"headerValue"] forHTTPHeaderField:[headerDictionary valueForKey:@"headerField"]];
    }];
    [NSManagedObject printLogsForRequest:mutableURLRequest];
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL success = false;

        [NSManagedObject printLogsForResponse:response data:data error:error];
        
        if ([self didCacheOffline:response crudType:UPDATE]) {
            success = TRUE;
        } else if ([NSManagedObject validateStatusCodeForResponse:response withCrudType:UPDATE]) {
            if (data == nil) {
                // if the data is nil, don't try to parse it
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                        failure(error);
                    }
                });
                return;
            }

            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (jsonError != nil) {
                if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                    NSLog(@"Could not parse JSON: %@", jsonError.localizedDescription);
                }
            } else {
                if (self.managedObjectContext) {
                    success = [self saveToDatabase:json];
                } else {
                    NSManagedObjectContext *context = [ROBot newChildContext];
                    success = [[self inContext:context] saveToDatabase:json];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && complete) {
                // if successfully saved to the database and the success callback isn't nil
                complete();
            } else if (failure) {
                // if the failure callback isn't nil, set the roboterror
                ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                failure(error);
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
    [[ROBotManager sharedInstance].headers enumerateObjectsUsingBlock:^(NSDictionary *headerDictionary, NSUInteger idx, BOOL *stop) {
        [mutableURLRequest setValue:[headerDictionary valueForKey:@"headerValue"] forHTTPHeaderField:[headerDictionary valueForKey:@"headerField"]];
    }];
    [NSManagedObject printLogsForRequest:mutableURLRequest];
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        [NSManagedObject printLogsForResponse:response data:data error:error];

        if ([NSManagedObject validateStatusCodeForResponse:response withCrudType:DELETE]) {
            [self.managedObjectContext deleteObject:self];
            [self saveContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete();
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                    failure(error);
                }
            });
        }
        
    }] resume];
}

#pragma mark - CRUD Add-on Convenience Methods

- (void)save:(void (^)(void))complete failure:(void (^)(ROBotError *))failure {    
    if([self valueForKey:[[self class] primaryKey]] == nil || [[self valueForKey:[[self class] primaryKey]] isEqualToNumber:@0]) {
        [self create:^{
            if (complete) {
                complete();
            }
        } failure:^(ROBotError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } else {
        [self update:^{
            if (complete) {
                complete();
            }
        } failure:^(ROBotError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }
}

+ (void)index:(void (^)(void))complete failure:(void (^)(ROBotError *))failure {
    [self indexWithDeletePredicate:nil complete:complete failure:failure];
}

+ (void)indexWithDeletePredicate:(NSString *)deletePredicate complete:(void (^)(void))complete failure:(void (^)(ROBotError *error))failure {
    
    //
    // TODO: We should check to see if offline changes are pending for this object type, and make sure those are synced before we make an index request
    //
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ROBotManager sharedInstance].baseURL, [[self class] indexURL]]];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:[NSString stringWithFormat:@"Bearer %@", [ROBotManager sharedInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    NSArray *objects = [[ROBot newChildContext] executeFetchRequest:fetchRequest error:&error];
    if (objects.count > 0) {
        // Only send the ETag if there are more than 0 objects, else if the
        NSString *etag = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"etag%@", [[self class] indexURL]]];
        [mutableURLRequest addValue:etag forHTTPHeaderField:@"If-None-Match"];
    }

    [[ROBotManager sharedInstance].headers enumerateObjectsUsingBlock:^(NSDictionary *headerDictionary, NSUInteger idx, BOOL *stop) {
        [mutableURLRequest setValue:[headerDictionary valueForKey:@"headerValue"] forHTTPHeaderField:[headerDictionary valueForKey:@"headerField"]];
    }];
    [NSManagedObject printLogsForRequest:mutableURLRequest];
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [NSManagedObject printLogsForResponse:response data:data error:error];
        
        // If the server returned a 304, leave the method
        if (((NSHTTPURLResponse *)response).statusCode == 304) {
            if (complete) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete();
                });
            }
            return;
        }
        
        if ([NSManagedObject validateStatusCodeForResponse:response withCrudType:READ]) {
            if (data == nil) {
                // if the data is nil, don't try to parse it
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                        failure(error);
                    }
                });
                return;
            }

            // If the response is valid, save the etag
            NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[headers valueForKey:@"Etag"] forKey:[NSString stringWithFormat:@"etag%@", [[self class] indexURL]]];
            [defaults synchronize];
            
            NSError *jsonError = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (jsonError != nil) {
                if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
                    NSLog(@"Could not parse JSON: %@", jsonError.localizedDescription);
                }
            } else {
                
                // Create the context outside the enumeration block
                NSManagedObjectContext *context = [ROBot newChildContext];
                
                __block NSMutableArray *objectsToKeep = [NSMutableArray new];
                [jsonArray enumerateObjectsUsingBlock:^(NSDictionary *jsonObject, NSUInteger idx, BOOL *stop) {
                    
                    // Check the database to see if the object in the JSON response exists already (based on the primary key)
                    NSError *error = nil;
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", [[self class] primaryKey], jsonObject[[[self class] primaryKey]]]];
                    
                    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
                    if (objects.count > 0) {
                        // The object already exists in the database, so let's just update it
                        [[objects objectAtIndex:0] setDictionaryToCoreDataEntity:jsonObject];
                        [objectsToKeep addObject:[objects objectAtIndex:0]];
                    } else {
                        // The object doesn't exist in the database, so we need to create it
                        NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
                        [newObject setDictionaryToCoreDataEntity:jsonObject];
                        [objectsToKeep addObject:newObject];
                    }
                }];
                
                // After we save the data from the index response, we need to check the deletePredicate, and delete items that match it
                if (deletePredicate) {
                    NSError *error = nil;
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:deletePredicate]];
                    NSMutableArray *objectsMatchingDeletePredicate = [[context executeFetchRequest:fetchRequest error:&error] mutableCopy];
                    [objectsMatchingDeletePredicate removeObjectsInArray:objectsToKeep];
                    [objectsMatchingDeletePredicate enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [context deleteObject:obj];
                    }];
                }
                
                // Save the context after all the objects have been created
                [NSManagedObject saveContext:context];
                if (complete) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete();
                    });
                }
            }
            
        } else {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                    failure(error);
                });
            }
        }
    }] resume];
}

+ (void)customRequestAtURL:(NSString *)urlString andBody:(NSDictionary *)body andMethod:(NSString *)httpMethod withCompletion:(void (^)(NSData *data, NSURLResponse *response))complete andFailure:(void (^)(ROBotError *))failure {
    [self customRequestAtURL:urlString andHeaders:nil andBody:body andMethod:httpMethod withCompletion:complete andFailure:failure];
}

+ (void)customRequestAtURL:(NSString *)urlString andHeaders:(NSDictionary *)headers andBody:(NSDictionary *)body andMethod:(NSString *)httpMethod withCompletion:(void (^)(NSData *data, NSURLResponse *response))complete andFailure:(void (^)(ROBotError *))failure {
    [self customRequestAtURL:urlString andHeaders:headers andBody:body andMethod:httpMethod andDeletePredicate:nil withCompletion:complete andFailure:failure];
}

+ (void)customRequestAtURL:(NSString *)urlString andHeaders:(NSDictionary *)headers andBody:(NSDictionary *)body andMethod:(NSString *)httpMethod andDeletePredicate:(NSString *)deletePredicate withCompletion:(void (^)(NSData *data, NSURLResponse *response))complete andFailure:(void (^)(ROBotError *))failure {

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ROBotManager sharedInstance].baseURL, urlString]];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            [mutableURLRequest addValue:obj forHTTPHeaderField:key];
        }];
    }
    
    [mutableURLRequest setHTTPMethod:httpMethod.uppercaseString];
    if (body) {
        [mutableURLRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]];
    }
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:[NSString stringWithFormat:@"Bearer %@", [ROBotManager sharedInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    [[ROBotManager sharedInstance].headers enumerateObjectsUsingBlock:^(NSDictionary *headerDictionary, NSUInteger idx, BOOL *stop) {
        [mutableURLRequest setValue:[headerDictionary valueForKey:@"headerValue"] forHTTPHeaderField:[headerDictionary valueForKey:@"headerField"]];
    }];
    [NSManagedObject printLogsForRequest:mutableURLRequest];
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [NSManagedObject printLogsForResponse:response data:data error:error];
        
        if ([NSManagedObject validateStatusCodeForResponse:response withCrudType:CUSTOM]) {
            
            if (data == nil) {
                // if the data is nil, don't try to parse it
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                        failure(error);
                    }
                });
                return;
            }
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 304) {
                complete(data, response);
                return;
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
                
                NSManagedObjectContext *context = [ROBot newChildContext];
                
                __block NSMutableArray *objectsToKeep = [NSMutableArray new];
                [jsonArray enumerateObjectsUsingBlock:^(NSDictionary *jsonObject, NSUInteger idx, BOOL *stop) {
                    
                    // Check the database to see if the object in the JSON response exists already (based on the primary key)
                    NSError *error = nil;
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", [[self class] primaryKey], jsonObject[[[self class] primaryKey]]]];
                    
                    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
                    if (objects.count > 0) {
                        // The object already exists in the database, so let's just update it
                        [[objects objectAtIndex:0] setDictionaryToCoreDataEntity:jsonObject];
                        [objectsToKeep addObject:[objects objectAtIndex:0]];
                    } else {
                        // The object doesn't exist in the database, so we need to create it
                        NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
                        [newObject setDictionaryToCoreDataEntity:jsonObject];
                        [objectsToKeep addObject:newObject];
                    }
                }];
                
                // After we save the data from the index response, we need to check the deletePredicate, and delete items that match it
                if (deletePredicate) {
                    NSError *error = nil;
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:deletePredicate]];
                    NSMutableArray *objectsMatchingDeletePredicate = [[context executeFetchRequest:fetchRequest error:&error] mutableCopy];
                    [objectsMatchingDeletePredicate removeObjectsInArray:objectsToKeep];
                    [objectsMatchingDeletePredicate enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [context deleteObject:obj];
                    }];
                }
                
                // Save the context after all the objects have been created
                [NSManagedObject saveContext:context];
                if (complete) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(data, response);
                    });
                }
            }
        } else {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ROBotError *error = [[ROBotError alloc] initWithResponse:response andResponseData:data];
                    failure(error);
                });
            }
        }
        
        
    }] resume];
}

#pragma mark — Helpers

+ (BOOL)validateStatusCodeForResponse:(NSURLResponse *)response withCrudType:(CRUD)crudType {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode]==404 && crudType == DELETE){
        // if we attempt to delete something, but we get a 404 from the server, then it might've already been deleted
        return TRUE;
    } else if ([httpResponse statusCode] == 200 || [httpResponse statusCode] == 201 || [httpResponse statusCode] == 204 || [httpResponse statusCode] == 304) {
        return TRUE;
    }
    return FALSE;
}

+ (void)printLogsForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error {
    if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response String: %@",responseString);
        NSLog(@"Response: %@",response);
        if (error != nil) {
            NSLog(@"Error: %@",error);
        }
    }
}

+ (void)printLogsForRequest:(NSMutableURLRequest *)request {
    if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
        NSLog(@"Show some logs about the request body, url, etc...");
//        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"Response String: %@",responseString);
//        NSLog(@"Response: %@",response);
//        NSLog(@"Error: %@",error);
    }
}

- (BOOL)didCacheOffline:(NSURLResponse *)response crudType:(CRUD)crudType {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if (!httpResponse && self != nil) {
        [self saveContext];
        NSString *cacheSlug = [ROBotManager cacheType:crudType];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // get the array of saved ids from the defaults based on the cache type
        NSMutableArray *ids = [[defaults stringArrayForKey:cacheSlug] mutableCopy];
        if (!ids) {
            ids = [NSMutableArray new];
        }
        // add the new id to the array
        [ids addObject:self.objectID.URIRepresentation.absoluteString];
        [defaults setObject:ids forKey:cacheSlug];
        [defaults synchronize];
        
        return TRUE;
    }
    return FALSE;
}


@end
