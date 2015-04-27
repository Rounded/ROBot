//
//  NSManagedObject+ROSerializer.m
//  Pods
//
//  Created by Heather Snepenger on 4/27/15.
//
//

#import "NSManagedObject+ROSerializer.h"

@implementation NSManagedObject (ROSerializer)

- (void)update:(NSDictionary *)json {
    // pull out the attributes that exist in the database
    NSEntityDescription *entity = self.entity;
    NSDictionary *attributes = entity.attributesByName;
    
    // Update all the key / values for the object
    [json enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        // If the object exists in the mapping, use the mapping
        if ([NSManagedObject mapping] && [[NSManagedObject mapping] objectForKey:key]) {
            [self setValue:obj forKey:[[NSManagedObject mapping] objectForKey:key]];
        }
        // Otherwise assign the value to the corresponding value in the db
        else {
            if (obj) {
                [self setValue:obj forKey:key];
            }
        }
    }];
}

@end
