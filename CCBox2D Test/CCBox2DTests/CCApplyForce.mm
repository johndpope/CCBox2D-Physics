#import "CCApplyForce.h"
#import "CCBodySprite.h"

@implementation CCApplyForce{
    
};

-(id) init
{

    self = [super init];
    
    if  (self!=nil){

        m_world->SetGravity(b2Vec2(0.0f, 0.0f));
        
		const float32 k_restitution = 0.4f;
        
		b2Body* ground;
		{
			b2BodyDef bd;
			bd.position.Set(0.0f, 20.0f);
			ground = m_world->CreateBody(&bd);
            
			b2EdgeShape shape;
            
			b2FixtureDef sd;
			sd.shape = &shape;
			sd.density = 0.0f;
			sd.restitution = k_restitution;
            
			// Left vertical
			shape.Set(b2Vec2(-20.0f, -20.0f), b2Vec2(-20.0f, 20.0f));
			ground->CreateFixture(&sd);
            
			// Right vertical
			shape.Set(b2Vec2(20.0f, -20.0f), b2Vec2(20.0f, 20.0f));
			ground->CreateFixture(&sd);
            
			// Top horizontal
			shape.Set(b2Vec2(-20.0f, 20.0f), b2Vec2(20.0f, 20.0f));
			ground->CreateFixture(&sd);
            
			// Bottom horizontal
			shape.Set(b2Vec2(-20.0f, -20.0f), b2Vec2(20.0f, -20.0f));
			ground->CreateFixture(&sd);
		}
        
		{
			b2Transform xf1;
			xf1.q.Set(0.3524f * b2_pi);
			xf1.p = xf1.q.GetXAxis();
            
			b2Vec2 vertices[3];
			vertices[0] = b2Mul(xf1, b2Vec2(-1.0f, 0.0f));
			vertices[1] = b2Mul(xf1, b2Vec2(1.0f, 0.0f));
			vertices[2] = b2Mul(xf1, b2Vec2(0.0f, 0.5f));
            
			b2PolygonShape poly1;
			poly1.Set(vertices, 3);
            
			b2FixtureDef sd1;
			sd1.shape = &poly1;
			sd1.density = 4.0f;
            
			b2Transform xf2;
			xf2.q.Set(-0.3524f * b2_pi);
			xf2.p = -xf2.q.GetXAxis();
            
			vertices[0] = b2Mul(xf2, b2Vec2(-1.0f, 0.0f));
			vertices[1] = b2Mul(xf2, b2Vec2(1.0f, 0.0f));
			vertices[2] = b2Mul(xf2, b2Vec2(0.0f, 0.5f));
            
			b2PolygonShape poly2;
			poly2.Set(vertices, 3);
            
			b2FixtureDef sd2;
			sd2.shape = &poly2;
			sd2.density = 2.0f;
            
			b2BodyDef bd;
			bd.type = b2_dynamicBody;
			bd.angularDamping = 5.0f;
			bd.linearDamping = 0.1f;
            
			bd.position.Set(0.0f, 2.0);
			bd.angle = b2_pi;
			bd.allowSleep = false;
			m_body = m_world->CreateBody(&bd);
			m_body->CreateFixture(&sd1);
			m_body->CreateFixture(&sd2);
		}
        
		{
			b2PolygonShape shape;
			shape.SetAsBox(0.5f, 0.5f);
            
			b2FixtureDef fd;
			fd.shape = &shape;
			fd.density = 1.0f;
			fd.friction = 0.3f;
            
			for (int i = 0; i < 10; ++i)
			{
				b2BodyDef bd;
				bd.type = b2_dynamicBody;
                
				bd.position.Set(0.0f, 5.0f + 1.54f * i);
				b2Body* body = m_world->CreateBody(&bd);
                
				body->CreateFixture(&fd);
                
				float32 gravity = 10.0f;
				float32 I = body->GetInertia();
				float32 mass = body->GetMass();
                
				// For a circle: I = 0.5 * m * r * r ==> r = sqrt(2 * I / m)
				float32 radius = b2Sqrt(2.0f * I / mass);
                
				b2FrictionJointDef jd;
				jd.localAnchorA.SetZero();
				jd.localAnchorB.SetZero();
				jd.bodyA = ground;
				jd.bodyB = body;
				jd.collideConnected = true;
				jd.maxForce = mass * gravity;
				jd.maxTorque = mass * radius * gravity;
                
				m_world->CreateJoint(&jd);
			}
		}

        
        /*CCBodySprite *bd = [[CCBodySprite alloc]init];
         CCShape *polygonShape = [CCShape boxWithRect:CGRectMake(0, 0, 1.5f, 1.5f)];
         [bd addShape:polygonShape named:@"polygonShape"];
         //[polygonShape addFixtureToBody:bd];
         bd.position = ccp(-40.0f, 5.0f);
         bd.bullet = YES;
         [bd setVelocity:ccp(150.0f, 0.0f)];
        [self addChild:bd];*/
    }
    return self;
}

@end