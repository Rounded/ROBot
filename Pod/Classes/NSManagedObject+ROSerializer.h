//
//  NSManagedObject+ROSerializer.h
//  Pods
//
//  Created by Heather Snepenger on 4/27/15.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ROSerializer)

+ (NSDictionary *)mapping;
+ (void)setMapping:(NSDictionary *)mapping;
- (void)update:(NSDictionary *)json;

@end
