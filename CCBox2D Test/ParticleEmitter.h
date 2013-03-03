#import <Foundation/Foundation.h>
#import "CCParticleSystemQuad.h"
#import "Box2D.h"

//class b2Body; // forward declaration of b2Body without '@' since it is a c++ class
 
@interface ParticleEmitter : CCParticleSystemQuad
{
	b2Body* bodyToFollow;
	CGPoint bodyPos;
}
 
-(void) setBodyToFollow:(b2Body*)newBody;
 
@property (nonatomic,assign) CGPoint bodyPos;
 
@end