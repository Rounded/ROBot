//
//  ROBotError.m
//  scoutlook
//
//  Created by bw on 4/14/15.
//  Copyright (c) 2015 rounded. All rights reserved.
//

#import "ROBotError.h"

@implementation ROBotError

- (id)init {
    return [self initWithResponse:nil andResponseData:nil];
}

- (id)initWithResponse:(NSURLResponse *)response andResponseData:(NSData *)responseData {
    self = [super init];
    if (self) {

        if (response) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            self.statusCode = [httpResponse statusCode];
        }
        
        if (responseData) {
            self.responseData = responseData;
            
            NSError *error = nil;
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&error];

            if (!error) {
                @try {
                    self.responseStringConcatenated = [jsonArray componentsJoinedByString:@", "];
                }
                @catch (NSException *exception) {
                    self.responseStringConcatenated = @"Sorry, there has been an error.";
                }
                @finally {
                    
                }
            }
        }

    }
    return self;
}

- (id)initWithResponse:(NSURLResponse *)response andCustomMessage:(NSString *)customMessage {
    self = [super init];
    if (self) {
        
        if (response) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            self.statusCode = [httpResponse statusCode];
        }
        
        if (customMessage) {
            self.responseStringConcatenated = customMessage;
        }
    }
    return self;
}

@end
