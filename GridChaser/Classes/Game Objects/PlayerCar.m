//
//  PlayerCar.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerCar.h"

@interface PlayerCar()

-(CGPoint)getNextTileCoordWithDirection:(playerDirection)dir;

@end

@implementation PlayerCar

@synthesize lastTileCoord,direction,gameplayLayerDelegate;

-(id) init
{
    if(self = [super init]) {
        velocity = 50;
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

- (void)turnDirection:(playerDirection)newDirection
{
    CGPoint currentTileCoord = self.tileCoordinate;
    
    if(!CGPointEqualToPoint(lastTileCoord, currentTileCoord)){
        switch (newDirection) {
            case kDirectionLeft:
                if(direction == 1) newDirection = 4;
                else {
                    newDirection = direction - 1; 
                }
                
                break;
                
            case kDirectionRight:
                if(direction == 4) newDirection = 1;
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
            lastTileCoord = currentTileCoord;
        }
    }
}

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
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
    
    
    
    switch (state) {
        case kStateIdle:
            break;
            
        case kStateMoving:
        {
            [self moveWithDirectionWithDeltaTime:deltaTime];
            break;
        }
            
        case kStateJumping:
        {
            
        }
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

- (CGPoint)getNextTileCoordWithDirection:(playerDirection)dir
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
