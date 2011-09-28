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

#pragma CharacterDirection
typedef enum {
    kDirectionUp = 1,
    kDirectionRight = 2,
    kDirectionDown = 3,
    kDirectionLeft = 4
} playerDirection; 

@interface PlayerCar : GameCharacter <CCTargetedTouchDelegate> {
    playerDirection direction;
    CGPoint lastTileCoord;
    id<GameplayLayerDelegate> gameplayLayerDelegate;
}

-(void)moveWithDirectionWithDeltaTime:(ccTime)deltaTime;
-(void)turnDirection:(playerDirection)newDirection;

@property (nonatomic,readwrite,assign) CGPoint lastTileCoord;
@property (nonatomic,readwrite,assign) id<GameplayLayerDelegate> gameplayLayerDelegate;
@property (nonatomic,readwrite,assign) playerDirection direction;

@end
