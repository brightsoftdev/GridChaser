//
//  GameCharacter.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameCharacter.h"

@implementation GameCharacter

@synthesize characterHealth,targetTile,targetPath,direction,velocity,acceleration,topSpeed,state;

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
        state = kStateIdle;
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [targetPath release];
}

-(CGPoint) getAdjacentTileFromTileCoord:(CGPoint)tileCoord WithDirection:(characterDirection) dir;
{
    CGPoint adjacentTileCoord;
    //TODO: Remove code which relies on adjacentTiles[][] order to work.
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

-(void) updateDirectionWithTileCoord:(CGPoint) tileCoord
{
    CGPoint tileCoordSub = ccpSub(tileCoord,self.tileCoordinate );
    #if GRID_CHASER_DEBUG_MODE
        CCLOG(@"TileCoordSub is %@ - %@ = %@",NSStringFromCGPoint(tileCoord),
              NSStringFromCGPoint(self.tileCoordinate),
              NSStringFromCGPoint(tileCoord));
    #endif
    
    if(tileCoordSub.y == -1) {
        direction = kDirectionUp;
    }
    else if(tileCoordSub.y == 1) {
        direction = kDirectionDown;
    }
    else if(tileCoordSub.x == 1) {
        direction = kDirectionRight;
    }
    else if(tileCoordSub.x == -1) {
        direction = kDirectionLeft;
    }
}

-(void)updateSprite
{
    //This method should update the GameCharacter's sprite
    //based on the direction that the GameCharacter is facing
    //CCLOG(@"updateSprite should be overridden"); 
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

-(void) moveWithPath:(NSMutableArray *)path withDeltaTime:(ccTime)deltaTime
{
    //Check to see if path is valid
    if([mapDelegate isPathValid:path]) {
        //grab the next position from the path, get the center tile coordinate.
        CGPoint currentTileCoord = self.tileCoordinate;
        CGPoint nextTileCoord = CGPointFromString([path objectAtIndex:0]);
        CGPoint nextPosition = [mapDelegate centerPositionAt :nextTileCoord];
        
        //check to see if we are not already at the first point
        if(CGPointEqualToPoint(currentTileCoord,nextTileCoord)) {
            [path removeObject:NSStringFromCGPoint(nextTileCoord)];

            if([path count] == 0) {
                //state = kStateIdle;
                return;
            }
            else {
                nextTileCoord = CGPointFromString([path objectAtIndex:0]);
                nextPosition = [mapDelegate centerPositionAt:nextTileCoord];
            }
        }
        [self moveToPosition:nextPosition withDeltaTime:deltaTime];
    }
}

-(void) setState:(CharacterState)newState; 
{
    state = newState;
    //Based on state, run the required animations.
    //Animations need to run here follow by changing of states.
}

-(void) updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
    float newVelocity = velocity + acceleration * deltaTime;
    #if GRID_CHASER_DEBUG_MODE
        CCLOG(@"Velocity: %f",newVelocity);
    #endif
    
    //velocity = newVelocity;
    
    if (newVelocity > topSpeed) {
        velocity = topSpeed;
    }
    else {
        velocity = newVelocity;
    }
}

@end
