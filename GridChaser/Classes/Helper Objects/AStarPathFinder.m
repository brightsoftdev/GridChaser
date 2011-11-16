//
//  AStarPathFinder.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AStarPathFinder.h"

@interface AStarPathFinder (Private)
    - (AStarNode *)lowestCostNode;
    - (AStarNode *) findShortestPathFrom:(CGPoint)origin to:(CGPoint)destination;
    
@end

@implementation AStarPathFinder

static const int numAdjacentTiles = 4;
static const int adjacentTiles[4][2] = { 0,1, -1,0, 1,0, 0,-1};


- (id)initWithTiledMap:(CCTMXTiledMap *)map withCollisionLayer:(CCTMXLayer*)layer
{
    self = [super init];
    if (self) {
        tiledMap = [map retain];
        collisionLayer = [layer retain];
        //TODO: Find a better Capacity value to prevent resizing
        openNodes = [[NSMutableSet alloc] initWithCapacity:16];
        closedNodes = [[NSMutableSet alloc] initWithCapacity:32];
        collisionKey = kMapCollidableProperty;
        collisionValue = kMapTrue;
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [tiledMap release];
    [collisionLayer release];
    [openNodes release];
    [closedNodes release];
}

- (AStarNode *) findShortestPathFrom:(CGPoint)origTileCoord to:(CGPoint)destTileCoord
{
    [openNodes removeAllObjects];
    [closedNodes removeAllObjects];
    
    //Assume origin and destination are tile coordinates not viewport coordinates.
    //Check if the destination isn't collideable
    if([self isCollidableWithTileCoord:destTileCoord]) {
        return nil;
    }
    
    AStarNode *originNode = [AStarNode nodeWithPoint:origTileCoord];
    originNode.parent = nil;
    [openNodes addObject:originNode];
    
    AStarNode *closestNode = nil;
    
    while ([openNodes count]) {
        //Grab lowest f costing node
        closestNode = [self lowestCostNode];
        
        //if lowest costing node is the destination, then we are done
        if(closestNode.point.x == destTileCoord.x && closestNode.point.y == destTileCoord.y) {
            return closestNode;
        }
        
        //move it to the closed list
        [openNodes removeObject:closestNode];
        [closedNodes addObject:closestNode];
        
        //check if the 4 squares are walkable
        for (int i = 0; i < numAdjacentTiles; i++) {
            int x = adjacentTiles[i][0];
            int y = adjacentTiles[i][1];
            
            AStarNode *adjacentNode = [AStarNode nodeWithPoint:ccp(x + closestNode.point.x, y + closestNode.point.y)];
            adjacentNode.parent = closestNode;
            
            if([closedNodes containsObject:adjacentNode]) {
                continue;
            }
            
            if([self isCollidableWithTileCoord:adjacentNode.point]) {
                [closedNodes addObject:adjacentNode];
                continue;
            }
            
            //Calculate G value for adjacentNode
            adjacentNode.g = closestNode.g + 10;
            
            //If openNodes already contains adjacentNodes, then compare new G to old G
            //change parent if lower
            
            BOOL isInOpenNodes = [openNodes containsObject:adjacentNode];
            
            if(isInOpenNodes) {
                AStarNode *previousAdjacentNode = [openNodes member:adjacentNode];
                int newCost = previousAdjacentNode.g - previousAdjacentNode.parent.g + closestNode.g;
                if(newCost < previousAdjacentNode.g) {
                    previousAdjacentNode.parent = closestNode;
                    previousAdjacentNode.g = newCost;
                }
            }
            //otherwise calculate H
            //add to open set
            else {
                adjacentNode.h = (abs(adjacentNode.point.x + destTileCoord.x) + abs(adjacentNode.point.y + destTileCoord.y)) * 10;
                 //CCLOG(@"Adding Point: %@",NSStringFromCGPoint(adjacentNode.point));
                [openNodes addObject:adjacentNode];
            }
        }
    }
    return nil;
}

- (NSMutableArray*) getPathPointsFrom:(CGPoint)origTileCoord to:(CGPoint)destTileCoord
{
    NSMutableArray *paths = [NSMutableArray array];
    
    AStarNode *destinationNode = [self findShortestPathFrom:origTileCoord to:destTileCoord];
    
    if(destinationNode == nil) {
        return paths;
    }
    
    while (destinationNode) {
        [paths addObject:NSStringFromCGPoint(destinationNode.point)];
        destinationNode = destinationNode.parent;
    }
    return (NSMutableArray*)[[paths reverseObjectEnumerator] allObjects];
}

- (BOOL) isCollidableWithTileCoord:(CGPoint)tileCoord 
{
    if(tileCoord.x >= collisionLayer.layerSize.width || tileCoord.x < 0) {
        return YES;
    }
    else if(tileCoord.y >= collisionLayer.layerSize.height || tileCoord.y <0) {
        return YES;
    }
    
    int tileGid = [collisionLayer tileGIDAt:tileCoord];
    
    if(tileGid) {
        NSDictionary *layerDict = [collisionLayer propertyNamed:collisionKey];
        if(layerDict) {
            return YES;
        }
        
        NSDictionary *tileDict = [tiledMap propertiesForGID:tileGid];
        
        if(tileDict) {
            NSString *collidable = [tileDict valueForKey:collisionKey];
            if(collidable && [collidable isEqualToString:kMapTrue]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL) isPathValid:(NSMutableArray *)path
{
    CGPoint tileCoord;
    
    for (NSString *string in path) {
        tileCoord = CGPointFromString(string);
        if([self isCollidableWithTileCoord:tileCoord]) {
            return NO;
        }
    }
    return YES;
}

- (AStarNode *)lowestCostNode
{
    AStarNode *lowestNode = [openNodes anyObject];
    
    for (AStarNode *node in openNodes) {
        if([node cost] < [lowestNode cost]) {
            lowestNode = node;
        }
        else if([node cost] == [lowestNode cost]) {
            if(node.h < lowestNode.h) {
                lowestNode = node;
            }
        }
    }
    return lowestNode;
}

@end

@implementation AStarNode

@synthesize point,parent,f,g,h;

+(id) nodeWithPoint:(CGPoint)newPoint
{
    return [[[AStarNode alloc] initWithPoint:newPoint] autorelease];
}

-(id) initWithPoint:(CGPoint)newPoint
{
    self.point = newPoint;
//    x = newPoint.x;
//    y = newPoint.y;
    
    return self;
}

-(int) cost
{
    return g + h;
}

-(int) f
{
    return g + h;
}

- (NSUInteger) hash
{
    int x = (int)point.x;
    int y = (int)point.y;
    return (x << 16) | (y & 0xFFFF);
}

- (BOOL)isEqual:(id)otherObject
{
    
    if (![otherObject isKindOfClass:[self class]])
    {
        return NO;
    }
    
    
    AStarNode *otherNode = (AStarNode*) otherObject;
    
    if (point.x == otherNode.point.x && point.y == otherNode.point.y)
    {
        return YES;
    }
    
    return NO;
}

@end