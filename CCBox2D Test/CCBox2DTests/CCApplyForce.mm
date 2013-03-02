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

        m_world->SetGravity(b2Vec2(0.0f, 0.0f));
        
        [self loadMapData];
        [self createNodes]; //- not needed
        [self createJoints];
        [self createCartesianBounds]; // 0,0 in center

        [self createTestBody];
        

    }
    return self;
}
-(void)dealloc{
    [ground release];
    [centerBody release];
    [super dealloc];
}

-(void)createTestBody{


    centerBody = [[ATParticle spriteWithFile:@"Icon.png"]retain];
    centerBody.tag = 111;
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    [centerBody configureSpriteForWorld:m_world bodyDef:bodyDef];
    centerBody.position = ccp(-130,-130);
    [self addChild:centerBody z:-100];
    [self generateNodesWithParent:centerBody];

}

-(void) update:(ccTime)delta
{
    [super update:delta];
    for (ATParticle *particle in appDelegate.system.physics.particles) {
        [particle update:delta];
        
        [self attractNode:particle target:centerBody];
    }
}
-(void)attractNode:(ATParticle*)p1 target:(ATParticle*)p2{
    CGPoint pt = [p1 attraction:p2];
    [p1 applyForce:pt];
    
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
 
    [self addChild:node]; //add the particle image into canvas
    
    float radius = RandomFloat(10.0,15.0);
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
         pt  = ccp(parentSprite.physicsPosition.x,parentSprite.physicsPosition.y+i);
        }else{
          pt  = ccp(parentSprite.physicsPosition.x*PTM_RATIO,parentSprite.physicsPosition.y*PTM_RATIO+i);
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
        particle.physicsPosition = pt;
        [self addChild:particle]; //add the particle image into canvas
        
         float radius = RandomFloat(1.0,15.0);
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
        
        
        float32 gravity = 0.0f;
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

        BG_WEAKSELF;
        [particle setTexture:[[CCTextureCache sharedTextureCache] addImage: @"Kirby.png"]];
        particle.onTouchDownBlock = ^{
            NSLog(@"onTouchDownBlock");
            [weakSelf generateChildrenByParent:particle];
        };
        [self addChild:particle];//add the particle image into canvas

    }
    
   
    
}

-(void)createJoints{
    for (ATSpring *spring in appDelegate.system.physics.springs) {
        
        // Connect the joints
        b2PrismaticJointDef jd;

        b2Body *currentBody = (b2Body*)spring.point1.body;
        b2Body *neighborBody = (b2Body*)spring.point2.body;
        
        // Connect the outer circles to each other
        jd.Initialize(currentBody, neighborBody,
                            currentBody->GetWorldCenter(),
                            neighborBody->GetWorldCenter() );
        // Specifies whether the two connected bodies should collide with each other
        jd.collideConnected = true;
        //jointDef.frequencyHz = 60.0;
        //jointDef.length = 250;
        //jointDef.dampingRatio = 0.0;
        b2Vec2 axis(2.0f, 1.0f);
        axis.Normalize();
        jd.motorSpeed = 0.0f;
        jd.maxMotorForce = 100.0f;
       // jd.enableMotor = true;
        jd.lowerTranslation = -4.0f;
        jd.upperTranslation = 4.0f;
        jd.enableLimit = false;
        
        m_world->CreateJoint(&jd);
        
    }
}

@end