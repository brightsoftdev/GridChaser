//
//  AIDirector.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-10-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <tgmath.h>
#import "cocos2d.h"
#import "Constants.h"

@interface AIDirector : NSObject {
    float elapsedTime;
    BOOL hasSpawned;
    id<GameplayLayerDelegate> gameplayLayerDelegate;
}

@property (nonatomic,readwrite,assign) float elapsedTime;
@property (nonatomic,readwrite,assign) id<GameplayLayerDelegate> gameplayLayerDelegate;

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray*)arrayOfGameObjects;

@end
