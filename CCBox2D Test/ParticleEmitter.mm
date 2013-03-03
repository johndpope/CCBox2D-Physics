#import "ParticleEmitter.h"
#import "CGPointExtension.h"
#import "Box2D.h"
#import "ccMacros.h"
#define PTM_RATIO 32

@implementation ParticleEmitter
@synthesize bodyPos;
 
-(id) init
{
	self 			= [super init];
	_positionType	= (tCCPositionType)kPositionTypeGrouped;
	bodyToFollow	= nil;
	bodyPos		= ccp(0,0);
	return self;
}
 
-(void) setBodyToFollow:(b2Body*)newBody
{
	bodyToFollow	= newBody;
	bodyPos		= ccp(bodyToFollow->GetPosition().x*PTM_RATIO,bodyToFollow->GetPosition().y*PTM_RATIO);
}
-(void) initParticle: (tCCParticle*) particle
{
	[super initParticle:particle];
	particle->startPos 	= bodyPos;
	particle->pos 		= bodyPos;
}

-(void) update: (ccTime) dt
{
	if( bodyToFollow != nil )
	{
		bodyPos		= ccp(bodyToFollow->GetPosition().x*PTM_RATIO, bodyToFollow->GetPosition().y*PTM_RATIO);
	}
	[super update:dt];
}

-(void) updateQuadWithParticle:(tCCParticle*)p newPosition:(CGPoint)newPos
{
	if( bodyToFollow != nil )
	{
		newPos = ccpAdd(newPos, p->startPos);
	}
	[super updateQuadWithParticle:p newPosition:newPos];
}

@end