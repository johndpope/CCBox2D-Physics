#import "CCTestLayer.h"
#import "CCBodySprite.h"
#import "CCBox2DPrivate.h"
#import "Render.h"
#import <OpenGLES/ES1/gl.h>




@implementation CCTestLayer {

   // CCDestructionListener m_destructionListener;
	ContactConduit *_conduit;
    DebugDraw *_debugDraw;
}


enum {
	kTagBox2DNode,
};

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
   		[self scheduleOnce:@selector(zoomInOnPlayer:) delay:0.0f];
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
    NSLog(@"registerWithTouchDispatcher");
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}



- (BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{

	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
	NSLog(@"pos: %f,%f -> %f,%f", touchLocation.x, touchLocation.y, nodePosition.x, nodePosition.y);
    
	return [self mouseDown:(b2Vec2(nodePosition.x,nodePosition.y))];
}

- (void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
   // NSLog(@"ccTouchMoved");
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
    
	[self mouseMove:(b2Vec2(nodePosition.x,nodePosition.y))];
}

- (void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
    NSLog(@"ccTouchEnded");
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
    
	[self mouseUp:(b2Vec2(nodePosition.x,nodePosition.y))];
}

-(void) onOverlapBody:(CCBodySprite *)sprite1 andBody:(CCBodySprite *)sprite2
{
  //  NSLog(@"onOverlapBody");
}

-(void) onSeparateBody:(CCBodySprite *)sprite1 andBody:(CCBodySprite *)sprite2
{
 //   NSLog(@"onSeparateBody");
}

-(void) onCollideBody:(CCBodySprite *)sprite1 andBody:(CCBodySprite *)sprite2 withForce:(float)force withFrictionForce:(float)frictionForce;
{
//    NSLog(@"onCollideBody");
}




-(BOOL)mouseDown:( b2Vec2 )p
{
    NSLog(@"mouseDown");
	m_mouseWorld = p;
    
	if (m_mouseJoint != NULL)
	{
		return NO;
	}
    
	// Make a small box.
	b2AABB aabb;
	b2Vec2 d;
	d.Set(0.001f, 0.001f);
	aabb.lowerBound = p - d;
	aabb.upperBound = p + d;
    
	// Query the world for overlapping shapes.
	TestQueryCallback callback(p);
	m_world->QueryAABB(&callback, aabb);
    
	if (callback.m_fixture)
	{
		b2Body* body = callback.m_fixture->GetBody();
		b2MouseJointDef md;
		md.bodyA = m_groundBody;
		md.bodyB = body;
		md.target = p;
		md.maxForce = 1000.0f * body->GetMass();
        
		m_mouseJoint = (b2MouseJoint*)m_world->CreateJoint(&md);
		body->SetAwake(true);
        
        void* userData = body->GetUserData();
        if ([(id)userData isKindOfClass:[CCBodySprite class]]){
            if (((CCBodySprite*)userData).onTouchDownBlock !=nil) {
                ((CCBodySprite*)userData).onTouchDownBlock();
            }           
        }
       
        
		return true;
	}
    
	return false;
}

-(void)shiftMouseDown:( b2Vec2 )p
{
	m_mouseWorld = p;
    
	if (m_mouseJoint != NULL)
	{
		return;
	}
    
}

-(void)mouseUp:( b2Vec2 )p
{
	if (m_mouseJoint)
	{
		m_world->DestroyJoint(m_mouseJoint);
		m_mouseJoint = NULL;
	}

}

-(void)mouseMove:( b2Vec2 )p
{
	m_mouseWorld = p;
    
	if (m_mouseJoint)
	{
		m_mouseJoint->SetTarget(p);
	}
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
    
    //m_world->DrawDebugData();
    
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


-(CCBodySprite*) createGround:(CGSize)size {
    
    float width = size.width;
	float height =  size.height;
    if([[CCDirector sharedDirector] enableRetinaDisplay:YES] ){
        width = width*2;
        height = height*2;
    }
 
    float32 margin = 5.0f;
    b2Vec2 lowerLeft = b2Vec2(margin/PTM_RATIO, margin/PTM_RATIO);
    b2Vec2 lowerRight = b2Vec2((width-margin)/PTM_RATIO,margin/PTM_RATIO);
    b2Vec2 upperRight = b2Vec2((width-margin)/PTM_RATIO, (height-margin)/PTM_RATIO);
    b2Vec2 upperLeft = b2Vec2(margin/PTM_RATIO, (height-margin)/PTM_RATIO);
    

    b2BodyDef bd;
    bd.type = b2_staticBody;
    bd.position.Set(0.0f, 0.0f);
    
    
    const float32 k_restitution = 0.4f;
	
    
    CCBodySprite *ground = [[CCBodySprite alloc]init];
    [ground configureSpriteForWorld:m_world bodyDef:bd];
    

    // Left vertical
    CCShape *leftEdge = [CCShape edgeWithVec1:lowerLeft  vec2:upperLeft];
    leftEdge.restitution =k_restitution;
    [ground addShape:leftEdge named:@"leftEdge"];
    
    // Right vertical
    CCShape *rightEdge = [CCShape edgeWithVec1:lowerRight  vec2:upperRight];
    rightEdge.restitution =k_restitution;
    [ground addShape:rightEdge named:@"rightEdge"];
    
    // Top horizontal
    CCShape *topEdge = [CCShape edgeWithVec1:upperLeft  vec2:upperRight];
    topEdge.restitution =k_restitution;
    [ground addShape:topEdge named:@"topEdge"];
    
    // Bottom horizontal
    CCShape *bottomEdge = [CCShape edgeWithVec1:lowerLeft  vec2:lowerRight];
    bottomEdge.restitution =k_restitution;
    [ground addShape:bottomEdge named:@"bottomEdge"];
    
    return ground;
}

const float kZoomInFactor = 15.0f;

-(void) zoomInOnPlayer:(ccTime)delta
{
	// just to be sure no other actions interfere
	[self stopAllActions];
	
	isZooming = YES;
	id zoomIn = [CCScaleTo actionWithDuration:0.0f scale:kZoomInFactor];
	id zoomOut = [CCScaleTo actionWithDuration:2.0f scale:1.0f];
	id reset = [CCCallBlock actionWithBlock:^{
		CCLOG(@"zoom in/out complete");
		isZooming = NO;
		self.position = CGPointZero;
		//[self scheduleOnce:@selector(zoomInOnPlayer:) delay:CCRANDOM_0_1() * 2.0f + 2.0f];
	}];
	id sequence = [CCSequence actions: zoomIn, nil]; //zoomOut, reset,
	[self runAction:sequence];
}



@end
