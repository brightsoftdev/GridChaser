//
//  EnemyCar.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EnemyCar.h"


@implementation EnemyCar

#define kBaseVelocity 40

static const int numAdjacentTiles = 4;
static const int adjacentTiles[4][2] = { 0,1, -1,0, 1,0, 0,-1};

-(id)init
{
    if(self = [super init]) {
        velocity = kBaseVelocity;
        acceleration = 5;
    }
    
    return self;
}

-(void) dealloc
{
    [super dealloc];
}

-(CGPoint)getNextPosition
{
    CGPoint currentTile = self.tileCoordinate;
    CGPoint bestPosition;
    float bestDistance = INFINITY;
    
    for (int i = 0; i < numAdjacentTiles; i++) {
        int x = adjacentTiles[i][0];
        int y = adjacentTiles[i][1];
        
        CGPoint adjacentTile = ccp(currentTile.x + x, currentTile.y + y);
        
        if (![mapDelegate isCollidableWithTileCoord:adjacentTile]) {
            CGPoint adjacentPosition = [mapDelegate centerPositionAt:adjacentTile];
            CGPoint lastKnownPlayerPosition = [mapDelegate centerPositionAt:lastKnownPlayerCoord];
            CGPoint moveDifference = ccpSub(lastKnownPlayerPosition, adjacentPosition);
            float distanceToMove = ccpLength(moveDifference);
            
            if (distanceToMove < bestDistance) {
                bestDistance = distanceToMove;
                bestPosition = adjacentPosition;
            }
        }  
    }
    return bestPosition;
}

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
    [super updateWithDeltaTime:deltaTime andArrayOfGameObjects:arrayOfGameObjects];
    
    switch (state) {
        case kStateIdle:
            //Play Idle Animation
            break;
            
        case kStateMoving:
        {    
            PlayerCar *player = nil;
            
            for (GameCharacter *tempChar in arrayOfGameObjects) {
                if(tempChar.tag == kPlayerCarTag) {
                    player = (PlayerCar*)tempChar;
                    break;
                }
            }
            
            if(player) {
                lastKnownPlayerCoord = player.tileCoordinate;
                CGRect playerBoundingBox = [player boundingBox];
                CGRect boundingBox = [self boundingBox];
                
                if(CGRectIntersectsRect(boundingBox, playerBoundingBox)) {
                    velocity = kBaseVelocity;
                    //Player shall die.
                    //[player removeFromParentAndCleanup:YES];
                }
                CGPoint nextPosition = [self getNextPosition];
                [self updateDirectionWithTileCoord:[mapDelegate tileCoordForPosition:nextPosition]];
                [self updateSprite];
                [self moveToPosition:nextPosition withDeltaTime:deltaTime];
            }
        }
            
        case kStateJumping:
        {
            
        }
    }
}

-(void) updateSprite
{
    if (direction == 0) {
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kEnemyCarVerticalImage]];
        self.flipY = NO;
    }
    else if(direction == 1) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kEnemyCarImage];
        [self setDisplayFrame:frame];
        self.flipX = NO;
    }
    else if(direction == 2) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kEnemyCarVerticalImage];
        [self setDisplayFrame:frame];
        self.flipY = YES;
    }
    else if(direction == 3) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kEnemyCarImage];
        [self setDisplayFrame:frame];
        self.flipX = YES;
    }
}
@end

