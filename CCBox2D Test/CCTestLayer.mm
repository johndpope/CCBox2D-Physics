#import "CCTestLayer.h"
#import "CCBodySprite.h"
#import "CCBox2DPrivate.h"
#import "Render.h"
#import <OpenGLES/ES1/gl.h>
#import "iPhoneTest.h"


@implementation CCTestLayer {

   // CCDestructionListener m_destructionListener;
	ContactConduit *_conduit;
    DebugDraw *_debugDraw;
}


-(id) init
{
	if ((self = [super init]))
	{
        b2Vec2 gravity;
        gravity.Set(0.0f, -10.0f);
        m_world = new b2World(gravity);
        
        //m_bomb = NULL;
        m_textLine = 30;
        m_mouseJoint = NULL;
        m_pointCount = 0;
        
        //settings = Settings();
        // TODO port the destruction listener
        //m_destructionListener.test = this;
        //m_destructionListener = new CCDestructionListener(self);
		//m_world->SetDestructionListener(m_destructionListener);
        
        _conduit = new ContactConduit(self);
		m_world->SetContactListener(_conduit);
        m_world->SetDebugDraw(&m_debugDraw);
        
        
        m_stepCount = 0;
        b2BodyDef bodyDef;
        m_groundBody = m_world->CreateBody(&bodyDef);
        
		// update every frame
		[self scheduleUpdate];
   
	}
	return self;
}

-(void) draw
{
	[super draw];
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    
	kmGLPushMatrix();
    
	m_world->DrawDebugData();
    
	kmGLPopMatrix();
    
	CHECK_GL_ERROR_DEBUG();
}

-(void) update:(ccTime)delta
{
	//[self step:settings];
}

- (void) dealloc
{
	// delete Box2D stuff
	delete _conduit;
	delete m_world;
    
    if(_debugDraw) delete _debugDraw;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}



-(void) registerWithTouchDispatcher
{
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];
    
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
    
	CGPoint diff = ccpSub(touchLocation,prevLocation);
    
	/*CCNode *node = [self getChildByTag:kTagBox2DNode];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, diff)];*/
}


-(void) onOverlapBody:(CCBodySprite *)sprite1 andBody:(CCBodySprite *)sprite2
{
    NSLog(@"onOverlapBody");
}

-(void) onSeparateBody:(CCBodySprite *)sprite1 andBody:(CCBodySprite *)sprite2
{
    NSLog(@"onSeparateBody");
}

-(void) onCollideBody:(CCBodySprite *)sprite1 andBody:(CCBodySprite *)sprite2 withForce:(float)force withFrictionForce:(float)frictionForce;
{
    NSLog(@"onCollideBody");
}

@end
