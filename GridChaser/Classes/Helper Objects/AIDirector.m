//
//  AIDirector.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-10-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AIDirector.h"

@implementation AIDirector

@synthesize elapsedTime,gameplayLayerDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        elapsedTime = 0.0;
        hasSpawned = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    gameplayLayerDelegate = nil;
}

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray*)arrayOfGameObjects 
{
    elapsedTime += deltaTime;
    
    if ((int)elapsedTime % 30 == 0 && !hasSpawned) {
        CCLOG(@"Spawn a new car at: %f",elapsedTime);
        [gameplayLayerDelegate addGameObject:kGameObjectEnemyCar];
        hasSpawned = YES;
    }
    else if((int)elapsedTime % 30 != 0) {
        hasSpawned = NO;
    }
    
}

@end
