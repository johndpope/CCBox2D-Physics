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
        
        self.mass = 1;
        b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		bodyDef.allowSleep = true;
		bodyDef.position.Set(POINTS_TO_METERS(position.x), POINTS_TO_METERS(position.y));
		bodyDef.userData =  self;
		bodyDef.angle = CC_DEGREES_TO_RADIANS(angle);
		_body = _world->CreateBody(&bodyDef);
        
		        
		
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


    self.particleView = nil;
    if (particleView_ !=nil)[particleView_ release];
    

	[self removeBody];
    [super dealloc];
}



- (void)setRotationSpeed:(float)rotationSpeed
{
	//_rotationSpeed = rotationSpeed;
	self.body->SetAngularVelocity(CC_DEGREES_TO_RADIANS(rotationSpeed));
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
	/if (self.sprite != nil && _body != NULL)
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
    NSLog(@"applyForce x:%f y:%f",force.x,force.y);
    // get force and location in world coordinates
    b2Vec2 b2Force(force.x , force.y );
    b2Vec2 point = self.body->GetPosition();
    self.body->ApplyForce(b2Force, point);

}

-(CGPoint)getVelocity{
    b2Vec2 vel = self.body->GetLinearVelocity();
    return ccpMult(CGPointMake(vel.x, vel.y), PTM_RATIO);
}

-(void)setVelocity:(CGPoint)point{

    b2Vec2 v = b2Vec2(point.x ,point.y);
    self.body->SetLinearVelocity(v);

}


-(CGPoint)attraction:(ATParticle*)target{
   
    CGPoint d = CGPointSubtract(self.physicsPosition, target.position);
    CGFloat distance = MAX(1.0f, CGPointMagnitude(d));
    CGPoint direction = ( CGPointMagnitude(d) > 0.0 ) ? d : CGPointNormalize( CGPointRandom(1.0) );

    CGPoint a = CGPointScale(direction, (self.body->GetMass()*(target.body->GetMass()) ));
    CGPoint force = CGPointDivideFloat(a , (distance * distance) );

    //float strength = (g * mass * m.mass) / (distance * distance);
   // force.mult(strength);

    CGLog(@"force %@",force);
    CGLog(@"direction %@",direction);

    return force;

}
#pragma mark - Internal Interface


@end
