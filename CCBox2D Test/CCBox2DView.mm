
#import "CCBox2DView.h"
#import "CCBodySprite.h"
#import "CCShape.h"
#import "CCWorldLayer.h"



#pragma mark -
#pragma mark CCBox2DView
@implementation CCBox2DView

+(id) viewWithEntryID:(int)entryId
{
	return [[[self alloc] initWithEntryID:entryId] autorelease];
}

- (id) initWithEntryID:(int)entryId
{
    if ((self = [super init])) {
        
		self.accelerometerEnabled = YES;
		self.touchEnabled = YES;
        
		[self schedule:@selector(tick:)];
        
		//entry = g_testEntries + entryId;
		//test = entry->createFcn();
 
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);


        // Define the gravity vector.
		/*self.gravity = ccp(0.0f, -320.0f);
		
		// Define the simulation accuracy
		self.velocityIterations = 8;
		self.positionIterations = 1;

        return self;
         CCBodySprite* ground = [CCBodySprite node];
		ground.physicsType = kStatic;
        [self addChild:ground];
        
        // Define the ground box shape.
        CCArray* bottom = [[CCArray alloc]initWithCapacity:4];
		[bottom addObject:[NSValue valueWithCGPoint:ccp(0, 0)]];
        [bottom addObject:[NSValue valueWithCGPoint:ccp(1, 1)]];
        [bottom addObject:[NSValue valueWithCGPoint:ccp(screenSize.width, 0)]];
        CCShape *ccBottom = [CCShape polygonWithVertices:bottom];
        [ground addShape:ccBottom named:@"bottom"];
        
		CCArray* top = [CCArray arrayWithCapacity:4];
		[top addObject:[NSValue valueWithCGPoint:ccp(0, screenSize.height)]];
        [top addObject:[NSValue valueWithCGPoint:ccp(1, screenSize.height-1)]];
		[top addObject:[NSValue valueWithCGPoint:ccp(screenSize.width, screenSize.height)]];
         [top addObject:[NSValue valueWithCGPoint:ccp(screenSize.width, screenSize.height-1)]];
        [ground addShape:[CCShape polygonWithVertices:top] named:@"top"];
        
		CCArray* left = [CCArray arrayWithCapacity:4];
		[left addObject:[NSValue valueWithCGPoint:ccp(0, screenSize.height)]];
		[left addObject:[NSValue valueWithCGPoint:ccp(0, 0)]];
        [left addObject:[NSValue valueWithCGPoint:ccp(1, 1)]];
		[ground addShape:[CCShape polygonWithVertices:left] named:@"left"];
		
		CCArray* right = [CCArray arrayWithCapacity:4];
		[right addObject:[NSValue valueWithCGPoint:ccp(screenSize.width, screenSize.height)]];
        [right addObject:[NSValue valueWithCGPoint:ccp(screenSize.width-1, screenSize.height)]];
		[right addObject:[NSValue valueWithCGPoint:ccp(screenSize.width, 0)]];
        [ground addShape:[CCShape polygonWithVertices:right] named:@"right"];
		
 
       CCBodySprite *bd = [CCBodySprite node];
       // bd.world = self;
        CCShape *polygonShape = [CCShape boxWithRect:CGRectMake(0, 0, 15.0f, 15.0f)];
        [bd addShape:polygonShape named:@"polygonShape"];
        bd.position = ccp(-40.0f, 5.0f);
        bd.bullet = YES;
        [bd setVelocity:ccp(150.0f, 0.0f)];
        [self addChild:bd];
        
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
		[self addChild:batch z:0 tag:1];*/
        
    }
    
    return self;
}

-(NSString*) title
{
	return @"CCBox2D";
}

- (void)tick:(ccTime) dt
{
	//test->Step(&settings);
}
/*
-(void) draw
{
	[super draw];
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
	kmGLPushMatrix();
    
	//test->m_world->DrawDebugData();
    //[world draw];
	kmGLPopMatrix();
    
	CHECK_GL_ERROR_DEBUG();
}*/

- (void)dealloc
{

	//delete test;

    [super dealloc];
}

-(void) registerWithTouchDispatcher
{
	// higher priority than dragging
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:-10 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
    
    
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
	NSLog(@"pos: %f,%f -> %f,%f", touchLocation.x, touchLocation.y, nodePosition.x, nodePosition.y);
    
	return YES;//test->MouseDown(b2Vec2(nodePosition.x,nodePosition.y));
}

- (void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
    
	//test->MouseMove(b2Vec2(nodePosition.x,nodePosition.y));
}

- (void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
    
	//test->MouseUp(b2Vec2(nodePosition.x,nodePosition.y));
}


- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	// Only run for valid values
	if (acceleration.y!=0 && acceleration.x!=0)
	{
		//if (test) test->SetGravity((float)-acceleration.y,(float)acceleration.x);
	}
}


@end
