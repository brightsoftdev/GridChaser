//
//  PlayerCar.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerCar.h"

@interface PlayerCar()

-(CGPoint)getNextTileCoordWithDirection:(characterDirection)dir;

@end

@implementation PlayerCar

#define kBaseVelocity 50

@synthesize lastTurnedTileCoord,gameplayLayerDelegate;
@synthesize attemptedTurn,hasTurnedCorrectly;

-(id) init
{
    if(self = [super init]) {
        hasTurnedCorrectly = NO;
        attemptedTurn = kTurnNotAttempted;
        velocity = kBaseVelocity;
        acceleration = 20;
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
- (void)setDirection:(characterDirection)newDirection
{
    CGPoint currentTileCoord = self.tileCoordinate;
    
    if(!CGPointEqualToPoint(lastTurnedTileCoord, currentTileCoord)){
        switch (newDirection) {
            case kDirectionLeft:
                if(direction == 0) newDirection = 3;
                else {
                    newDirection = direction - 1; 
                }
                break;
                
            case kDirectionRight:
                if(direction == 3) newDirection = 0;
                else {
                    newDirection = direction + 1;
                }
                break;
                
            default:
                break;
        }
        
        CGPoint nextTileCoord = [self getNextTileCoordWithDirection:newDirection];
        
        if (![mapDelegate isCollidableWithTileCoord:nextTileCoord]) {
            direction = newDirection;
            [self updateSprite];
            lastTurnedTileCoord = currentTileCoord;
            hasTurnedCorrectly = YES;
            if (self.state == kStateMoving) {
                attemptedTurn = kTurnAttemptSuccess;
            }
        }
        else {
            if (self.state == kStateMoving) {
                attemptedTurn = kTurnAttemptFailed;
            }
        }
    }
}

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
    [super updateWithDeltaTime:deltaTime andArrayOfGameObjects:arrayOfGameObjects];
    
    GameObject *marker = nil;
    
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
    
    CGPoint nextTileCoord = [self getNextTileCoordWithDirection:direction];
    
    switch (state) {
        case kStateIdle:
        {
            if (![mapDelegate isCollidableWithTileCoord:nextTileCoord]) {
                self.state = kStateMoving;
                break;
            }
            else {
                self.velocity = kBaseVelocity;
                break;
            }

        } 
        case kStateMoving:
        {
            if ([mapDelegate isCollidableWithTileCoord:nextTileCoord]) {
                self.state = kStateIdle;
                break;
            }
            else {
                if (attemptedTurn == kTurnAttemptSuccess) {
                    velocity = velocity + 100 * deltaTime;
                    hasTurnedCorrectly = NO;
                    attemptedTurn = kTurnNotAttempted;
                }
                else if(attemptedTurn == kTurnAttemptFailed) {
                    velocity = kBaseVelocity;
                    attemptedTurn = kTurnNotAttempted;
                }
                
                [self moveWithDirectionWithDeltaTime:deltaTime];
                break;
            }
        }
        case kStateJumping:
        {
            
        }
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
    CGPoint nextTileCoord = [self getNextTileCoordWithDirection:direction];
    CGPoint nextTilePosition = [mapDelegate centerPositionAt:nextTileCoord];
    [self moveToPosition:nextTilePosition withDeltaTime:deltaTime];
}

- (CGPoint)getNextTileCoordWithDirection:(characterDirection)dir
{
    CGPoint currentTileCoord = self.tileCoordinate;
    CGPoint nextTileLocation = currentTileCoord;
    
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
