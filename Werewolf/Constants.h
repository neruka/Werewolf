//
//  Constants.h
//  Werewolf
//
//  Created by Lauren Lee on 4/11/14.
//  Copyright (c) 2014 Lauren Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int MAX_NUM_PEOPLE = 99;

typedef NS_ENUM(NSInteger, roleType)
{
    kVillager,
    kWerewolf,
    kSeer,
    kPriest,
    kVigilante,
    kHunter,
    kMinion,
    kAssassin
};

@interface Constants : NSObject

+ (NSArray *)listOfDefinedRoles;
+ (NSArray *)listOfRoleDescriptions;
+ (NSDictionary *)defaultSettings;

@end
