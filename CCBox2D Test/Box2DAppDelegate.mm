#import <UIKit/UIKit.h>
#import "Box2DAppDelegate.h"
//#import "Box2DView.h"
#import "cocos2d.h"
#import "CCBox2DView.h"
#import "CCWorldLayer.h"
#import "CCTestLayer.h"
#import "CCAddPair.h"
#import "CCApplyForce.h"

@implementation Box2DAppDelegate

enum {
	kTagBox2DNode,
};

@synthesize system;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

    [application setStatusBarHidden:true];

    
    
    
    // Create our particle system
    self.system = [[ATSystem alloc] init];
    
    // Configure simulation parameters, (take a copy, modify it, update the system when done.)
    ATSystemParams *params = self.system.parameters;
   // http://arborjs.org/reference
    /* params.gravity = NO;
     params.repulsion = 1,000;
     params.stiffness = 600;
     params.friction  = 0.5;
     params.precision = 0.6;*/ //accuracy vs. speed in force calculations
                             //(zero is fast but jittery, one is smooth but cpu-intensive)
    
    self.system.parameters = params;
    
    // Setup the view bounds
    //self.system.viewBounds = CGRectMake(0, 0, 768*PTM_RATIO, 1024*PTM_RATIO);
    //self.system.viewBounds = CGRectMake(0, 0, 100, 100);
    
    // leave some space at the bottom and top for text
    //self.system.viewPadding = UIEdgeInsetsMake(60.0, 60.0, 60.0, 60.0);
    
    // have the ‘camera’ zoom somewhat slowly as the graph unfolds
    self.system.viewTweenStep = 0.2;
    
    // set this controller as the system's delegate
    self.system.delegate = self;
    
    
    
	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	//if( ! [director_ enableRetinaDisplay:NO] )
		CCLOG(@"Retina Display Not supported");

	CCScene *scene = [CCScene node];
    CGSize s = [[CCDirector sharedDirector] winSize];

    CCApplyForce *view =[[CCApplyForce alloc]init];
    [view setScale:1];
    [view setAnchorPoint:ccp(0,0)];
    [view setPosition:ccp(s.width/2, s.height/2)];
    [scene addChild:view z:0 tag:kTagBox2DNode];

	[director_ pushScene: scene];

    // start the simulation
    [self.system start:YES];
    
	return YES;
}



@end
