#import "CCApplyForce.h"
#import "CCBodySprite.h"
#import "CCJointSprite.h"
#import "CCSpringSprite.h"
#import "ATSpring.h"
#import "ATParticle.h"
#import "ATKernel.h"
#import "ATSystemRenderer.h"
#import "ATPhysics.h"
#import "b2FrictionJoint.h"


@implementation CCApplyForce{
    
};

-(id) init
{
    self = [super init];
    if  (self!=nil){

        m_world->SetGravity(b2Vec2(0.0f, 0.0f));
        
        [self createCartesianBounds]; // 0,0 in center
        [self createTestBody];
        NSArray *arr = [NSArray arrayWithObjects:@"bk42w74", @"bk43w73", @"bk70bk62", @"bk95bk3", @"g81w58", @"g83w57", @"pk60gr7", @"r15bl29", @"r17pu46", nil];
        float rnd = RandomFloat(0, [arr count]);
  
        [self loadMapDataForFileName:[arr objectAtIndex:rnd]];
        [self performSelector:@selector(createJoints) withObject:nil afterDelay:3];
       


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


}

-(void) update:(ccTime)delta
{
    [super update:delta];
    for (ATParticle *particle in appDelegate.system.physics.particles) {
        [particle update:delta];
        
      //  [self attractNodeToOrigin:particle];
    }
   
   
  
    
    
}
-(void)attractNodeToOrigin:(ATParticle*)p1{

    
    b2Body *body1 = p1.body;
    b2Body *body2 = centerBody.body;
    b2Vec2 position = body1->GetWorldCenter();
    NSLog(@"(%f, %f)",position.x,position.y);
    
    b2Vec2 position1 = body2->GetWorldCenter();
   // NSLog(@"(%f, %f)",position1.x,position1.y);
    
    b2Vec2 direction = body1->GetWorldCenter() - body2->GetWorldCenter();
    direction.Normalize();

    float magnitude = 1;
    body1->ApplyForce( -magnitude * direction, body1->GetWorldCenter() ); //flip to cause repulsion
    body2->ApplyForce( magnitude * direction, body2->GetWorldCenter() );//flip to cause repulsion
    
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
        b2DistanceJointDef jd;
        jd.length = 250;
        jd.frequencyHz = 60;
        jd.dampingRatio = 1;
       // jd.localAnchorA.SetZero();
       // jd.localAnchorB.SetZero();
        jd.bodyA = parentSprite.body;
        jd.bodyB = particle.body;
        jd.collideConnected = true;
        //jd.maxForce = mass * gravity;
        //jd.maxTorque = mass * radius * gravity;
        m_world->CreateJoint(&jd);
        
        
        
    }
}




-(void) loadMapDataForFileName:(NSString*)filename
{
    // Find the file
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
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
        ATParticle *currentBody = spring.point1;
        ATParticle *neighborBody = spring.point2;
        
        float32 gravity = 10.0f;
        float32 radius = 30;
        float32 I = [currentBody inertia];
        float32 mass = [currentBody mass];
        
        
        b2RopeJointDef jd;
         jd.localAnchorA.SetZero();
         jd.localAnchorB.SetZero();
         jd.bodyA = currentBody.body;
         jd.bodyB = neighborBody.body;
         jd.collideConnected = true;
        jd.maxLength = 200;
        // jd.maxForce = mass * gravity;
        // jd.maxTorque = mass * radius * gravity;
         m_world->CreateJoint(&jd);
        
        /*b2DistanceJointDef jd;
        jd.localAnchorA.SetZero();
        jd.localAnchorB.SetZero();
        jd.bodyA = currentBody.body;
        jd.bodyB = neighborBody.body;
        jd.collideConnected = true;
        //jd.maxForce = mass * gravity;
        //jd.maxTorque = mass * radius * gravity;
        
        // d = p2 - p1;
        jd.length = 250;//d.Length();
        jd.frequencyHz = 2.0f;
        jd.dampingRatio = 0.0f;
        
        m_world->CreateJoint(&jd);*/
        
       /*b2DistanceJointDef jd;
        jd.localAnchorA.SetZero();
        jd.localAnchorB.SetZero();
        jd.bodyA = currentBody.body;
        jd.bodyB = neighborBody.body;
        jd.collideConnected = true;
        //jd.maxForce = mass * gravity;
        //jd.maxTorque = mass * radius * gravity;
        
       // d = p2 - p1;
        jd.length = 250;//d.Length();
        jd.frequencyHz = 2.0f;
        jd.dampingRatio = 0.0f;
        
        m_world->CreateJoint(&jd);*/
        
        
        /*b2PrismaticJointDef jd;
        jd.localAnchorA.SetZero();
        jd.localAnchorB.SetZero();
        jd.bodyA = currentBody.body;
        jd.bodyB = neighborBody.body;
        jd.collideConnected = true;
        jd.upperTranslation = 80;
        jd.lowerTranslation = 60;*/
        

        // Distance joint
        /*float dampingRatio = 0.0;
        float frequencyHz = 0;
        // Rope joint
        float kMaxWidth = 150.1;
        // Bodies
        int countBodyInChain = 15;
        b2Body *body = currentBody.body;
        b2Body* prevBody = neighborBody.body;
        
        //Create distance joint
        b2DistanceJointDef distJDef;
        b2Vec2 anchor1 = prevBody->GetWorldCenter();
        b2Vec2 anchor2 = body->GetWorldCenter();
        distJDef.Initialize(prevBody, body, anchor1, anchor2);
        distJDef.collideConnected = false;
        distJDef.dampingRatio = dampingRatio;
        distJDef.frequencyHz = frequencyHz;
        m_world->CreateJoint(&distJDef);*/
        
        //Create rope joint
       /* b2RopeJointDef rDef;
        rDef.maxLength = (body->GetPosition() - prevBody->GetPosition()).Length() * kMaxWidth;
        rDef.localAnchorA = rDef.localAnchorB = b2Vec2_zero;
        rDef.bodyA = prevBody;
        rDef.bodyB = body;
        m_world->CreateJoint(&rDef);*/
        
        
    }
}

@end