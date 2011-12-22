//
//  PlayerCar.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerCar.h"

@implementation PlayerCar

#define kBaseVelocity 50

@synthesize lastTurnedTileCoord,gameplayLayerDelegate;
@synthesize attemptedTurnDirection,state;

-(id) init
{
    if(self = [super init]) {
        attemptedTurnDirection = kDirectionNull;
        velocity = kBaseVelocity;
        acceleration = 20;
        topSpeed = 100;
        direction = kDirectionRight;
        
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
    switch (newDirection) {
        case kDirectionLeft:
            if (direction == 0) newDirection = 3;
            else {
                newDirection = direction - 1;
            }
            break;
            
        case kDirectionRight:
            if (direction == 3) newDirection = 0;
            else {
                newDirection = direction + 1;
            }
            break;
        default:
            break;
    }
    attemptedTurnDirection = newDirection;
}

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
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
                    if ([self attemptTurnWithDirection:nextDirection andDeltaTime:deltaTime] == kTurnAttemptFailed) {
                        nextTileCoord = [self getNextTileCoordWithTileCoord:self.tileCoordinate andDirection:self.direction];
                    }
                    else {
                        //if we are turning, then skip this frame
                        break;
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

#pragma mark -
#pragma mark CCTouchDispatcher

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

#pragma mark - 
#pragma mark MoveWithDirection

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

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event 
{
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event 
{
    
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

@end
