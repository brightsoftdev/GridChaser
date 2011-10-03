//
//  GameplayLayer.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AIDirector.h"
#import "PlayerCar.h"
#import "EnemyCar.h"
#import "Marker.h"
#import "Map.h"

@interface GameplayLayer : CCLayer <GameplayLayerDelegate> {
    AIDirector *director;
    PlayerCar *player;
    CCSpriteBatchNode *spriteBatchNode;
    Map *gameMap;
}

+(CCScene *)scene;

@property (nonatomic,retain) Map *gameMap;

@end