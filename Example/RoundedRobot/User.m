//
//  User.m
//  RoundedRobot
//
//  Created by Heather Snepenger on 4/29/15.
//  Copyright (c) 2015 Brian Weinreich. All rights reserved.
//

#import "User.h"
#import "ROBot.h"


@implementation User

@dynamic name;
@dynamic id;

+ (NSString *)indexURL {
    return @"/users";
}

- (NSString *)createURL {
    return @"/users";
}

- (NSString *)updateURL {
    return [NSString stringWithFormat:@"/users/%@", self.id];
}

- (NSString *)deleteURL {
    return [NSString stringWithFormat:@"/users/%@", self.id];
}

@end
