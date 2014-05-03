//
//  Constants.m
//  Werewolf
//
//  Created by Lauren Lee on 4/11/14.
//  Copyright (c) 2014 Lauren Lee. All rights reserved.
//

#import "Constants.h"

@implementation Constants

+ (NSArray *)listOfDefinedRoles
{
    static NSArray *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @[
                 @"Villager",
                 @"Werewolf",
                 @"Seer",
                 @"Priest",
                 @"Vigilante",
                 @"Hunter",
                 @"Minion",
                 @"Assassin"
                 ];
    });
    return inst;
}

+ (NSArray *)listOfRoleDescriptions
{
    static NSArray *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @[
                 @"Villagers do not have any special powers. They must figure out who the Werewolves are before they get eaten, and all hope is lost.",
                 @"Werewolves know who's in their pack, and at night they get to secretly kill someone in the Village. They win if they equal or outnumber Villagers.",
                 @"The Seer is a Villager who can look at someone at night to reveal which side they're on.",
                 @"The Priest is a Villager who can choose someone at night to save from the Werewolves. If they pick the same target as the Wolves, no one dies.",
                 @"The Vigilante is a Villager who can shoot someone at night. Hopefully a Werewolf.",
                 @"The Hunter is a Villager who lets the Village win if they are the last Villager alive.",
                 @"The Minion looks like a Villager to the Seer but is on the Werewolf side. The Minion knows who the Werewolves are but not vice versa.",
                 @"The Assassin starts with a random Villager target. Their goal is to convince the Village to kill that person in the Day."
                 ];
    });
    return inst;
}

+ (NSDictionary *)defaultSettings
{
    static NSDictionary *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = @{@"DAY_KILL_ANNOUNCED": @YES,
                 @"NIGHT_KILL_ANNOUNCED": @NO,
                 @"WOLVES_SEE_ROLE_OF_KILL": @YES,
                 @"PRIEST_CAN_TARGET_SELF": @YES,
                 @"PRIEST_CAN_TARGET_SAME_PERSON_TWICE_IN_A_ROW": @NO,
                 @"SEER_PEEKS_NIGHT_ZERO": @NO,
                 @"SEER_SEES_ROLE":@NO,
                 @"VIGILANTE_KILLS_AT_NIGHT": @NO,
                 @"VIGILANTE_KILLS_ONCE_PER_GAME": @YES
                 
                 };
    });
    return inst;
}

@end
