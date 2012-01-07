//
//  PlayerCar.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerCar.h"

@interface PlayerCar (Private)
- (void) updateWithInput;
@end

@implementation PlayerCar

#define kBaseVelocity 50

@synthesize lastTurnedTileCoord,gameplayLayerDelegate;
@synthesize attemptedTurnDirection,state;
@synthesize upButton,leftButton,rightButton,downButton,lastPressedButton;

-(id) init
{
    if(self = [super init]) {
        attemptedTurnDirection = kDirectionNull;
        velocity = kBaseVelocity;
        acceleration = 20;
        topSpeed = 100;
        direction = kDirectionRight;
        isBraking = NO;
        lastPressedButton = nil;
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

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
    [self updateWithInput];
    [super updateWithDeltaTime:deltaTime andArrayOfGameObjects:arrayOfGameObjects];
    
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
                if (nextDirection != self.direction && nextDirection != kDirectionNull) {
                    if ([self attemptTurnWithDirection:nextDirection andDeltaTime:deltaTime] == kTurnAttemptFailed) {
                        nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:self.direction];
                    }
                    else {
                        self.state = kStateMoving;
                    }
                }
            }
            break;
        } 
        case kStateMoving:
        {
            if (!CGPointEqualToPoint(targetTile, ccp(-1, -1))) {
                self.targetPath = [mapDelegate getPathPointsFrom:self.tileCoordinate to:targetTile withDirection:direction];
                targetTile = ccp(-1, -1);
            }
            
            if(targetPath.count > 0) {
                nextTileCoord = [self getNextTileCoordWithPath:targetPath];
            }
            else {
                if (attemptedTurnDirection != kDirectionNull) {
                    nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:attemptedTurnDirection];
                    attemptedTurnDirection = kDirectionNull;
                    nextDirection = [self getDirectionWithTileCoord:nextTileCoord];
                    if (nextDirection != self.direction && nextDirection != kDirectionNull) {
                        if ([self attemptTurnWithDirection:nextDirection andDeltaTime:deltaTime] == kTurnAttemptFailed) {
                            nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:self.direction];
                        }
                        else {
                            //if we are turning, then skip this frame
                            break;
                        }
                    }
                }
                else {
                    nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:direction];
                    
                    if ([mapDelegate isCollidableWithTileCoord:nextTileCoord]) {
                        self.state = kStateIdle;
                        //TODO: Override state setter and change velocity in that method.
                        velocity = kBaseVelocity;
                        break;
                    }
                }
            }
        }
            
        nextDirection = [self getDirectionWithTileCoord:nextTileCoord];
        if(nextDirection != kDirectionNull) {
            self.direction = nextDirection;
        }
        [self updateSprite];
        [self moveToPosition:[mapDelegate centerPositionFromTileCoord:nextTileCoord] withDeltaTime:deltaTime];    
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

- (void) updateWithInput
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
        velocity = velocity * 0.9;
    }
    else if(isButtonSelected == NO && lastPressedButton != nil) {
        if(lastPressedButton == upButton)
        {
            self.attemptedTurnDirection = kDirectionUp;
        }
        else if(lastPressedButton == leftButton)
        {
            self.attemptedTurnDirection = kDirectionLeft;
        }
        else if(lastPressedButton == rightButton)
        {
            self.attemptedTurnDirection = kDirectionRight;
        }
        else if(lastPressedButton == downButton)
        {
            self.attemptedTurnDirection = kDirectionDown;
        }
        lastPressedButton = nil;
    }
}

#pragma mark - 
#pragma mark MoveWithDirection

//TODO:Move to GameCharacter.m
- (void)moveWithDirectionWithDeltaTime:(ccTime)deltaTime
{
    CGPoint nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:direction];
    CGPoint nextTilePosition = [mapDelegate centerPositionFromTileCoord:nextTileCoord];
    [self moveToPosition:nextTilePosition withDeltaTime:deltaTime];
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
