//
//  EnemyCar.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameCharacter.h"
#import "Constants.h"
#import "PlayerCar.h"

@interface EnemyCar : GameCharacter {
    CGPoint lastKnownPlayerCoord;
}

@end
