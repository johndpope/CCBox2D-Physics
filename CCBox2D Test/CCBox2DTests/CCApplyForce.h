#import "CCTestLayer.h"
#import "Box2DAppDelegate.h"

@interface CCApplyForce : CCTestLayer
{
    Box2DAppDelegate *appDelegate;
	b2Body* m_body;
    CCBodySprite *ground;


};

@end
