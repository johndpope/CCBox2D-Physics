#import "CCTestLayer.h"
#import "CCBodySprite.h"
#import "CCBox2DPrivate.h"
#import "Render.h"
#import <OpenGLES/ES1/gl.h>
#import "ATBarnesHutBranch.h"
#import "ATParticle.h"
#import "Box2DAppDelegate.h"


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
        appDelegate = (Box2DAppDelegate*) [[UIApplication sharedApplication] delegate];
   
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
   		//[self scheduleOnce:@selector(zoomInOnPlayer:) delay:0.0f];
        self.isDebugDrawing = YES;
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
    [self drawRect];
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
    
	// Make a tiny box. 
   
	b2AABB aabb;
	b2Vec2 d;
    d.Set(1, 1); // 1x1 meter
    //d.Set(0.1f, 0.1f); // 10cm x 10cm meter
    //d.Set(0.01f, 0.01f); // 1cm x 1cm meter
    //d.Set(0.001f, 0.001f); // 10mm x 10mm 
    
	d.Set(0.001f, 0.001f); // 
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

//this isn't working!!
-(void) createBounds {
    
    // for the screenBorder body we'll need these values
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    float widthInMeters = screenSize.width / PTM_RATIO;
    float heightInMeters = screenSize.height / PTM_RATIO;
    b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
    b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
    b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
    b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
    
    // static container body, with the collisions at screen borders
    b2BodyDef screenBorderDef;
    screenBorderDef.position.Set(0, 0);
    b2Body* screenBorderBody = m_world->CreateBody(&screenBorderDef);
    b2EdgeShape screenBorderShape;
    
    // Create fixtures for the four borders (the border shape is re-used)
    screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0);
    screenBorderShape.Set(lowerRightCorner, upperRightCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0);
    screenBorderShape.Set(upperRightCorner, upperLeftCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0);
    screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0);

}



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




- (void) drawRect
{
   // NSLog(@"drawRect");
    
    if ( appDelegate.system ) {

        if (self.isDebugDrawing) {
            
            // Drawing code for the barnes-hut trees
            ATBarnesHutBranch *root = appDelegate.system.physics.bhTree.root;
            
            if ( root ) {
                [self recursiveDrawBranches:root];
            }
            // Draw bounds target (due to translation will always be the outeredge in display)

            [self createLineByRect:[self scaleRect:appDelegate.system.tweenBoundsTarget]];
    
            
            // Draw bounds current (this is a relative representation of the view window you see
            // with all the nodes. It shows what the "camera" is doing to keep elements centered in
            // view)
            [self createLineByRect:[self scaleRect:appDelegate.system.tweenBoundsCurrent]];

        }
        

        // Drawing code for springs
       /* for (ATSpring *spring in appDelegate.system.physics.springs) {
            //  NSLog(@"spring:%@",spring.userData);
        
           // [self drawSpring:spring inContext:context];
            
        }

        CGContextSetLineWidth(context, 2.0);
        // Drawing code for particle centers
        /*for (ATParticle *particle in appDelegate.system.physics.particles) {
            //[self updateParticleViewPosition:particle];
        }*/

    }
    
}

#pragma mark - Internal Interface

- (CGSize) sizeToScreen:(CGSize)s
{
    return [appDelegate.system toViewSize:s];
}

- (CGPoint) pointToScreen:(CGPoint)p
{
    return [appDelegate.system toViewPoint:p];
}

- (CGRect) scaleRect:(CGRect)rect
{
    return [appDelegate.system toViewRect:rect];
}

-(void)createLineByRect:(CGRect)rect{
    //NSLog(@"rect w:%f",rect.size.width);
    //NSLog(@"rect h:%f",rect.size.height);
    
    [self createLineByRect:rect color:ccc4(0, 0, 1, 1)];
}
-(void)createLineByRect:(CGRect)rect color:(ccColor4B)color
{
    return;
    CCLayerColor* layer = [CCLayerColor layerWithColor:color width:rect.size.width*PTM_RATIO height:rect.size.height*PTM_RATIO];
    layer.position = rect.origin;
    [self addChild:layer];
    
}

- (void) recursiveDrawBranches:(ATBarnesHutBranch *)branch
{
    // Draw the rect
    [self createLineByRect:[self scaleRect:branch.bounds]];
    
    // Draw any sub branches
    if (branch.se != nil && [branch.se isKindOfClass:ATBarnesHutBranch.class] == YES) {
        [self recursiveDrawBranches:branch.se];
    }
    
    if (branch.sw != nil && [branch.sw isKindOfClass:ATBarnesHutBranch.class] == YES ) {
        [self recursiveDrawBranches:branch.sw ];
    }
    
    if (branch.ne != nil && [branch.ne isKindOfClass:ATBarnesHutBranch.class] == YES ) {
        [self recursiveDrawBranches:branch.ne ];
    }
    
    if (branch.nw != nil && [branch.nw isKindOfClass:ATBarnesHutBranch.class] == YES ) {
        [self recursiveDrawBranches:branch.nw ];
    }
    
}


@end
