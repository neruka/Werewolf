//
//  GameData.m
//  Werewolf
//
//  Created by Lauren Lee on 4/16/14.
//  Copyright (c) 2014 Lauren Lee. All rights reserved.
//

#import "GameData.h"

@implementation GameData

// singleton of GameData
+(GameData *)sharedData
{
    static dispatch_once_t pred;
    static GameData *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[GameData alloc] init];
        shared.gameSetups = [[GameData gameSetupsFromPlist] mutableCopy];
    });
    
    return shared;
}

+(NSMutableArray*)gameSetupsFromPlist
{
    NSMutableArray *gameSetups = [[NSMutableArray alloc] init];
    
    // path from application documents
    NSString *plistPath = [[GameData applicationDocumentsDirectory] stringByAppendingPathComponent:@"gameSetupList.plist"];
    
    NSLog(@"%@",plistPath);
    
    // path from main bundle
    NSString *pathBundle = [[NSBundle mainBundle] pathForResource:@"gameSetupList" ofType:@"plist"];

    if ([self checkForPlistFileAtPath:plistPath])
    {
        NSLog(@"unarchive game data from app doc");
        return [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
    }
    else if ([self checkForPlistFileAtPath:pathBundle])
    {
        NSLog(@"init with contents of main bundle plist");
        // create an array from main bundle plist
        NSArray *plistGameSetups = [[NSArray alloc] initWithContentsOfFile:pathBundle];

        [plistGameSetups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            GameSetup *newSetup = [[GameSetup alloc] initWithName:obj[@"name"] roleNumbers:[obj[@"roleNumbers"] mutableCopy] settings:[obj[@"settings"] mutableCopy]];
            [gameSetups addObject:newSetup];
        }];
        
        return gameSetups;
        
    }
    else {
        return gameSetups;
    }
    

}

+(NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+(BOOL)checkForPlistFileAtPath:(NSString*)path
{
    NSFileManager *myManager = [NSFileManager defaultManager];
//    NSString *pathForPlistInDocs = [[GameData applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
    
    return [myManager fileExistsAtPath:path];
}

-(void)save {
    [NSKeyedArchiver archiveRootObject:self.gameSetups toFile:[[GameData applicationDocumentsDirectory] stringByAppendingPathComponent:@"gameSetupList.plist"]];
}


-(void)addNewGameSetup:(GameSetup *)newGameSetup
{
    [_gameSetups insertObject:newGameSetup atIndex:0];
    [[GameData sharedData] save];
}

-(void)removeGameDataAtIndex:(NSInteger)row
{
    [_gameSetups removeObjectAtIndex:row];
    [[GameData sharedData] save];
}

@end

