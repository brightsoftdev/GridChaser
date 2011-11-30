//
//  Constants.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-07-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef GridChaser_Constants_h
#define GridChaser_Constants_h

#ifndef GRID_CHASER_DEBUG_MODE
#define GRID_CHASER_DEBUG_MODE 0
#endif

#define kPixelToMetresRatio 32.0 //Pixel to Meters ratio for Box2D

#define kPlayerCarTag 1
#define kEnemyCarTag 2
#define kMarkerTag 3

#define kGameObjectZValue 100

#define kEndPointIntersectionWidth 3
#define kEndPointIntersectionHeight 3

#pragma mark -
#pragma mark MapLayers

#define kMapForegroundLayer @"Foreground"
#define kMapBackgroundLayer @"Background"
#define kMapObjectLayer @"Objects"
#define kMapCollisionLayer @"Collision"

#pragma mark - 
#pragma mark MapProperties

#define kMapCollidableProperty @"Collidable"

#pragma mark -
#pragma mark MapPropertyValues
#define kMapTrue @"True"
#define kMapFalse @"False"


#pragma mark - 
#pragma mark MapObjects

#define kMapObjectSpawnPoint1 @"SpawnPoint1"
#define kMapObjectSpawnPoint2 @"SpawnPoint2"

#pragma mark -
#pragma mark CharacterStates
typedef enum {
    kStateIdle,
    kStatePatrolling,
    kStateCreeping,
    kStateAlarmed,
    kStateChasing,
    kStateMoving,
    kStateJumping
} CharacterState; // 1

#pragma mark -
#pragma mark CharacterDirection
typedef enum {
    kDirectionUp = 0,
    kDirectionRight = 1,
    kDirectionDown = 2,
    kDirectionLeft = 3
} characterDirection; 

#pragma mark -
#pragma mark GameObjectTypes
typedef enum {
    kGameObjectMarker,
    kGameObjectEnemyCar
} GameObjectType;

#pragma mark -
#pragma mark AdjacentTiles
static const int numAdjacentTiles = 4;
static const int adjacentTiles[4][2] = { 0,1, -1,0, 1,0, 0,-1};

#pragma mark -
#pragma mark GameplayLayerDelegate
@protocol GameplayLayerDelegate
- (void) addGameObject:(GameObjectType)type;
@end

#pragma mark - 
#pragma mark MapDelegate
@protocol MapDelegate
- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGPoint) centerPositionAt:(CGPoint)position;
- (NSMutableArray*) getPathPointsFrom:(CGPoint)origTileCoord to:(CGPoint)destTileCoord;
- (BOOL) isPathValid:(NSMutableArray*)path;
- (BOOL) isCollidableWithTileCoord:(CGPoint)tileCoord;
- (CGSize) getMapSize;
- (CGSize) getTileSize;
@end

#endif
