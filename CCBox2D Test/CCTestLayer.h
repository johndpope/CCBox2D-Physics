#import "CCWorldLayer.h"
#import "cocos2d.h"
#import <UIKit/UIKit.h>
#include <Box2D/Box2D.h>
#include "GLES-Render.h"
#import "CCBox2DPrivate.h"
#include <cstdlib>
#import "Box2DAppDelegate.h"

@class CCBodySprite;



/// Test settings. Some can be controlled in the GUI.
/// Test settings. Some can be controlled in the GUI.
struct Settings
{
	Settings() :
	viewCenter(0.0f, 20.0f),
	hz(60.0f),
	velocityIterations(8),
	positionIterations(3),
	drawShapes(1),
	drawJoints(1),
	drawAABBs(0),
	drawPairs(0),
	drawContactPoints(0),
	drawContactNormals(0),
	drawContactForces(0),
	drawFrictionForces(0),
	drawCOMs(0),
	drawStats(0),
	drawProfile(0),
	enableWarmStarting(1),
	enableContinuous(1),
	enableSubStepping(0),
	pause(0),
	singleStep(0)
	{}
    
	b2Vec2 viewCenter;
	float32 hz;
	int32 velocityIterations;
	int32 positionIterations;
	int32 drawShapes;
	int32 drawJoints;
	int32 drawAABBs;
	int32 drawPairs;
	int32 drawContactPoints;
	int32 drawContactNormals;
	int32 drawContactForces;
	int32 drawFrictionForces;
	int32 drawCOMs;
	int32 drawStats;
	int32 drawProfile;
	int32 enableWarmStarting;
	int32 enableContinuous;
	int32 enableSubStepping;
	int32 pause;
	int32 singleStep;
};

const int32 k_maxContactPoints = 2048;

struct ContactPoint
{
	b2Fixture* fixtureA;
	b2Fixture* fixtureB;
	b2Vec2 normal;
	b2Vec2 position;
	b2PointState state;
};


#define	RAND_LIMIT	32767

/// Random number in range [-1,1]
inline float32 RandomFloat()
{
	float32 r = (float32)(rand() & (RAND_LIMIT));
	r /= RAND_LIMIT;
	r = 2.0f * r - 1.0f;
	return r;
}

/// Random floating point number in range [lo, hi]
inline float32 RandomFloat(float32 lo, float32 hi)
{
	float32 r = (float32)(rand() & (RAND_LIMIT));
	r /= RAND_LIMIT;
	r = (hi - lo) * r + lo;
	return r;
}


@interface CCTestLayer : CCLayer <ContactListenizer>
{
    Box2DAppDelegate *appDelegate;
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
@property(nonatomic,assign)     BOOL isDebugDrawing;
-(void) createBounds;
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


class TestQueryCallback : public b2QueryCallback
{
public:
    TestQueryCallback(const b2Vec2& point)
    {
        m_point = point;
        m_fixture = NULL;
    }
    
    bool ReportFixture(b2Fixture* fixture)
    {
        b2Body* body = fixture->GetBody();
        if (body->GetType() == b2_dynamicBody)
        {
            bool inside = fixture->TestPoint(m_point);
            if (inside)
            {
                m_fixture = fixture;
                
                // We are done, terminate the query.
                return false;
            }
        }
        
        // Continue the query.
        return true;
    }
    
    b2Vec2 m_point;
    b2Fixture* m_fixture;
};

