#import "CCAddPair.h"
#import "CCBodySprite.h"

@implementation CCAddPair{
    
};

-(id) init
{

    self = [super init];
    
    if  (self!=nil){

        m_world->SetGravity(b2Vec2(0.0f,0.0f));
		{
            
            
			b2CircleShape shape;
			shape.m_p.SetZero();
			shape.m_radius = 0.1f;
            
			float minX = -6.0f;
			float maxX = 0.0f;
			float minY = 4.0f;
			float maxY = 6.0f;
            
			for (int32 i = 0; i < 100; ++i)
			{
				b2BodyDef bd;
				bd.type = b2_dynamicBody;
				bd.position = b2Vec2(RandomFloat(minX,maxX),RandomFloat(minY,maxY));
				b2Body* body = m_world->CreateBody(&bd);
				body->CreateFixture(&shape, 0.01f);
			}
		}
        
		{
			b2PolygonShape shape;
			shape.SetAsBox(10.5f, 10.5f);
			b2BodyDef bd;
			bd.type = b2_dynamicBody;
			bd.position.Set(-40.0f,5.0f);
			bd.bullet = true;
			b2Body* body = m_world->CreateBody(&bd);
			body->CreateFixture(&shape, 1.0f);
			body->SetLinearVelocity(b2Vec2(150.0f, 0.0f));

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