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

#pragma TurnAttempt
typedef enum {
    kTurnAttemptSuccess,
    kTurnAttemptFailed,
    kTurnNotAttempted
} turnAttempt;

@interface PlayerCar : GameCharacter <CCTargetedTouchDelegate> {
    CGPoint lastTurnedTileCoord;
    BOOL hasTurnedCorrectly;
    turnAttempt attemptedTurn;
    id<GameplayLayerDelegate> gameplayLayerDelegate;
}

-(void)moveWithDirectionWithDeltaTime:(ccTime)deltaTime;

@property (nonatomic,readwrite,assign) CGPoint lastTurnedTileCoord;
@property (nonatomic,readwrite,assign) turnAttempt attemptedTurn;
@property (nonatomic,readwrite,assign) BOOL hasTurnedCorrectly;
@property (nonatomic,readwrite,assign) id<GameplayLayerDelegate> gameplayLayerDelegate;

@end