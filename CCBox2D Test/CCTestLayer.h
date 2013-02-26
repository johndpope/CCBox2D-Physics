#import "CCWorldLayer.h"
#import "cocos2d.h"
#import <UIKit/UIKit.h>
#include <Box2D/Box2D.h>
#include "GLES-Render.h"
#import "CCBox2DPrivate.h"
#include <cstdlib>
#import "iPhoneTest.h"

@class CCBodySprite;



@interface CCTestLayer : CCLayer <ContactListenizer>
{

    b2World* m_world;	// cocos2d specific
    Settings* settings;
    
    b2Body* m_groundBody;
    ContactPoint m_points[k_maxContactPoints];
    int32 m_pointCount;
    GLESDebugDraw m_debugDraw;
    int32 m_textLine;
    b2MouseJoint* m_mouseJoint;
    b2Vec2 m_mouseWorld;
    int32 m_stepCount;
    
    BOOL isZooming;
    
    
}

-(CCBodySprite*) createGround:(CGSize)size;
// size of box around the point used for hit testing in -bodyAtPoint:queryTest:; defaults to 16x16 points
// smallest value supported is 2x2
/*@property (nonatomic) CGSize hitTestSize;
@property (nonatomic) CGPoint gravity;
@property (nonatomic) int positionIterations;
@property (nonatomic) int velocityIterations;
@property (nonatomic) BOOL debugDrawing;

@property (nonatomic, readonly) BOOL locked;

// queryTest should return YES to continue searching
//- (CCBodySprite *)bodyAtPoint:(CGPoint)point queryTest:(QueryTest)queryTest;

+ (void)setPixelsToMetresRatio:(CGFloat)ratio;
+ (CGFloat)pixelsToMetresRatio;*/

@end
