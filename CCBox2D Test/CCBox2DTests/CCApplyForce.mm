#import "CCApplyForce.h"
#import "CCBodySprite.h"
#import "CCJointSprite.h"
#import "CCSpringSprite.h"

@implementation CCApplyForce{
    
};

-(id) init
{

    self = [super init];
    
    if  (self!=nil){

        m_world->SetGravity(b2Vec2(0.0f, -1.0f));
        
		const float32 k_restitution = 5.4f;

        
        // Define the ground box shape.
        CCBodySprite *ground;
		{
            ground = [[CCBodySprite alloc]initWithWorld:m_world bodyType:b2_staticBody];
            ground.position = ccp(0.0f, 10.0f);
            //[self addChild:ground];
            [ground createBody];
            
			// Left vertical
           CCShape *leftEdge = [CCShape edgeWithVec1:b2Vec2(-20.0f, -20.0f)  vec2:b2Vec2(-20.0f, 20.0f)];
            leftEdge.density = 0.0f;
            leftEdge.restitution =k_restitution;
            [ground addShape:leftEdge named:@"leftEdge"];
            
			// Right vertical
            CCShape *rightEdge = [CCShape edgeWithVec1:b2Vec2(20.0f, -20.0f)  vec2:b2Vec2(20.0f, 20.0f)];
            rightEdge.density = 0.0f;
            rightEdge.restitution =k_restitution;
            [ground addShape:rightEdge named:@"rightEdge"];

			// Top horizontal
             CCShape *topEdge = [CCShape edgeWithVec1:b2Vec2(-20.0f, 20.0f)  vec2:b2Vec2(20.0f, 20.0f)];
             topEdge.density = 0.0f;
             topEdge.restitution =k_restitution;
             [ground addShape:topEdge named:@"topEdge"];
             
			// Bottom horizontal            
            CCShape *bottomEdge = [CCShape edgeWithVec1:b2Vec2(-20.0f, -20.0f)  vec2:b2Vec2(20.0f, -20.0f)];
            bottomEdge.density = 0.0f;
            bottomEdge.restitution =k_restitution;
            [ground addShape:bottomEdge named:@"bottomEdge"];
		}
        
		{
			b2Transform xf1;
			xf1.q.Set(0.3524f * b2_pi);
			xf1.p = xf1.q.GetXAxis();

            b2Vec2 vertices[3];
			vertices[0] = b2Mul(xf1, b2Vec2(-1.0f, 0.0f));
			vertices[1] = b2Mul(xf1, b2Vec2(1.0f, 0.0f));
			vertices[2] = b2Mul(xf1, b2Vec2(0.0f, 0.5f));
            
            CCShape *poly = [CCShape polygonWithVecVertices:vertices count:3];
			poly.density = 4.0f; 

			b2Transform xf2;
			xf2.q.Set(-0.3524f * b2_pi);
			xf2.p = -xf2.q.GetXAxis();
            
			vertices[0] = b2Mul(xf2, b2Vec2(-1.0f, 0.0f));
			vertices[1] = b2Mul(xf2, b2Vec2(1.0f, 0.0f));
			vertices[2] = b2Mul(xf2, b2Vec2(0.0f, 0.5f));
            
            CCShape *poly2 = [CCShape polygonWithVecVertices:vertices count:3];
			poly2.density = 2.0f;

            CCBodySprite *bd = [[CCBodySprite alloc]initWithWorld:m_world bodyType:b2_dynamicBody];
			bd.angularDamping = 5.0f;
			bd.damping = 0.1f;
            bd.rotation = b2_pi;
            bd.position = ccp(0.0f, 2.0);
            bd.sleepy = NO;
            
            [bd addShape:poly named:@"poly"];
            [bd addShape:poly2 named:@"poly2"];

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
                CCBodySprite *bd = [[CCBodySprite alloc]initWithWorld:m_world bodyType:b2_dynamicBody];
                bd.position = ccp(0.0f, 5.0f + 1.54f * i);
   
                CCShape *mShape = [CCShape boxWithFixtureDef:fd];
                [bd addShape:mShape named:[NSString stringWithFormat:@"fd%d",i]];

				float32 gravity = 10.0f;
				float32 I = bd.body->GetInertia();
				float32 mass = bd.body->GetMass();
                
				// For a circle: I = 0.5 * m * r * r ==> r = sqrt(2 * I / m)
				float32 radius = b2Sqrt(2.0f * I / mass);

				//b2FrictionJointDef jd;
                b2FrictionJointDef jd;
				jd.localAnchorA.SetZero();
				jd.localAnchorB.SetZero();
				jd.bodyA = ground.body;
				jd.bodyB = bd.body;
				jd.collideConnected = false;
				jd.maxForce = mass * gravity;
				jd.maxTorque = mass * radius * gravity;

                //CCSpringSprite *jointSprite = [[CCSpringSprite alloc] initWithWorld:m_world distanceJointDef:jd body1:ground body2:bd];
                //[jointSprite createJoint];
                m_world->CreateJoint(&jd);

                
			}
		}

        

    }
    return self;
}

@end