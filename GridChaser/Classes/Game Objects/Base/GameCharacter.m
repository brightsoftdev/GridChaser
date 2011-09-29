//
//  GameCharacter.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameCharacter.h"

@implementation GameCharacter

@synthesize characterHealth,velocity,state,mapDelegate,tileCoordinate;

- (id)init
{
    self = [super init];
    if (self) {
        velocity = 40;
        characterHealth = 100;
        state = kStateIdle;
    }
    
    return self;
}

-(CGPoint) tileCoordinate {
    CGPoint currentTileCoordinate = [mapDelegate tileCoordForPosition:self.position];
    return currentTileCoordinate;
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
            CGPoint deltaLocation = ccp(lroundf(deltaDistance*moveDifference.x/distanceToMove),lroundf(deltaDistance*moveDifference.y/distanceToMove));
            newLocation = ccpAdd(self.position, deltaLocation);
        }
        self.position = newLocation;
    }
}

-(void) moveToPositionWithPath:(NSMutableArray *)path withDeltaTime:(ccTime)deltaTime
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
                state = kStateIdle;
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

-(void) updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
     //OVERLOAD ME
}

@end
