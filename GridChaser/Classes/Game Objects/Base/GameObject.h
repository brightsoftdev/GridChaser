//
//  GameObject.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"
#import "Map.h"
#import "Constants.h"

@interface GameObject : CCSprite {
    BOOL isActive;
    BOOL isTouched;
    CGPoint tileCoordinate;
    id<MapDelegate> mapDelegate;
}

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray*)arrayOfGameObjects;

@property (nonatomic,assign) BOOL isActive;
@property (nonatomic,assign) BOOL isTouched;
@property (nonatomic,assign) id<MapDelegate> mapDelegate;
@property (nonatomic,readonly) CGPoint tileCoordinate;




@end
