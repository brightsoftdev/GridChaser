//
//  Constants.h
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-07-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef GridChaser_Constants_h
#define GridChaser_Constants_h

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

#pragma CharacterStates
typedef enum {
    kStateIdle,
    kStateMoving
} CharacterState; // 1

#pragma mark -
#pragma mark GameplayLayerDelegate
@protocol GameplayLayerDelegate
- (void) addNewMarker;
@end

#pragma mark - 
#pragma mark MapDelegate
@protocol MapDelegate
- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGPoint) centerPositionAt:(CGPoint)position;
- (NSMutableArray*) getPathPointsFrom:(CGPoint)origin to:(CGPoint)destination;
- (BOOL) isPathValid:(NSMutableArray*)path;
- (BOOL) isCollidableWithTileCoord:(CGPoint)tileCoord;
@end

#endif
