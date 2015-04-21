//
//  ROBotError.h
//  scoutlook
//
//  Created by bw on 4/14/15.
//  Copyright (c) 2015 rounded. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ROBotError : NSObject

@property (nonatomic) NSInteger statusCode;
@property (strong, nonatomic) NSData *responseData;
@property (strong, nonatomic) NSString *responseStringConcatenated;

- (id)initWithResponse:(NSURLResponse *)response andResponseData:(NSData *)responseData;

@end
