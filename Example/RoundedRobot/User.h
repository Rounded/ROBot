//
//  User.h
//  RoundedRobot
//
//  Created by Heather Snepenger on 4/29/15.
//  Copyright (c) 2015 Brian Weinreich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;

@end
