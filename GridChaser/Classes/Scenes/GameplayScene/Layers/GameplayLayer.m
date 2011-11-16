//
//  GameplayLayer.m
//  GridChaser
//
//  Created by Shervin Ghazazani on 11-08-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameplayLayer.h"
#import "Constants.h"
#import "FileConstants.h"
#import "GameScene.h"

@implementation GameplayLayer

@synthesize gameMap;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	GameScene *scene = [GameScene node];
	
	// 'layer' is an autorelease object.
	GameplayLayer *layer = [GameplayLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
    [player release];
    [gameMap release];
    [spriteBatchNode release];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        self.isTouchEnabled = YES;
        //self.isAccelerometerEnabled = YES;
        
        #if CC_ENABLE_PROFILERS
        updateLoopProfiler = [[CCProfiler timerWithName:@"updateProfiler" andInstance:self] retain];
        #endif
        
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval: (1.0 / 60)];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:kSpriteSheetPlist];
        
        //TODO: Give a better capacity value to prevent unneccessary resizing.
        spriteBatchNode = [[CCSpriteBatchNode alloc] initWithFile:kSpriteSheetImage capacity:0];
        
        gameMap = [[Map alloc] init];
        
        director = [[AIDirector alloc] init];
        director.gameplayLayerDelegate = self;
        
        //Initialize Player and Enemy
        player = [[PlayerCar alloc] initWithSpriteFrameName:kPlayerCarImage];
        player.mapDelegate = gameMap;
        player.gameplayLayerDelegate = self;
        player.state = kStateMoving;
        player.tag = kPlayerCarTag;
        
        CCTMXObjectGroup *objects = [gameMap objectGroupNamed:kMapObjectLayer];
        NSAssert(objects != nil, @"Objects group not found");
        
        NSMutableDictionary *spawnPoint = [objects objectNamed:kMapObjectSpawnPoint1];
        NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
        int x = [[spawnPoint valueForKey:@"x"] intValue];
        int y = [[spawnPoint valueForKey:@"y"] intValue];
        player.position = CGPointMake(x, y);
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        leftButtonArrow = [CCMenuItemImage itemFromNormalImage:kGuiLeftArrow selectedImage:kGuiLeftArrow 
                                                        target:self selector:@selector(leftArrowButtonTapped:)];
        leftButtonArrow.position = ccp(0+20,winSize.height * 0.5);
        
        rightButtonArrow = [CCMenuItemImage itemFromNormalImage:kGuiRightArrow selectedImage:kGuiRightArrow 
                                                         target:self selector:@selector(rightArrowButtonTapped:)];
        rightButtonArrow.position = ccp(winSize.width - 20, winSize.height * 0.5);
        
        guiMenu = [CCMenu menuWithItems:leftButtonArrow,rightButtonArrow, nil];
        guiMenu.position = CGPointZero;
        
        [self addGameObject:kGameObjectMarker];
        
        [spriteBatchNode addChild:player z:kGameObjectZValue tag:kPlayerCarTag];
        [self addChild:spriteBatchNode z:2];
        [self addChild:gameMap z:1];
        [self addChild:guiMenu z:3];
        
        [self scheduleUpdate];
    }
	return self;
}

-(void) update:(ccTime)deltaTime 
{
    #if CC_ENABLE_PROFILERS
        CCProfilingBeginTimingBlock(updateLoopProfiler);
    #endif
    
    CCArray *listOfGameObjects = [spriteBatchNode children];
    for (GameCharacter *tempChar in listOfGameObjects) {
        [tempChar updateWithDeltaTime:deltaTime andArrayOfGameObjects:listOfGameObjects];
    }
    
    [director updateWithDeltaTime:deltaTime andArrayOfGameObjects:listOfGameObjects];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(player.position.x, winSize.width / 2);
    int y = MAX(player.position.y, winSize.height / 2);
    
    x = MIN(x, (gameMap.mapSize.width * gameMap.tileSize.width) 
            - winSize.width / 2);
    y = MIN(y, (gameMap.mapSize.height * gameMap.tileSize.height) 
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView,actualPosition);
    self.position = viewPoint;
    guiMenu.position = ccpNeg(viewPoint);    
    
    #if CC_ENABLE_PROFILERS
        CCProfilingEndTimingBlock(updateLoopProfiler);
    #endif
}

#define kFilteringFactor 0.1
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration{
    static float prevX=0, prevY=0, prevZ=0;
    
    float accelX = acceleration.x - ( (acceleration.x * kFilteringFactor) + (prevX * (1.0 - kFilteringFactor)) );
    float accelY = acceleration.y - ( (acceleration.y * kFilteringFactor) + (prevY * (1.0 - kFilteringFactor)) );
    float accelZ = acceleration.z - ( (acceleration.z * kFilteringFactor) + (prevZ * (1.0 - kFilteringFactor)) );
    
    if (accelY > 0.20) {
        player.direction = kDirectionRight;
    }
    else if(accelY < -0.20) {
        player.direction = kDirectionLeft;
    }    
    //CCLOG(@"accelY: %f",accelY);
    
    prevX = accelX;
    prevY = accelY;
    prevZ = accelZ;
}

- (void) addGameObject:(GameObjectType)type 
{
    if(type == kGameObjectMarker) {
        CGPoint newMarkerTileCoord = ccp(-1, -1);
        while ([gameMap isCollidableWithTileCoord:newMarkerTileCoord]) {
            int x = arc4random() % (int)gameMap.mapSize.width;
            int y = arc4random() % (int)gameMap.mapSize.height;
            newMarkerTileCoord = ccp(x, y);
        }
        newMarkerTileCoord = [gameMap.collisionLayer positionAt:newMarkerTileCoord];
        newMarkerTileCoord.x = newMarkerTileCoord.x + gameMap.tileSize.width * 0.5;
        newMarkerTileCoord.y = newMarkerTileCoord.y + gameMap.tileSize.height * 0.5;
        
        Marker *newMarker = [Marker spriteWithSpriteFrameName:kRedBuildingImage];
        newMarker.position = newMarkerTileCoord;
        newMarker.tag = kMarkerTag;
        
        [spriteBatchNode addChild:newMarker];
    }
    else if(type == kGameObjectEnemyCar) {
        EnemyCar *enemy = [EnemyCar spriteWithSpriteFrameName:kEnemyCarImage];
        enemy.mapDelegate = gameMap;
        enemy.state = kStateMoving;
        
        CGPoint spawnPoint = [gameMap centerPositionAt:CGPointMake(25, 4)];
        enemy.position = spawnPoint;
        
        [spriteBatchNode addChild:enemy z:kGameObjectZValue tag:kEnemyCarTag];
    }
}

- (void) leftArrowButtonTapped:(id)sender {
    player.direction = kDirectionLeft;
    #if GRID_CHASER_DEBUG_MODE
        CCLOG(@"Tapped Left!");
    #endif
}

- (void) rightArrowButtonTapped:(id)sender {
    player.direction = kDirectionRight;
    #if GRID_CHASER_DEBUG_MODE
        CCLOG(@"Tapped Right");
    #endif
}

@end
