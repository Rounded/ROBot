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
    [[ROBotManager sharedInstance].headers enumerateObjectsUsingBlock:^(NSDictionary *headerDictionary, NSUInteger idx, BOOL *stop) {
        [mutableURLRequest setValue:[headerDictionary valueForKey:@"headerValue"] forHTTPHeaderField:[headerDictionary valueForKey:@"headerField"]];
    }];
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL success = false;
        
        if ([NSManagedObject validateResponseForData:data andResponse:response andError:error withCrudType:CREATE withObject:self]) {
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
    [[ROBotManager sharedInstance].headers enumerateObjectsUsingBlock:^(NSDictionary *headerDictionary, NSUInteger idx, BOOL *stop) {
        [mutableURLRequest setValue:[headerDictionary valueForKey:@"headerValue"] forHTTPHeaderField:[headerDictionary valueForKey:@"headerField"]];
    }];
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL success = false;
        
        if ([NSManagedObject validateResponseForData:data andResponse:response andError:error withCrudType:READ withObject:self]) {
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
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL success = false;
        
        if ([NSManagedObject validateResponseForData:data andResponse:response andError:error withCrudType:UPDATE withObject:self]) {
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
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if ([NSManagedObject validateResponseForData:data andResponse:response andError:error withCrudType:DELETE withObject:self]) {
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
    if([self valueForKey:[[self class] primaryKey]] == nil || [self valueForKey:[[self class] primaryKey]] == @0) {
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ROBotManager sharedInstance].baseURL, [[self class] indexURL]]];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:[NSString stringWithFormat:@"Bearer %@", [ROBotManager sharedInstance].accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSString *etag = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"etag%@", [[self class] indexURL]]];
    [mutableURLRequest addValue:etag forHTTPHeaderField:@"If-None-Match"];
    [[ROBotManager sharedInstance].headers enumerateObjectsUsingBlock:^(NSDictionary *headerDictionary, NSUInteger idx, BOOL *stop) {
        [mutableURLRequest setValue:[headerDictionary valueForKey:@"headerValue"] forHTTPHeaderField:[headerDictionary valueForKey:@"headerField"]];
    }];
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",responseString);
            NSLog(@"%@",response);
            NSLog(@"%@",error);
        }
        
        // If the server returned a 304, leave the method
        if (((NSHTTPURLResponse *)response).statusCode == 304) {
            return;
        }

        if ([NSManagedObject validateResponseForData:data andResponse:response andError:error withCrudType:CUSTOM withObject:nil]) {

            // If the response is valid, save the etag
            NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
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

+ (void)customRequestAtURL:(NSString *)urlString andBody:(NSDictionary *)body andMethod:(NSString *)httpMethod withCompletion:(void (^)(void))complete andFailure:(void (^)(ROBotError *))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ROBotManager sharedInstance].baseURL, urlString]];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
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
    
    [[session dataTaskWithRequest:mutableURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",responseString);
            NSLog(@"%@",response);
            NSLog(@"%@",error);
        }

        if ([NSManagedObject validateResponseForData:data andResponse:response andError:error withCrudType:CUSTOM withObject:nil]) {
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




#pragma mark — Helpers
+ (BOOL)validateResponseForData:(NSData *)data andResponse:(NSURLResponse *)response andError:(NSError *)error withCrudType:(CRUD)crudType withObject:(NSManagedObject *)object{
    if ([ROBotManager sharedInstance].verboseLogging == TRUE) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",responseString);
        NSLog(@"%@",response);
        NSLog(@"%@",error);
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    // Check if offline
    if (!httpResponse && crudType != CUSTOM && object) {
        // Cache the response if offline
        [object cacheOffline:crudType];
        return false;
    }
    if ([httpResponse statusCode]==200 || [httpResponse statusCode]==201 || [httpResponse statusCode]==304) {
        return TRUE;
    }
    return FALSE;
}



- (void)cacheOffline:(CRUD)crudType {
    
    // Don't cache read calls
    if (crudType == READ) {
        return;
    }

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
}


@end