//
//  PlayerCar.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerCar.h"

@interface PlayerCar (Private)
- (void) updateInput;
@end

@implementation PlayerCar

#define kBaseVelocity 50

@synthesize lastTurnedTileCoord,gameplayLayerDelegate;
@synthesize attemptedTurnDirection,state,isLaneChanging;
@synthesize upButton,leftButton,rightButton,downButton,lastPressedButton;

-(id) init
{
    if(self = [super init]) {
        attemptedTurnDirection = kDirectionNull;
        velocity = kBaseVelocity;
        acceleration = 10;
        topSpeed = 100;
        direction = kDirectionRight;
        lastPressedButton = nil;
        isLaneChanging = NO;
    }
    return self;
}

- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
    gameplayLayerDelegate = nil;
}


#pragma mark -
#pragma TurnDirection
- (CharacterTurnAttempt) attemptTurnWithDirection:(CharacterDirection)newDirection andDeltaTime:(ccTime)deltaTime
{
    CharacterTurnAttempt turnAttempt = [super attemptTurnWithDirection:newDirection andDeltaTime:deltaTime];
    
    switch (turnAttempt) {
        case kTurnAttemptPerfect: {
            velocity = velocity + 100 * deltaTime;
            break; 
        }
        case kTurnAttemptGood: {
            velocity = velocity + 50 * deltaTime;
            break;
        }
        case kTurnAttemptOkay: {
            break;
        }
        case kTurnAttemptPoor: {
            velocity = velocity - 50 * deltaTime;
            break;
        }
        case kTurnAttemptTerrible: {
            velocity = velocity - 100 * deltaTime;
            break;
        }
        case kTurnAttemptFailed: {
            velocity = kBaseVelocity;
            break;
        }
            
        default:
            break;
    }
    return turnAttempt;
}

- (void)setAttemptedTurnDirection:(CharacterDirection)newDirection
{
    attemptedTurnDirection = newDirection;
}

- (void)setState:(PlayerState)newState
{
    targetTile = ccp(-1, -1);
    
    switch (newState) {
        case kStateIdle:
            velocity = kBaseVelocity;
            break;
            
        case kStateMoving:
            break;
            
        default:
            break;
    }
    state = newState;
}

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
    [self updateInput];
    
    float newVelocity = velocity + acceleration * deltaTime;
    
    if (newVelocity < kBaseVelocity) {
        velocity = kBaseVelocity;
    }
    else {
        velocity = newVelocity;
    }
    
    GameObject *marker = nil;
    CGPoint nextTileCoord = ccp(-1, -1);
    CharacterDirection nextDirection = kDirectionNull;
    
    for (GameObject *tempObj in arrayOfGameObjects) {
        if(tempObj.tag == kMarkerTag) {
            marker = (Marker*)tempObj; 
        }
    }
    
    if(marker != nil) {
        CGRect markerBoundingBox = [marker boundingBox];
        CGRect boundingBox = [self boundingBox];
        
        if(CGRectIntersectsRect(boundingBox, markerBoundingBox)) {
            [marker setVisible:NO];
            [marker removeFromParentAndCleanup:YES];
            [gameplayLayerDelegate addGameObject:kGameObjectMarker];
        }
    }
    
    switch (state) {
        case kStateIdle:
        {
            velocity = kBaseVelocity;
            if (attemptedTurnDirection != kDirectionNull) {
                nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:attemptedTurnDirection];
                attemptedTurnDirection = kDirectionNull;
                nextDirection = [self getDirectionWithTileCoord:nextTileCoord];
                if (nextDirection != self.direction && nextDirection != kDirectionNull && nextDirection != [self getOppositeDirectionFromDirection:self.direction]) {
                    if ([self attemptTurnWithDirection:nextDirection andDeltaTime:deltaTime] == kTurnAttemptFailed) {
                        nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:self.direction];
                        targetTile = nextTileCoord;
                        break;
                    }
                    else {
                        self.state = kStateMoving;
                        self.targetPath = [mapDelegate getPathPointsFrom:self.tileCoordinate to:targetTile withDirection:direction];
                        nextTileCoord = [self getNextTileCoordWithPath:targetPath];
                        targetTile = nextTileCoord;
                        break;

                    }
                }
            }
            break;
        } 
        case kStateMoving:
        {
            if (attemptedTurnDirection != kDirectionNull) {
                nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:attemptedTurnDirection];
                attemptedTurnDirection = kDirectionNull;
                nextDirection = [self getDirectionWithTileCoord:nextTileCoord];
                if (nextDirection != self.direction && nextDirection != kDirectionNull && nextDirection != [self getOppositeDirectionFromDirection:self.direction]) {
                    if ([self attemptTurnWithDirection:nextDirection andDeltaTime:deltaTime] == kTurnAttemptFailed) {
                        nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:self.direction];
                        targetTile = nextTileCoord;
                        break;
                    }
                    else {
                        self.targetPath = [mapDelegate getPathPointsFrom:self.tileCoordinate to:targetTile withDirection:direction];
                        nextTileCoord = [self getNextTileCoordWithPath:targetPath];
                        targetTile = nextTileCoord;
                        break;
                    }
                }
            }
            else if(isLaneChanging) {
                if(CGPointEqualToPoint(self.tileCoordinate, targetTile)) {
                    isLaneChanging = NO;
                }
            }
            else {
                if(targetPath.count > 0) {
                    nextTileCoord = [self getNextTileCoordWithPath:targetPath];
                    targetTile = nextTileCoord;
                    break;
                }
                else {
                    nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:direction];
                    targetTile = nextTileCoord;
                }
            }
        }
    }
    
    if(![mapDelegate isCollidableWithTileCoord:targetTile]) {
        
        //if we need to change the direction because we turned, then turn;
        nextDirection = [self getDirectionWithTileCoord:targetTile];
        if(nextDirection != self.direction && nextDirection != kDirectionNull && !isLaneChanging) {
            self.direction = nextDirection;
        }
        [self updateSprite];
        [self moveToPosition:[mapDelegate centerPositionFromTileCoord:targetTile] withDeltaTime:deltaTime];  
    }
    else if(self.state != kStateIdle){
        self.state = kStateIdle;
    }
}

- (void)updateSprite
{
    if (direction == 0) {
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kPlayerCarVerticalImage]];
        self.flipY = NO;
    }
    else if(direction == 1) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kPlayerCarImage];
        [self setDisplayFrame:frame];
        self.flipX = YES;
    }
    else if(direction == 2) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kPlayerCarVerticalImage];
        [self setDisplayFrame:frame];
        self.flipY = YES;
    }
    else if(direction == 3) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:kPlayerCarImage];
        [self setDisplayFrame:frame];
        self.flipX = NO;
    }
}

- (void) updateInput
{
    BOOL isButtonSelected = upButton.isSelected || leftButton.isSelected || rightButton.isSelected || downButton.isSelected;
    
    if (isButtonSelected && lastPressedButton == nil) {
        //start braking
        if(upButton.isSelected == YES)
        {
            lastPressedButton = upButton;
        }
        else if(leftButton.isSelected == YES)
        {
            lastPressedButton = leftButton;
        }
        else if(rightButton.isSelected == YES)
        {
            lastPressedButton = rightButton;
        }
        else if(downButton.isSelected == YES)
        {
            lastPressedButton = downButton;
        }
        acceleration = -30;
    }
    else if(!isButtonSelected && lastPressedButton != nil) {
        
        CGPoint adjacentSideTile;
        CGPoint adjacentForwardTile;
        CGPoint adjacentBackwardTile;
        
        if(lastPressedButton == upButton)
        {
            if (!(direction == kDirectionDown)) {
                adjacentSideTile = [self getAdjacentTileFromTileCoord:self.tileCoordinate WithDirection:kDirectionUp];
                adjacentForwardTile = [self getAdjacentTileFromTileCoord:adjacentSideTile WithDirection:direction];
                adjacentBackwardTile = [self getAdjacentTileFromTileCoord:adjacentSideTile WithDirection:[self getOppositeDirectionFromDirection:direction]];
                
                if (![mapDelegate isCollidableWithTileCoord:adjacentSideTile] && 
                    ![mapDelegate isCollidableWithTileCoord:adjacentForwardTile] && 
                    ![mapDelegate isCollidableWithTileCoord:adjacentBackwardTile]) {
                    
                    isLaneChanging = YES;
                    targetTile = adjacentForwardTile;
                }
                else {
                    self.attemptedTurnDirection = kDirectionUp;
                    
                }
            }
        }
        else if(lastPressedButton == leftButton)
        {
            adjacentSideTile = [self getAdjacentTileFromTileCoord:self.tileCoordinate WithDirection:kDirectionLeft];
            adjacentForwardTile = [self getAdjacentTileFromTileCoord:adjacentSideTile WithDirection:direction];
            adjacentBackwardTile = [self getAdjacentTileFromTileCoord:adjacentSideTile WithDirection:[self getOppositeDirectionFromDirection:direction]];
            
            if (!(direction == kDirectionRight)) {
                if (![mapDelegate isCollidableWithTileCoord:adjacentSideTile] && 
                    ![mapDelegate isCollidableWithTileCoord:adjacentForwardTile] && 
                    ![mapDelegate isCollidableWithTileCoord:adjacentBackwardTile]) {
                    
                    isLaneChanging = YES;
                    targetTile = adjacentForwardTile;
                }
                else {
                    self.attemptedTurnDirection = kDirectionLeft;
                }
            }
        }
        else if(lastPressedButton == rightButton)
        {
            adjacentSideTile = [self getAdjacentTileFromTileCoord:self.tileCoordinate WithDirection:kDirectionRight];
            adjacentForwardTile = [self getAdjacentTileFromTileCoord:adjacentSideTile WithDirection:direction];
            adjacentBackwardTile = [self getAdjacentTileFromTileCoord:adjacentSideTile WithDirection:[self getOppositeDirectionFromDirection:direction]];
            
            if (!(direction == kDirectionLeft)) {
                if (![mapDelegate isCollidableWithTileCoord:adjacentSideTile] && 
                    ![mapDelegate isCollidableWithTileCoord:adjacentForwardTile] && 
                    ![mapDelegate isCollidableWithTileCoord:adjacentBackwardTile]) {
                    
                    isLaneChanging = YES;
                    targetTile = adjacentForwardTile;
                }
                else {
                    self.attemptedTurnDirection = kDirectionRight;
                }
            }
        }
        else if(lastPressedButton == downButton)
        {
            adjacentSideTile = [self getAdjacentTileFromTileCoord:self.tileCoordinate WithDirection:kDirectionDown];
            adjacentForwardTile = [self getAdjacentTileFromTileCoord:adjacentSideTile WithDirection:direction];
            adjacentBackwardTile = [self getAdjacentTileFromTileCoord:adjacentSideTile WithDirection:[self getOppositeDirectionFromDirection:direction]];
            
            if (!(direction == kDirectionUp)) {
                if (![mapDelegate isCollidableWithTileCoord:adjacentSideTile] && 
                    ![mapDelegate isCollidableWithTileCoord:adjacentForwardTile] && 
                    ![mapDelegate isCollidableWithTileCoord:adjacentBackwardTile]) {
                    
                    isLaneChanging = YES;
                    targetTile = adjacentForwardTile;
                }
                else {
                    self.attemptedTurnDirection = kDirectionDown;
                }
            }
        }
        lastPressedButton = nil;
        acceleration = 10;
    }
}

#pragma mark CCTargetedTouch Methods
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    location = [self.parent convertToNodeSpace:location];
    
    CGRect boundingBox = [self boundingBox];
    
    if(CGRectContainsPoint(boundingBox, location)) {
        CCLOG(@"Touching Player!");
        isTouched = YES;
        return YES;
    }
    else {
        //Assume player is attempting to use their active ability
        //active ability code;
    }
        return YES;
}
@end
