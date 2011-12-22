//
//  AStarPathFinder.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"

@interface AStarPathFinder : NSObject {
    CCTMXTiledMap *tiledMap;
    CCTMXLayer *collisionLayer;
    NSMutableSet *openNodes;
    NSMutableSet *closedNodes;
    
    NSString *collisionKey;
    NSString *collisionValue;
}

- (id)initWithTiledMap:(CCTMXTiledMap*)map withCollisionLayer:(CCTMXLayer*)collisionLayer;
- (NSMutableArray*) getPathPointsFrom:(CGPoint)origTileCoord to:(CGPoint)destTileCoord withDirection:(CharacterDirection) startingDirection;
- (BOOL) isCollidableWithTileCoord:(CGPoint)tileCoord;
- (BOOL) isPathValid:(NSMutableArray*)path;

@end

@interface AStarNode : NSObject {
    //int x,y;
    CGPoint point;
    AStarNode *parent;
    CharacterDirection direction;
    int f;
    int g;
    int h;
}

+ (id) nodeWithPoint:(CGPoint)newPoint andDirection:(CharacterDirection)newDirection;
- (id) initWithPoint:(CGPoint)newPoint andDirection:(CharacterDirection) newDirection;
- (int) cost;


@property (nonatomic,assign) CGPoint point;
@property (nonatomic,assign) AStarNode *parent;
@property (nonatomic,assign) CharacterDirection direction;
@property (nonatomic,assign) int f;
@property (nonatomic,assign) int g;
@property (nonatomic,assign) int h;

@end

