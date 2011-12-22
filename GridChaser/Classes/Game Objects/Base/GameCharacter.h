//
//  GameCharacter.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"

@interface GameCharacter : GameObject {
    int characterHealth;
    CGPoint targetTile;
    NSMutableArray *targetPath;
    CharacterDirection direction;
    float velocity;
    float acceleration;
    float topSpeed;
}

#define kTurnLimit 2

@property (nonatomic,assign) int characterHealth;
@property (nonatomic,assign) CGPoint targetTile;
@property (nonatomic,assign) CharacterDirection direction;
@property (nonatomic,assign) float velocity;
@property (nonatomic,assign) float acceleration;
@property (nonatomic,assign) float topSpeed;
@property (nonatomic,retain) NSMutableArray *targetPath;

-(void) moveToPosition:(CGPoint)newPosition withDeltaTime:(ccTime)deltaTime;
-(CGPoint) getNextTileCoordWithPath:(NSMutableArray *)path;
-(CGPoint) getNextTileCoordWithTileCoord:(CGPoint)tileCoord andDirection:(CharacterDirection)dir;
-(CGPoint) getAdjacentTileFromTileCoord:(CGPoint)tileCoord WithDirection:(CharacterDirection) dir;
-(void) moveWithPath:(NSMutableArray *)path withDeltaTime:(ccTime)deltaTime;
-(CharacterDirection) getDirectionWithTileCoord:(CGPoint) tileCoord;
-(void) updateSprite;
-(CharacterTurnAttempt) attemptTurnWithDirection:(CharacterDirection)newDirection andDeltaTime:(ccTime)deltaTime;

@end