//
//  GameCharacter.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameCharacter.h"

@implementation GameCharacter

@synthesize characterHealth,targetTile,targetPath,direction,velocity,acceleration,topSpeed;

- (id)init
{
    self = [super init];
    if (self) {
        velocity = 40;
        targetTile = ccp(-1, -1);
        targetPath = [[NSMutableArray alloc] init];
        acceleration = 10;
        topSpeed = 125;
        characterHealth = 100;
        direction = kDirectionNull;
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [targetPath release];
}

-(CGPoint) getAdjacentTileFromTileCoord:(CGPoint)tileCoord WithDirection:(CharacterDirection) dir;
{
    CGPoint adjacentTileCoord;
    //SHERVIN: Remove code which relies on adjacentTiles[][] order to work.
    switch (dir) {
        case kDirectionUp:
        {
            adjacentTileCoord = ccp(adjacentTiles[kDirectionUp][0],adjacentTiles[kDirectionUp][1]);
            break;
        }
        case kDirectionRight:
        {
            adjacentTileCoord = ccp(adjacentTiles[kDirectionRight][0],adjacentTiles[kDirectionRight][1]);
            break;
        }
        case kDirectionDown:
        {
            adjacentTileCoord = ccp(adjacentTiles[kDirectionDown][0],adjacentTiles[kDirectionDown][1]);
            break;
        }
        case kDirectionLeft:
        {
            adjacentTileCoord = ccp(adjacentTiles[kDirectionLeft][0],adjacentTiles[kDirectionLeft][1]);
            break;
        }
        default:
        {
            CCLOG(@"Could not find adjacent tile coord, double check characterDirection given");
        }
            break;
    }
    adjacentTileCoord = ccpAdd(tileCoord,adjacentTileCoord);
    return adjacentTileCoord;
}

//SHERVIN:Refactor method to moveToTileCoord
-(void) moveToPosition:(CGPoint)newPosition withDeltaTime:(ccTime)deltaTime
{
    CGPoint newTileCoord = [self.mapDelegate tileCoordForPosition:newPosition];
    if(![self.mapDelegate isCollidableWithTileCoord:newTileCoord]) {
        float deltaDistance = deltaTime * velocity;
        CGPoint moveDifference = ccpSub(newPosition, self.position);
        float distanceToMove = ccpLength(moveDifference);
        
        CGPoint newLocation;
        
        if(distanceToMove < 1) {
            newLocation = newPosition;
        }
        else {
            CGPoint deltaLocation = ccp(deltaDistance*moveDifference.x/distanceToMove,deltaDistance*moveDifference.y/distanceToMove);
            #if GRID_CHASER_DEBUG_MODE
                CCLOG(@"delta.x: %f",deltaDistance*moveDifference.x/distanceToMove);
                CCLOG(@"delta.y: %f",deltaDistance*moveDifference.y/distanceToMove);
            #endif
            
            newLocation = ccpAdd(self.position, deltaLocation);
        }
        self.position = newLocation;
    }
}

-(CharacterDirection) getDirectionWithTileCoord:(CGPoint) tileCoord
{
    CharacterDirection nextDirection = kDirectionNull;
    CGPoint tileCoordSub = ccpSub(tileCoord,self.tileCoordinate );
    #if GRID_CHASER_DEBUG_MODE
        CCLOG(@"TileCoordSub is %@ - %@ = %@",NSStringFromCGPoint(tileCoord),
              NSStringFromCGPoint(self.tileCoordinate),
              NSStringFromCGPoint(tileCoord));
    #endif
    
    if(tileCoordSub.y <= -1) {
        nextDirection = kDirectionUp;
    }
    else if(tileCoordSub.y >= 1) {
        nextDirection = kDirectionDown;
    }
    else if(tileCoordSub.x >= 1) {
        nextDirection = kDirectionRight;
    }
    else if(tileCoordSub.x <= -1) {
        nextDirection = kDirectionLeft;
    }
    return nextDirection;
}

-(CharacterDirection) getOppositeDirectionFromDirection:(CharacterDirection) dir
{
    CharacterDirection oppositeDirection = kDirectionNull;
        switch (dir) {
            case kDirectionUp:
                oppositeDirection = kDirectionDown;
                break;
                
            case kDirectionDown:
                oppositeDirection = kDirectionUp;
                break;
                
            case kDirectionLeft:
                oppositeDirection = kDirectionRight;
                break;
                
            case kDirectionRight:
                oppositeDirection = kDirectionLeft;
                break;
                
            case kDirectionNull:
                CCLOG(@"Warning: Attempting to get opposite direction of kNullDirection");
                oppositeDirection = kDirectionNull;
                break;
                
            default:
                CCLOG(@"Warning: Attempting to get opposite direction of a non CharacterDirection object");
                oppositeDirection = kDirectionNull;
                break;
        }
    return oppositeDirection;
}

-(void) updateSprite
{
    //This method should update the GameCharacter's sprite
    //based on the direction that the GameCharacter is facing
    //CCLOG(@"updateSprite should be overridden"); 
}

-(CharacterTurnAttempt) attemptTurnWithDirection:(CharacterDirection)newDirection andDeltaTime:(ccTime)deltaTime
{
    
    CGPoint nextTileCoord = self.tileCoordinate;
    BOOL isNextTileCollidable = YES;
    int i = 1;
     
    while (i <= kTurnLimit) {
        nextTileCoord = [self getNextTileCoordWithTileCoord:nextTileCoord andDirection:newDirection];
        isNextTileCollidable = [mapDelegate isCollidableWithTileCoord:nextTileCoord];
         
        if (!isNextTileCollidable) {
            break;
        }
        else {
            nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:direction]; 
            i++;
        }
     }
     
     if (isNextTileCollidable) {
        return kTurnAttemptFailed;
     }
     else {
         CGPoint moveDifference = ccpSub(self.position, [mapDelegate centerPositionFromTileCoord:nextTileCoord]);
         float distanceToMove = ccpLength(moveDifference);
         CharacterTurnAttempt turnAttempt;
         if (distanceToMove < kTurnAttemptPerfect ) {
             turnAttempt = kTurnAttemptPerfect;
         }
         else if(distanceToMove < kTurnAttemptGood) {
             turnAttempt = kTurnAttemptGood;
         }
         else if(distanceToMove < kTurnAttemptOkay) {
             turnAttempt = kTurnAttemptOkay;
         }
         else if(distanceToMove < kTurnAttemptPoor) {
             turnAttempt = kTurnAttemptPoor;
         }
         else if(distanceToMove < kTurnAttemptTerrible) {
             turnAttempt = kTurnAttemptTerrible;
         }
         targetTile = nextTileCoord;
         return turnAttempt;
     }
}

-(CGPoint) getNextTileCoordWithPath:(NSMutableArray *)path
{
    CGPoint nextTileCoord = CGPointZero;
    
    if([mapDelegate isPathValid:path]) {
        //grab the next position from the path, get the center tile coordinate.
        CGPoint currentTileCoord = self.tileCoordinate;
        nextTileCoord = CGPointFromString([path objectAtIndex:0]);
        
        //check to see if we are not already at the first point
        if(CGPointEqualToPoint(currentTileCoord,nextTileCoord)) {
            [path removeObject:NSStringFromCGPoint(nextTileCoord)];
            
            if([path count] == 0) {
                return nextTileCoord;
            }
            else {
                nextTileCoord = CGPointFromString([path objectAtIndex:0]);
            }
        }
    }
    return nextTileCoord;
}

-(CGPoint) getNextTileCoordWithTileCoord:(CGPoint)tileCoord andDirection:(CharacterDirection)dir
{
    CGPoint nextTileLocation = tileCoord;
    
    switch (dir) {
        case kDirectionUp:
            nextTileLocation.y -= 1;
            break;
            
        case kDirectionDown:
            nextTileLocation.y += 1;
            break;
            
        case kDirectionLeft:
            nextTileLocation.x -= 1;
            break;
            
        case kDirectionRight:
            nextTileLocation.x += 1;
            break;
            
        default:
            break;
    }
    return nextTileLocation;
}

-(void) moveWithPath:(NSMutableArray *)path withDeltaTime:(ccTime)deltaTime
{
    //Check to see if path is valid
    if([mapDelegate isPathValid:path]) {
        //grab the next position from the path, get the center tile coordinate.
        CGPoint currentTileCoord = self.tileCoordinate;
        CGPoint nextTileCoord = CGPointFromString([path objectAtIndex:0]);
        CGPoint nextPosition = [mapDelegate centerPositionFromTileCoord :nextTileCoord];
        
        //check to see if we are not already at the first point
        if(CGPointEqualToPoint(currentTileCoord,nextTileCoord)) {
            [path removeObject:NSStringFromCGPoint(nextTileCoord)];

            if([path count] == 0) {
                //state = kStateIdle;
                return;
            }
            else {
                nextTileCoord = CGPointFromString([path objectAtIndex:0]);
                nextPosition = [mapDelegate centerPositionFromTileCoord:nextTileCoord];
            }
        }
        [self moveToPosition:nextPosition withDeltaTime:deltaTime];
    }
}

-(void) updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
    //OVERLOAD ME
}

@end
