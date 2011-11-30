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

-(id)init
{
    if(self = [super init]) {
        velocity = kBaseVelocity;
        acceleration = 5;
        topSpeed = 100;
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
        
        if (self.direction == kDirectionDown  && y == -1) {
            continue;
        }
        else if(self.direction ==  kDirectionUp && y == 1) {
            continue;
        }
        else if(self.direction == kDirectionRight && x == -1) {
            continue;
        }
        else if(self.direction == kDirectionLeft && x == 1) {
            continue;
        }
        
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
            
        case kStatePatrolling:
        {
            acceleration = 1;
            topSpeed = 50;
            
            if(targetPath.count == 0 && CGPointEqualToPoint(targetTile, ccp(-1, -1))) {
                //set a new position
                CGPoint nextTargetTile = ccp(-1, -1);
                CGSize mapSize = [mapDelegate getMapSize];
                
                while ([mapDelegate isCollidableWithTileCoord:nextTargetTile]) {
                    int x = arc4random() % (int)mapSize.width;
                    int y = arc4random() % (int)mapSize.height;
                    nextTargetTile = ccp(x, y);
                }
                
                targetTile = nextTargetTile;
                self.targetPath = [mapDelegate getPathPointsFrom:self.tileCoordinate to:targetTile];
            }
            else if(targetPath.count > 0 && !CGPointEqualToPoint(targetTile, self.tileCoordinate)) {
                CGPoint nextTileCoord = [self getNextTileCoordWithPath:targetPath];
                [self updateDirectionWithTileCoord:nextTileCoord];
                [self updateSprite];
                [self moveToPosition:[mapDelegate centerPositionAt:nextTileCoord] withDeltaTime:deltaTime];
            }
            else if(CGPointEqualToPoint(targetTile, self.tileCoordinate)){
                //wait a second or two or three
                
                
                targetTile = ccp(-1, -1);
                //move to another tileCoord;
            }
        }
            
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
    if (direction == kDirectionUp) {
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kEnemyCarVerticalImage]];
        self.flipY = NO;
    }
    else if(direction == kDirectionRight) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kEnemyCarImage];
        [self setDisplayFrame:frame];
        self.flipX = YES;
    }
    else if(direction == kDirectionDown) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kEnemyCarVerticalImage];
        [self setDisplayFrame:frame];
        self.flipY = YES;
    }
    else if(direction == kDirectionLeft) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kEnemyCarImage];
        [self setDisplayFrame:frame];
        self.flipX = NO;
    }
}
@end

