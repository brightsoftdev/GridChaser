//
//  PlayerCar.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameCharacter.h"
#import "Marker.h"
#import "Constants.h"

#define kTurnLimit 2

@interface PlayerCar : GameCharacter <CCTargetedTouchDelegate> {
    CGPoint lastTurnedTileCoord;
    BOOL hasTurnedCorrectly;
    CharacterDirection attemptedTurnDirection;
    PlayerState state;
    id<GameplayLayerDelegate> gameplayLayerDelegate;
    
}

-(void)moveWithDirectionWithDeltaTime:(ccTime)deltaTime;

@property (nonatomic,readwrite,assign) CGPoint lastTurnedTileCoord;
@property (nonatomic,readwrite,assign) CharacterDirection attemptedTurnDirection;
@property (nonatomic,readwrite,assign) PlayerState state;
@property (nonatomic,readwrite,assign) id<GameplayLayerDelegate> gameplayLayerDelegate;

@end