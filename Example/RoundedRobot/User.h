//
//  User.h
//  RoundedRobot
//
//  Created by Heather Snepenger on 7/3/15.
//  Copyright (c) 2015 Brian Weinreich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * test;

@end
