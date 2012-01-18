//
//  EnemyCar.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EnemyCar.h"

@implementation EnemyCar

@synthesize lastPlayerCoord,lastPlayerDirection,vision,state,turnSuccessRate;

#define kBaseVelocity 40

-(id)init
{
    if(self = [super init]) {
        velocity = kBaseVelocity;
        acceleration = 1;
        topSpeed = 50;
        vision = 7;
        lastPlayerCoord = ccp(-1, -1);
        lastPlayerDirection = -1;
        state = kStatePatrolling;
        turnSuccessRate = kSuccessRatePerfect;
    }
    return self;
}

-(void) dealloc
{
    [super dealloc];
}

-(void) setState:(EnemyState)newState
{
    targetTile = ccp(-1, -1);
    [targetPath removeAllObjects];
    
    switch (newState) {
        case kStatePatrolling: {
            acceleration = 1;
            topSpeed = 50;
            turnSuccessRate = kSuccessRatePerfect;
            break;
        }
        case kStateCautiousPatrolling: {
            turnSuccessRate = 100.0;
            break;
        }
        case kStateCreeping: {
            turnSuccessRate = 1.0;
            break;
        }
        case kStateChasing: {
            acceleration = 2;
            topSpeed = 100;
        }
        case kStateAlarmed: {
            break;
        }
        default:
            break;
    }
    state = newState;
}

-(CharacterTurnAttempt) attemptTurnWithDeltaTime:(ccTime)deltaTime
{
    int minValue = MIN(kSuccessRatePerfect,self.turnSuccessRate);
    int maxValue = MAX(kSuccessRatePerfect,self.turnSuccessRate);
    
    int x = (arc4random() % (maxValue - minValue+1));
    x = x + minValue;
    
    if( x > kTurnAttemptPerfect) {
        velocity = velocity + 100 * deltaTime;
        return kTurnAttemptPerfect;
    }
    else if(x > kTurnAttemptGood) {
        velocity = velocity + 50 * deltaTime;
        return kTurnAttemptGood;
    }
    else if(x > kTurnAttemptOkay) {
        velocity = velocity + 0 * deltaTime;
        return kTurnAttemptOkay;
    }
    else if(x > kTurnAttemptPoor) {
        velocity = velocity - 50 * deltaTime;
        return kTurnAttemptPoor;
    }
    else if(x > kTurnAttemptTerrible) {
        velocity = velocity - 75 * deltaTime;
        return kTurnAttemptTerrible;
    }
    else {
        velocity = velocity - 100 * deltaTime;
        return kTurnAttemptFailed;
    }
}

-(BOOL) isGameObjectVisible:(GameObject *) gameObject 
{
    CGPoint adjacentTile = self.tileCoordinate;
    for (int i = 0; i < vision; i++) {

        if ([self.mapDelegate isCollidableWithTileCoord:adjacentTile]) {
            break;
        }
        else if (CGPointEqualToPoint(gameObject.tileCoordinate, adjacentTile)) {
            return YES;
        }
        
        adjacentTile = [self getAdjacentTileFromTileCoord:adjacentTile WithDirection:direction];
    }
    return NO;
}

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
    float newVelocity = velocity + acceleration * deltaTime;
    velocity = newVelocity;
    
    PlayerCar *player = nil;
    CGPoint nextTileCoord = ccp(-1, -1);
    CharacterDirection nextDirection = kDirectionNull;
    
    for (GameCharacter *tempChar in arrayOfGameObjects) {
        if(tempChar.tag == kPlayerCarTag) {
            player = (PlayerCar*)tempChar;
            break;
        }
    }
    
    /*
     *If we have a success rate that isn't 100% then we must be 
     *in a chasing the player and we should increment the successRate.
     */
    if (turnSuccessRate != kSuccessRatePerfect) {
        if(turnSuccessRate + 2.0 > 100) {
            turnSuccessRate = 100;
        }
        turnSuccessRate += 2.0;
    }
    
    switch (state) {
        //if noteriety is above a certain level, then chase
        //otherwise we might follow/creep toward the player
        //or do nothing
        case kStatePatrolling:
        {
            if ([self isGameObjectVisible:player]) {
                self.state = kStateCreeping;
                nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:self.direction];
                break;
            }
            else {            
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
                    self.targetPath = [mapDelegate getPathPointsFrom:self.tileCoordinate to:targetTile withDirection:direction];
                    nextTileCoord = [self getNextTileCoordWithPath:targetPath];
                }
                else if(targetPath.count > 0 && !CGPointEqualToPoint(targetTile, self.tileCoordinate)) {
                    nextTileCoord = [self getNextTileCoordWithPath:targetPath];
                }
                else if(CGPointEqualToPoint(targetTile, self.tileCoordinate)){
                    //wait a for a random amount of time.
                    //[self wait:arc4random() % 5];
                    targetTile = ccp(-1, -1);
                    //move to another tileCoord;
                }
            }
            break;
        }
            
        case kStateCreeping:
        {
            self.state = kStateChasing;
            nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:self.direction];
            break;
        }
            
        case kStateCautiousPatrolling:
        {
            break;
        }
            
        case kStateChasing:
        {
            if(player) {
                
                CGRect playerBoundingBox = [player boundingBox];
                CGRect boundingBox = [self boundingBox];
                
                if(CGRectIntersectsRect(boundingBox, playerBoundingBox)) {
                    velocity = kBaseVelocity;
                    //Player shall die.
                    //[player removeFromParentAndCleanup:YES];
                }
                
                //if we see the player, then continue chasing
                //if the player is no longer visible, then we should guess where they are.
                //potential reasons for loss of visibility, turning, getting out of vision range.
                
                if ([self isGameObjectVisible:player]) {
                    lastPlayerCoord = player.tileCoordinate;
                    targetTile = player.tileCoordinate;
                    
                    if (lastPlayerDirection != player.direction) {
                        lastPlayerDirection = player.direction;
                        turnSuccessRate = 0.0;
                    }
                    nextTileCoord = lastPlayerCoord;
                    break;
                }
                else {
                    if(CGPointEqualToPoint(self.tileCoordinate, targetTile)) {
                        self.state = kStateAlarmed;
                        nextTileCoord = ccp(-1, -1);
                        break;
                    }
                    else if(targetPath.count == 0) {
                        
                        if(CGPointEqualToPoint(targetTile, ccp(-1, -1))) {
                            targetTile = [self getNextTileCoordWithTileCoord:lastPlayerCoord andDirection:lastPlayerDirection];
                        }

                        self.targetPath = [mapDelegate getPathPointsFrom:self.tileCoordinate to:targetTile withDirection:direction];
                        nextTileCoord = [self getNextTileCoordWithPath:targetPath];
                    }
                    else if(targetPath.count > 0) {
                        nextTileCoord = [self getNextTileCoordWithPath:targetPath];
                    }

                }
                
                nextDirection = [self getDirectionWithTileCoord:nextTileCoord];
                
                if (nextDirection != self.direction && nextDirection != kDirectionNull) {
                    CharacterTurnAttempt turnAttempt = [self attemptTurnWithDeltaTime:deltaTime];
                    
                    if (turnAttempt != kTurnAttemptFailed) {
                        self.direction = nextDirection;
                    }
                    else {
                        nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:self.direction];
                    }
                }
                break;
            }
        }
            
        case kStateAlarmed:
        {
            self.state = kStatePatrolling;
        }
    }

    if(!CGPointEqualToPoint(nextTileCoord, ccp(-1, -1))) {
        nextDirection = [self getDirectionWithTileCoord:nextTileCoord];
        if(nextDirection != kDirectionNull) {
            self.direction = nextDirection;
        }
        [self updateSprite];
        [self moveToPosition:[mapDelegate centerPositionFromTileCoord:nextTileCoord] withDeltaTime:deltaTime];
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

