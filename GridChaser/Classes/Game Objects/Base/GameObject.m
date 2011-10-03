//
//  GameObject.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject

@synthesize isActive,isTouched;

- (id)init
{
    self = [super init];
    if (self) {
        isActive = YES;
        isTouched = NO;
    }
    
    return self;
}

-(void)updateWithDeltaTime:(ccTime)deltaTime andArrayOfGameObjects:(CCArray *)arrayOfGameObjects
{
    //CCLOG(@"updateWithDeltaTime should be overridden"); 
}

@end
