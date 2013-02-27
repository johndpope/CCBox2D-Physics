#import "CCApplyForce.h"
#import "CCBodySprite.h"
#import "CCJointSprite.h"
#import "CCSpringSprite.h"
#import "ATSpring.h"
#import "ATParticle.h"
#import "ATKernel.h"
#import "ATSystemRenderer.h"
#import "ATPhysics.h"

@implementation CCApplyForce{
    
};

-(id) init
{

    self = [super init];
    
    if  (self!=nil){

        appDelegate = (Box2DAppDelegate*) [[UIApplication sharedApplication] delegate];
        
        [self loadMapData];
        [self createNodes];
        [self createJoints];
        m_world->SetGravity(b2Vec2(0.0f, 0.0f));
   

        return self;
        
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

-(void) update:(ccTime)delta
{
    [super update:delta];
    for (ATParticle *particle in appDelegate.system.physics.particles) {
        [particle update:delta];
    }
    
    
	
}
-(void)generateChildrenByParent:(ATParticle*)parentParticle{
    
    //TODO make this cleaner
    
    float n = RandomFloat(10.0,150000000.0);
    NSString *name = [NSString stringWithFormat:@"rnd%f",n];
    CGPoint pt = CGPointRandom(5.0);;
    
    ATParticle *node = [[ATParticle alloc] initWithWorld:m_world size:1 position:pt angle:0.35  name:name userData:nil];

    [appDelegate.system.state setNamesObject:node forKey:name];
    [appDelegate.system.state setNodesObject:node forKey:node.index];
    [appDelegate.system addParticle:node];
    

    [node setTexture:[[CCTextureCache sharedTextureCache] addImage: @"Icon.png"]];
    //CCBodySprite *particle = [[CCBodySprite spriteWithFile:@"Icon.png"]retain];
    node.color = ccMAGENTA;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.awake = YES;
    bodyDef.allowSleep = YES;
    [node configureSpriteForWorld:m_world bodyDef:bodyDef];
   // particle.position = pt;
    [self addChild:node]; //add the particle image into canvas
    
    float radius = RandomFloat(10.0,150.0);
    CCShape *circle = [CCShape circleWithCenter:ccp(5,5) radius:radius];
    circle.restitution = 0.0f;
    [node addShape:circle named:@"circle"];
    float scale =1.0f/15;
    [node setScale:scale];
    
    [appDelegate.system addEdgeFromNode:[parentParticle name] toNode:name withData:nil withWorld:m_world];
    @try {
           [self createJoints];
    }
    @catch (NSException *exception) {
        NSLog(@"e:%@",exception);
    }

 
}

-(void)generateNodesWithParent:(CCBodySprite*)parentSprite{
    b2PolygonShape shape;
    //shape.SetAsBox(2, 2);
    
    b2FixtureDef fd;
    fd.shape = &shape;
    fd.density = 1.0f;
    fd.friction = 0.3f;
    
    BG_WEAKSELF;
    
    
    float minX = 2.0f;
    float maxX = 8.0f;
    float t = RandomFloat(minX,maxX);
    
    
    for (int i = 0; i < t; ++i)
    {
        CGPoint pt;
        if (parentSprite.tag ==111) {
         pt  = ccp(parentSprite.position.x,parentSprite.position.y+i);
        }else{
          pt  = ccp(parentSprite.position.x*PTM_RATIO,parentSprite.position.y*PTM_RATIO+i);
        }
         
        NSLog(@"pt.x:%f",pt.x);
        NSLog(@"pt.y:%f",pt.y);
        
        CCBodySprite *particle = [[CCBodySprite spriteWithFile:@"Icon.png"]retain];
        particle.color = ccMAGENTA;
        
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.awake = YES;
        bodyDef.allowSleep = YES;
        [particle configureSpriteForWorld:m_world bodyDef:bodyDef];
        particle.position = pt;
        [self addChild:particle]; //add the particle image into canvas
        
         float radius = RandomFloat(10.0,150.0);
        CCShape *circle = [CCShape circleWithCenter:ccp(5,5) radius:radius];
        circle.restitution = 0.0f;
        [particle addShape:circle named:@"circle"];
        float scale =1.0f/15;
        [particle setScale:scale];

        particle.onTouchDownBlock = ^{
            NSLog(@"onTouchDownBlock");

            [weakSelf generateNodesWithParent:particle];
            //circle
            
        };
        
        
        float32 gravity = 10.0f;
        float32 I = [particle inertia];
        float32 mass = [particle mass];
        
        // For a circle: I = 0.5 * m * r * r ==> r = sqrt(2 * I / m)
        radius = b2Sqrt(2.0f * I / mass);
        
        //b2FrictionJointDef jd;
        b2FrictionJointDef jd;
        jd.localAnchorA.SetZero();
        jd.localAnchorB.SetZero();
        jd.bodyA = parentSprite.body;
        jd.bodyB = particle.body;
        jd.collideConnected = true;
        jd.maxForce = mass * gravity;
        jd.maxTorque = mass * radius * gravity;
        m_world->CreateJoint(&jd);
        
        
        
    }
}




-(void) loadMapData
{
    // Find the file
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"usofa" ofType:@"json"];
    if (filePath) {
        // Load data in the file
        NSData *theJSONData = [NSData dataWithContentsOfFile:filePath];
        if (theJSONData) {
            // Parse the file
            NSError *theError = nil;
            NSDictionary *theObject = [NSJSONSerialization JSONObjectWithData:theJSONData options:NSJSONReadingAllowFragments                                error:&theError];
            
            if (theObject) {
                
                NSMutableDictionary *edges = [NSMutableDictionary dictionaryWithDictionary:[theObject objectForKey:@"edges"]];
                
                NSLog(@"edges:%@",edges);
                
                for (id o in edges) {
                    
                }
                [edges enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    
                    NSString *source = key;
                    NSDictionary *targets = obj;
                    
                    // How about an extra measure of concurrency within the concurrency.
                    NSLog(@"source:%@",source);
                    NSLog(@"targets:%@",targets);
                    
                    NSMutableDictionary *userDataDict = [targets objectForKey:@"userData"];
                    
                    [targets enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

                        if (![key isEqualToString:@"userData"]) {
                            NSLog(@"Source %@ -> %@", source, key);
                            // Create the edge, and by proxy, create the nodes
                            [appDelegate.system addEdgeFromNode:[source copy] toNode:[key copy] withData:userDataDict withWorld:m_world];
                            
                        }
                        
                        
                    }];
                    
                }];
                
            } else {
                NSLog(@"Could not parse JSON file.");
            }
        } else {
            NSLog(@"Could not load NSData from file.");
        }
    } else {
        NSLog(@"Please include america.json in the project resources.");
    }
}


-(void)createNodes{
    
    for (ATParticle *particle in appDelegate.system.physics.particles) {
        
        CGPoint pt = CGPointRandom(5.0);;
        //create a random point to display

        [particle update:nil];
        
        BG_WEAKSELF;
        
        [particle setTexture:[[CCTextureCache sharedTextureCache] addImage: @"Icon.png"]];
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.awake = YES;
        bodyDef.allowSleep = YES;
        [particle configureSpriteForWorld:m_world bodyDef:bodyDef];
        particle.position = pt;
        [self addChild:particle]; //add the particle image into canvas
        particle.onTouchDownBlock = ^{
            NSLog(@"onTouchDownBlock");
            
            [weakSelf generateChildrenByParent:particle];
            //circle
            
        };
        
        float radius = 50;
        CCShape *circle = [CCShape circleWithCenter:ccp(5,5) radius:radius];
        circle.restitution = 0.0f;
        [particle addShape:circle named:@"circle"];
        float scale =1.0f/15;
        [particle setScale:scale];

    }
    
   
    
}

-(void)createJoints{
    for (ATSpring *spring in appDelegate.system.physics.springs) {
        
        // Connect the joints
        b2DistanceJointDef jointDef;

        NSLog(@"spring.point1.name:%@",spring.point1.name);
        NSLog(@"spring.point2.name:%@",spring.point2.name);
        // NSLog(@"sspring.point1.innerCircleBody:%@",spring.point1.innerCircleBody);
        
        // spring.point1.position = ccp(i, i);
        // Get current body and neighbor
        b2Body *currentBody = (b2Body*)spring.point1.innerCircleBody;
        b2Body *neighborBody = (b2Body*)spring.point2.innerCircleBody;
        
        // Connect the outer circles to each other
        jointDef.Initialize(currentBody, neighborBody,
                            currentBody->GetWorldCenter(),
                            neighborBody->GetWorldCenter() );
        // Specifies whether the two connected bodies should collide with each other
        jointDef.collideConnected = false;
        jointDef.frequencyHz = 1.0;
        jointDef.length = 15;
        jointDef.dampingRatio = 0.0;
        
        m_world->CreateJoint(&jointDef);
        
    }
}

@end