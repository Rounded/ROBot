//
//  ROBot.m
//  Pods
//
//  Created by Heather Snepenger on 6/2/15.
//
//

#import "ROBot.h"

@implementation ROBot

+ (NSManagedObjectContext *)newChildContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:[ROBotManager sharedInstance].mainContext.concurrencyType];
    [context setParentContext:[ROBotManager sharedInstance].mainContext];
    return context;
}

@end
