#import <UIKit/UIKit.h>
#import "Box2DAppDelegate.h"
#import "Box2DView.h"
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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

    [application setStatusBarHidden:true];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director_ setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	//if( ! [director_ enableRetinaDisplay:NO] )
		CCLOG(@"Retina Display Not supported");

	CCScene *scene = [CCScene node];
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    // switch this to run normal box2d demos
    if (0){
        [scene addChild: [MenuLayer menuWithEntryID:0]];
    }
    if (1) {
        
        CCApplyForce *view =[[CCApplyForce alloc]init];
        [view setScale:1];
		[view setAnchorPoint:ccp(0,0)];
        [scene addChild:view z:0 tag:kTagBox2DNode];
        
    }
   
	
  
	[director_ pushScene: scene];

	return YES;
}
@end
