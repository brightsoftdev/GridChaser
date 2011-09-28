//
//  GameCharacter.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"

@interface GameCharacter : GameObject {
    int characterHealth;
    float velocity;
    CharacterState state;
    id<MapDelegate> mapDelegate;
}

-(void) moveToPosition:(CGPoint)newPosition withDeltaTime:(ccTime)deltaTime;
-(void) moveToPositionWithPath:(NSMutableArray *)path withDeltaTime:(ccTime)deltaTime;

@property (nonatomic,assign) int characterHealth;
@property (nonatomic,assign) float velocity;
@property (nonatomic,assign) CharacterState state;
@property (nonatomic,assign) id<MapDelegate> mapDelegate;

@end
