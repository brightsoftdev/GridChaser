//
//  GameCharacter.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"

#pragma mark -
#pragma mark CharacterDirection
typedef enum {
    kDirectionUp = 0,
    kDirectionRight = 1,
    kDirectionDown = 2,
    kDirectionLeft = 3
} characterDirection; 

@interface GameCharacter : GameObject {
    int characterHealth;
    characterDirection direction;
    float velocity;
    float acceleration;
    float topSpeed;
    CharacterState state;
    id<MapDelegate> mapDelegate;
    CGPoint tileCoordinate;
}

-(id) initWithDirection:(characterDirection) startingDirection;
-(void) moveToPosition:(CGPoint)newPosition withDeltaTime:(ccTime)deltaTime;
-(void) updateDirectionWithTileCoord:(CGPoint) tileCoord;
-(void)updateSprite;
-(void) moveToPositionWithPath:(NSMutableArray *)path withDeltaTime:(ccTime)deltaTime;

@property (nonatomic,assign) int characterHealth;
@property (nonatomic,assign) characterDirection direction;
@property (nonatomic,assign) float velocity;
@property (nonatomic,assign) float acceleration;
@property (nonatomic,assign) float topSpeed;
@property (nonatomic,assign) CharacterState state;
@property (nonatomic,assign) id<MapDelegate> mapDelegate;
@property (nonatomic,readonly) CGPoint tileCoordinate;

@end
