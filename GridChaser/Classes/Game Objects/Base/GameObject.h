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
}

@property (nonatomic,assign) BOOL isActive;
@property (nonatomic,assign) BOOL isTouched;

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray*)arrayOfGameObjects;

@end
