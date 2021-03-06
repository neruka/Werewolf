//
//  Player.m
//  Werewolf
//
//  Created by Lauren Lee on 4/11/14.
//  Copyright (c) 2014 Lauren Lee. All rights reserved.
//

#import "Player.h"

@implementation Player

-(id)initWithIndex:(int)index withGame:(Game *)game
{
    if (self = [super init])
    {
        _game = game;
        
        _index = index;
        
        _name = [NSString stringWithFormat:@"Player %d", index];

        _target = @"";
        
        _nightGuesses = [NSMutableArray new];
        _seerPeeks = [NSMutableArray new];
        
        _isDead = NO;
        _isPriestTarget = NO;
        _isVigilanteTarget = NO;
        _isWolfTarget = NO;

    }
    return self;
}

- (void)resetAfterNight
{
    _isPriestTarget = NO;
    _isVigilanteTarget = NO;
    _isWolfTarget = NO;
}

@end
