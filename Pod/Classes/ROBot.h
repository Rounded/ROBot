//
//  ROBot.h
//  Pods
//
//  Created by Heather Snepenger on 6/2/15.
//
//

#import <Foundation/Foundation.h>
#import "ROBotError.h"
#import "NSManagedObject+CRUD.h"
#import "ROBotManager.h"
#import "NSManagedObject+ROSerializer.h"

@interface ROBot : NSObject

+ (NSManagedObjectContext *)newChildContext;

@end
