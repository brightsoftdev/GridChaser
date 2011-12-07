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
    characterDirection direction;
    float velocity;
    float acceleration;
    float topSpeed;
    CharacterState state;
}

@property (nonatomic,assign) int characterHealth;
@property (nonatomic,assign) CGPoint targetTile;
@property (nonatomic,assign) characterDirection direction;
@property (nonatomic,assign) float velocity;
@property (nonatomic,assign) float acceleration;
@property (nonatomic,assign) float topSpeed;
@property (nonatomic,assign) CharacterState state;
@property (nonatomic,retain) NSMutableArray *targetPath;

-(void) moveToPosition:(CGPoint)newPosition withDeltaTime:(ccTime)deltaTime;
-(CGPoint) getNextTileCoordWithPath:(NSMutableArray *)path;
-(CGPoint) getAdjacentTileFromTileCoord:(CGPoint)tileCoord WithDirection:(characterDirection) dir;
-(void) moveWithPath:(NSMutableArray *)path withDeltaTime:(ccTime)deltaTime;
-(void) updateDirectionWithTileCoord:(CGPoint) tileCoord;
-(void) updateSprite;

@end