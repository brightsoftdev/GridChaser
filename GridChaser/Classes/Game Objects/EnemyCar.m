//
//  EnemyCar.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EnemyCar.h"


@implementation EnemyCar

-(id)init
{
    if(self = [super init]) {
        velocity = 40;
    }
    
    return self;
}

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
    switch (state) {
        case kStateIdle:
            //Play Idle Animation
            break;
            
        case kStateMoving:
        {    
            PlayerCar *player;
            
            for (GameCharacter *tempChar in arrayOfGameObjects) {
                if(tempChar.tag == kPlayerCarTag) {
                    player = (PlayerCar*)tempChar; 
                }
            }
            
            CGRect playerBoundingBox = [player boundingBox];
            CGRect boundingBox = [self boundingBox];
            
            if(CGRectIntersectsRect(boundingBox, playerBoundingBox)) {
                state = kStateIdle;
                [player removeFromParentAndCleanup:YES];
            }
            else {
                CGPoint posTileCoord = [mapDelegate tileCoordForPosition:self.position];
                CGPoint playerTileCoord = [mapDelegate tileCoordForPosition:player.position];
                
                NSMutableArray *path = [mapDelegate getPathPointsFrom:posTileCoord to:playerTileCoord];
                [self moveToPositionWithPath:path withDeltaTime:deltaTime];
            }
            break;
        }
    }
}
@end

