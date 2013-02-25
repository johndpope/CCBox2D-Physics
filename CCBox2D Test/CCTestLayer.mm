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
        self.touchEnabled = YES;
        
        b2Vec2 gravity;
        gravity.Set(0.0f, -10.0f);
        m_world = new b2World(gravity);
        
        settings = new Settings();
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

- (void) dealloc
{
	// delete Box2D stuff
	delete _conduit;
	delete m_world;
    
    if(_debugDraw) delete _debugDraw;
	
	// don't forget to call "super dealloc"
	[super dealloc];
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
	[self step:settings];
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
 //   NSLog(@"onOverlapBody");
}

-(void) onSeparateBody:(CCBodySprite *)sprite1 andBody:(CCBodySprite *)sprite2
{
  //  NSLog(@"onSeparateBody");
}

-(void) onCollideBody:(CCBodySprite *)sprite1 andBody:(CCBodySprite *)sprite2 withForce:(float)force withFrictionForce:(float)frictionForce;
{
 //   NSLog(@"onCollideBody");
}



//Debug Test Bed stuff

-(void)step:(Settings*)_settings
{
	float32 timeStep = settings->hz > 0.0f ? 1.0f / settings->hz : float32(0.0f);
    
	if (settings->pause)
	{
		if (settings->singleStep)
		{
			settings->singleStep = 0;
		}
		else
		{
			timeStep = 0.0f;
		}
        
		m_debugDraw.DrawString(5, m_textLine, "****PAUSED****");
		m_textLine += 15;
	}
    
	uint32 flags = 0;
	flags += settings->drawShapes			* b2Draw::e_shapeBit;
	flags += settings->drawJoints			* b2Draw::e_jointBit;
	flags += settings->drawAABBs			* b2Draw::e_aabbBit;
	flags += settings->drawPairs			* b2Draw::e_pairBit;
	flags += settings->drawCOMs				* b2Draw::e_centerOfMassBit;
	m_debugDraw.SetFlags(flags);
    
	m_world->SetWarmStarting(settings->enableWarmStarting > 0);
	m_world->SetContinuousPhysics(settings->enableContinuous > 0);
    
	m_pointCount = 0;
    
	m_world->Step(timeStep, settings->velocityIterations, settings->positionIterations);
    
    //	m_world->DrawDebugData();
    
	if (timeStep > 0.0f)
	{
		++m_stepCount;
	}
    
	if (settings->drawStats)
	{
		m_debugDraw.DrawString(5, m_textLine, "bodies/contacts/joints/proxies = %d/%d/%d",
							   m_world->GetBodyCount(), m_world->GetContactCount(), m_world->GetJointCount(), m_world->GetProxyCount());
		m_textLine += 15;
	}
    
	if (m_mouseJoint)
	{
        
	}
    
    
    
	if (settings->drawContactPoints)
	{
		//const float32 k_impulseScale = 0.1f;
		const float32 k_axisScale = 0.3f;
        
		for (int32 i = 0; i < m_pointCount; ++i)
		{
			ContactPoint* point = m_points + i;
            
			if (point->state == b2_addState)
			{
				// Add
				m_debugDraw.DrawPoint(point->position, 10.0f, b2Color(0.3f, 0.95f, 0.3f));
			}
			else if (point->state == b2_persistState)
			{
				// Persist
				m_debugDraw.DrawPoint(point->position, 5.0f, b2Color(0.3f, 0.3f, 0.95f));
			}
            
			if (settings->drawContactNormals == 1)
			{
				b2Vec2 p1 = point->position;
				b2Vec2 p2 = p1 + k_axisScale * point->normal;
				m_debugDraw.DrawSegment(p1, p2, b2Color(0.4f, 0.9f, 0.4f));
			}
			else if (settings->drawContactForces == 1)
			{
				//b2Vec2 p1 = point->position;
				//b2Vec2 p2 = p1 + k_forceScale * point->normalForce * point->normal;
				//DrawSegment(p1, p2, b2Color(0.9f, 0.9f, 0.3f));
			}
            
			if (settings->drawFrictionForces == 1)
			{
				//b2Vec2 tangent = b2Cross(point->normal, 1.0f);
				//b2Vec2 p1 = point->position;
				//b2Vec2 p2 = p1 + k_forceScale * point->tangentForce * tangent;
				//DrawSegment(p1, p2, b2Color(0.9f, 0.9f, 0.3f));
			}
		}
	}
}
@end
