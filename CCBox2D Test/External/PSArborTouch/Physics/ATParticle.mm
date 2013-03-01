//
//  ATParticle.m
//  PSArborTouch
//
//  Created by Ed Preston on 19/09/11.
//  Copyright 2011 Preston Software. All rights reserved.
//

#import "ATParticle.h"
#import "ATGeometry.h"
#import "CCNode.h"
#import "Box2D.h"
#import "cocos2d.h"
#import "Defs.h"

@interface ATParticle ()
// reserved
@end


@implementation ATParticle

@synthesize velocity    = velocity_;
@synthesize force       = force_;
@synthesize tempMass    = tempMass_;
@synthesize connections = connections_;
@synthesize particleView = particleView_;
@synthesize sprite = sprite_;

#define PTM_RATIO 32.f
- (id) init
{
    self = [super init];
    if (self) {
    
        velocity_       = CGPointZero;
        force_          = CGPointZero;
        tempMass_       = 0.0;
        connections_    = 0;
    }
    return self;
}






- (id)initWithWorld:(b2World *)world size:(int)size position:(CGPoint)position angle:(float)angle name:(NSString*)name userData:(NSMutableDictionary*)data
{
    
    self = [self init];
    if (self) {
     
        _world =  world;
        name_ = [name copy];
        data_ = [data retain];
        
        //self.mass = 1;
        b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		bodyDef.allowSleep = true;
		bodyDef.position.Set(POINTS_TO_METERS(position.x), POINTS_TO_METERS(position.y));
		bodyDef.userData =  self;
		bodyDef.angle = CC_DEGREES_TO_RADIANS(angle);
		_body = _world->CreateBody(&bodyDef);
        
		self.sprite = [[CCSprite spriteWithFile:@"Kirby.png" rect:CGRectMake(0, 0, 64, 64)]retain];
        
        self.sprite.position = ccp(100, 300);
        self.position =  ccp(100, 300);
        self.physicsPosition = position;
		self.sprite.rotation = -angle;
        
        
		b2CircleShape shape;
		shape.m_radius =  POINTS_TO_METERS(self.sprite.contentSize.width);
        
		b2FixtureDef fixtureDef;
		fixtureDef.shape = &shape;
		fixtureDef.friction = 1.0f;
		fixtureDef.restitution = 1.0f;
		fixtureDef.density = (1.0f - shape.m_radius*shape.m_radius) * 0.5f;  // trial-and-error
		_body->CreateFixture(&fixtureDef);
        [self createPhysicsObject];

    }
    return self;
    
}


- (void) createPhysicsObject{
    // Center is the position of the circle that is in the center (inner circle)
    b2Vec2 center = b2Vec2(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    b2CircleShape circleShape;
    circleShape.m_radius = 0.1f;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &circleShape;
    fixtureDef.density = 0.1;
    fixtureDef.restitution = 0.05;
    fixtureDef.friction = 1.0;
        
    // Circle at the center (inner circle)
    b2BodyDef innerCircleBodyDef;
    // Make the inner circle larger
    circleShape.m_radius = 15.0f;
    innerCircleBodyDef.type = b2_dynamicBody;
    
    // Position is at the center
    innerCircleBodyDef.position = center;
    self.body = _world->CreateBody(&innerCircleBodyDef);
    self.body->CreateFixture(&fixtureDef);
    
    [self createBody];
    
    
}



- (void)dealloc
{
	NSLog(@"dealloc %@", self);

    [sprite_ release];    self.sprite = nil;
    self.particleView = nil;
    if (particleView_ !=nil)[particleView_ release];
    
	[self removeSprite];
	[self removeBody];
    [super dealloc];
}



- (void)setRotationSpeed:(float)rotationSpeed
{
	//_rotationSpeed = rotationSpeed;
	_body->SetAngularVelocity(CC_DEGREES_TO_RADIANS(rotationSpeed));
}

/*- (CGPoint)position
{
	return _sprite.position;
}*/

- (void)addSpriteTo:(CCNode *)parent
{
	[parent addChild:self.sprite];
}

- (void)removeSprite
{
	if (self.sprite != NULL)
	{
		[self.sprite removeFromParentAndCleanup:YES];
		self.sprite = nil;
	}
}

- (void)removeBody
{
	if (_body != NULL)
	{
		_world->DestroyBody(_body);
		_body = NULL;
	}
}

/*- (void)update:(ccTime)dt
{
    //NSLog(@"update particle");
	/*if (self.sprite != nil && _body != NULL)
	{
        //NSLog(@"_body->GetPosition().x:%f",_body->GetPosition().x);
       // NSLog(@"_body->GetPosition().y:%f",_body->GetPosition().y);
   
        self.position = ccp(_body->GetPosition().x * PTM_RATIO,
                                _body->GetPosition().y * PTM_RATIO);
        
        //NSLog(@"x:%f",self.position.x);
        //NSLog(@"y:%f",self.position.y);
		self.rotation = -1.0f * CC_RADIANS_TO_DEGREES(_body->GetAngle());
	}*/
//}

- (void) applyForce:(CGPoint)force
{
   // NSLog(@"applyForce");
    //self.position = CGPointAdd(self.force, CGPointDivideFloat(force, self.mass));
    [self applyForce:CGPointAdd(self.force, CGPointDivideFloat(force, self.mass)) asImpulse:NO];
}

#pragma mark - Internal Interface


@end
