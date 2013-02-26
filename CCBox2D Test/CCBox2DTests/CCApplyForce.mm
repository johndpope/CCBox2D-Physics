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

        m_world->SetGravity(b2Vec2(0.0f, 0.0f));
   
        
        // Define the ground box shape.
        CGSize screenSize = [CCDirector sharedDirector].winSize;
		CGPoint screenCenter = CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
        
        //float scale = 1.0f/15;
        ground = [self createGround:screenSize];
        ground.anchorPoint = screenCenter;
     
        
        CCBodySprite *centerBody = [[CCBodySprite spriteWithFile:@"Icon.png"]retain];
        centerBody.tag = 111;
        b2BodyDef bodyDef;
        bodyDef.type = b2_staticBody;
        [centerBody configureSpriteForWorld:m_world bodyDef:bodyDef];
        centerBody.position = ccp(500,500);
        [self addChild:centerBody z:-100];
        
		{
            [self generateNodesWithParent:centerBody];
		}

        

    }
    return self;
}
-(void)dealloc{
    [ground release];
    [super dealloc];
}
-(void)generateNodesWithParent:(CCBodySprite*)parentSprite{
    b2PolygonShape shape;
    //shape.SetAsBox(2, 2);
    
    b2FixtureDef fd;
    fd.shape = &shape;
    fd.density = 1.0f;
    fd.friction = 0.3f;
    
    BG_WEAKSELF;
    
    for (int i = 0; i < 5; ++i)
    {
        CGPoint pt;
        if (parentSprite.tag ==111) {
         pt  = ccp(parentSprite.position.x,parentSprite.position.y+i);
        }else{
          pt  = ccp(parentSprite.position.x*PTM_RATIO,parentSprite.position.y*PTM_RATIO+i);
        }
         
        NSLog(@"pt.x:%f",pt.x);
        NSLog(@"pt.y:%f",pt.y);
        
        CCBodySprite *kirby = [[CCBodySprite spriteWithFile:@"Icon.png"]retain];
        kirby.color = ccMAGENTA;
        
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.awake = YES;
        bodyDef.allowSleep = YES;
        [kirby configureSpriteForWorld:m_world bodyDef:bodyDef];
        kirby.position = pt;
        [self addChild:kirby]; //add the kirby image into canvas
        
        
        float radius = 150;
        CCShape *circle = [CCShape circleWithCenter:ccp(5,5) radius:radius];
        circle.restitution = 0.0f;
        [kirby addShape:circle named:@"circle"];
        float scale =1.0f/15;
        [kirby setScale:scale];

        kirby.onTouchDownBlock = ^{
            NSLog(@"onTouchDownBlock");

            [weakSelf generateNodesWithParent:kirby];
            //circle
            
        };
        
        
        float32 gravity = 10.0f;
        float32 I = [kirby inertia];
        float32 mass = [kirby mass];
        
        // For a circle: I = 0.5 * m * r * r ==> r = sqrt(2 * I / m)
        radius = b2Sqrt(2.0f * I / mass);
        
        //b2FrictionJointDef jd;
        b2FrictionJointDef jd;
        jd.localAnchorA.SetZero();
        jd.localAnchorB.SetZero();
        jd.bodyA = parentSprite.body;
        jd.bodyB = kirby.body;
        jd.collideConnected = true;
        jd.maxForce = mass * gravity;
        jd.maxTorque = mass * radius * gravity;
        m_world->CreateJoint(&jd);
        
        
        
    }
}



@end