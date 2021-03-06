//
//  ATPhysics.m
//  PSArborTouch
//
//  Created by Ed Preston on 19/09/11.
//  Copyright 2011 Preston Software. All rights reserved.
//

#import "ATPhysics.h"
#import "ATBarnesHutTree.h"
#import "ATSpring.h"
#import "ATParticle.h"
#import "ATGeometry.h"

#import "ATEnergy.h"


@interface ATPhysics ()

- (void) tendParticles;
- (void) eulerIntegrator:(CGFloat)deltaTime;
- (void) applyBruteForceRepulsion;
- (void) applyBarnesHutRepulsion;
- (void) applySprings;
- (void) applyCenterDrift;
- (void) applyCenterGravity;
- (void) updateVelocity:(CGFloat)timestep;
- (void) updatePosition:(CGFloat)timestep;

@end


@implementation ATPhysics

@synthesize particles   = particles_;
@synthesize springs     = springs_;
@synthesize energy      = energy_;
@synthesize bounds      = bounds_;
@synthesize speedLimit  = speedLimit_;
@synthesize deltaTime   = deltaTime_;
@synthesize stiffness   = stiffness_;
@synthesize repulsion   = repulsion_;
@synthesize friction    = friction_;
@synthesize gravity     = gravity_;
@synthesize theta       = theta_;
@synthesize bhTree      = bhTree_;

- (id) init
{
    self = [super init];
    if (self) {
        activeParticles_ = [[NSMutableArray arrayWithCapacity:32] retain];
        activeSprings_  = [[NSMutableArray arrayWithCapacity:32] retain];
        freeParticles_  = [[NSMutableArray arrayWithCapacity:32] retain];
        particles_      = [[NSMutableArray arrayWithCapacity:32] retain];
        springs_        = [[NSMutableArray arrayWithCapacity:32] retain];
        energy_         = [[ATEnergy alloc] init];
        bounds_         = CGRectMake(-1.0, -1.0, 2.0, 2.0);
        speedLimit_     = 100000;
        deltaTime_      = 1;
        stiffness_      = 1000;
        repulsion_      = 600;
        friction_       = 0.3;
        gravity_        = NO;
        theta_          = 0.4;
        bhTree_         = [[ATBarnesHutTree alloc] init] ;
    }
    return self;
}

- (id) initWithDeltaTime:(CGFloat)deltaTime 
               stiffness:(CGFloat)stiffness 
               repulsion:(CGFloat)repulsion 
                friction:(CGFloat)friction 
{
    self = [self init];
    if (self) {
        deltaTime_  = deltaTime;
        stiffness_  = stiffness;
        repulsion_  = repulsion;
        friction_   = friction;
    }
    return self;
}

- (void) dealloc
{
    [bhTree_ release];
    [activeParticles_ release];
    [activeSprings_ release];
    [freeParticles_ release];
    [particles_ release];
    [springs_ release];
    [energy_ release];
    
    [super dealloc];
}


- (void) addParticle:(ATParticle *)particle
{
    NSParameterAssert(particle != nil);
    
    if (particle == nil) return;
    
    particle.connections = 0.0;
    [activeParticles_ addObject:particle];
    [freeParticles_ addObject:particle];
    [particles_ addObject:particle];
}

- (void) removeParticle:(ATParticle *)particle
{
    NSParameterAssert(particle != nil);
    
    if (particle == nil) return;
    
    [particles_ removeObjectIdenticalTo:particle];
    [activeParticles_ removeObjectIdenticalTo:particle];
    [freeParticles_ removeObjectIdenticalTo:particle];
}

- (void) addSpring:(ATSpring *)spring
{
    NSParameterAssert(spring != nil);

    if (spring == nil) return;
    
    [activeSprings_ addObject:spring];
    [springs_ addObject:spring];

    spring.point1.connections++;
    spring.point2.connections++;

    [freeParticles_ removeObjectIdenticalTo:spring.point1];
    [freeParticles_ removeObjectIdenticalTo:spring.point2];
}

- (void) removeSpring:(ATSpring *)spring
{
    NSParameterAssert(spring != nil);
    
    if (spring == nil) return;
    
    spring.point1.connections--;
    spring.point2.connections--;
    
    [springs_ removeObjectIdenticalTo:spring];
    [activeSprings_ removeObjectIdenticalTo:spring];
}


#pragma mark - Physics Stuff

- (BOOL) update; 
{
   // [self tendParticles];
    [self eulerIntegrator:deltaTime_];
    
//    CGFloat motion = (self.energy.mean + self.energy.max) / 2; 
    CGFloat motion = (self.energy.max - self.energy.mean) / 2;
    
    if (motion < 0.05) { // 0.05
        NSLog(@"We would stop now.");
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - Internal Interface


//this causes problems
- (void) tendParticles
{
    // Barnes-Hut requires accurate bounds.  If a particle has been modified from one
    // run to the next, detect it here to ensure the bounds are correct.
    
    CGPoint bottomright = CGPointZero;
    CGPoint topleft     = CGPointZero;

    BOOL firstParticle  = YES;
    BOOL didFindMovingParticle = NO;
    
    
    for (ATParticle *particle in activeParticles_) {

        // decay down any of the temporary mass increases that were passed along
        // by using an {_m:} instead of an {m:} (which is to say via a Node having
        // its .tempMass attr set)
        
        if (particle.tempMass != 0.0) {
            if (ABS(particle.mass - particle.tempMass) < 1.0) {
                particle.mass = particle.tempMass;
                particle.tempMass = 0.0;
            } else {
                particle.mass *= 0.98;
            }
        }
        
        // zero out the velocity from one tick to the next
        particle.velocity = CGPointZero;
    }   
}

-(BOOL)updateBounds{
    /*
     if (_screenSize===null) return
     
     if (newBounds) _boundsTarget = newBounds
     else _boundsTarget = that.bounds()
     
     // _boundsTarget = newBounds || that.bounds()
     // _boundsTarget.topleft = new Point(_boundsTarget.topleft.x,_boundsTarget.topleft.y)
     // _boundsTarget.bottomright = new Point(_boundsTarget.bottomright.x,_boundsTarget.bottomright.y)
     
     var bottomright = new Point(_boundsTarget.bottomright.x, _boundsTarget.bottomright.y)
     var topleft = new Point(_boundsTarget.topleft.x, _boundsTarget.topleft.y)
     var dims = bottomright.subtract(topleft)
     var center = topleft.add(dims.divide(2))
     
     
     var MINSIZE = 4                                   // perfect-fit scaling
     // MINSIZE = Math.max(Math.max(MINSIZE,dims.y), dims.x) // proportional scaling
     
     var size = new Point(Math.max(dims.x,MINSIZE), Math.max(dims.y,MINSIZE))
     _boundsTarget.topleft = center.subtract(size.divide(2))
     _boundsTarget.bottomright = center.add(size.divide(2))
     
     if (!_bounds){
     if ($.isEmptyObject(state.nodes)) return false
     _bounds = _boundsTarget
     return true
     }
     
     // var stepSize = (Math.max(dims.x,dims.y)<MINSIZE) ? .2 : _screenStep
     var stepSize = _screenStep
     _newBounds = {
     bottomright: _bounds.bottomright.add( _boundsTarget.bottomright.subtract(_bounds.bottomright).multiply(stepSize) ),
     topleft: _bounds.topleft.add( _boundsTarget.topleft.subtract(_bounds.topleft).multiply(stepSize) )
     }
     
     // return true if we're still approaching the target, false if we're ‘close enough’
     var diff = new Point(_bounds.topleft.subtract(_newBounds.topleft).magnitude(), _bounds.bottomright.subtract(_newBounds.bottomright).magnitude())
     if (diff.x*_screenSize.width>1 || diff.y*_screenSize.height>1){
     _bounds = _newBounds
     return true
     }else{
     return false
     }
     */
    // update the bounds
    /* CGPoint pt = particle.physicsPosition;
     if(!CGPointEqualToPoint(CGPointZero,pt)) didFindMovingParticle = YES;
     // NSLog(@"pt.x:%f",pt.x);
     // NSLog(@"pt.y:%f",pt.y);
     
     if (firstParticle) {
     bottomright     = pt;
     topleft         = pt;
     firstParticle   = NO;
     }
     
     if (pt.x > bottomright.x) bottomright.x = pt.x;
     if (pt.y > bottomright.y) bottomright.y = pt.y;
     if   (pt.x < topleft.x)   topleft.x = pt.x;
     if   (pt.y < topleft.y)   topleft.y = pt.y;
     }
     float width = bottomright.x - topleft.x;
     float height = bottomright.y - topleft.y;
     
     CGRect rect = CGRectMake(topleft.x, topleft.y, width*PTM_RATIO, height*PTM_RATIO);
     
     if (didFindMovingParticle){
     self.bounds = rect;
     //  NSLog(@"BARNES HUT - width:%f height:%f",height*PTM_RATIO,height*PTM_RATIO);
     }*/
     
     
     // NSLog(@"topLeft.x:%f",topleft.x);
     // NSLog(@"topLeft.y:%f",topleft.y);

}

- (void) eulerIntegrator:(CGFloat)deltaTime
{
    NSParameterAssert(deltaTime > 0.0);
    
    // Without advancement of time, does the simulation have meaning?
    if (deltaTime <= 0.0) return;

    
    if (self.repulsion > 0.0) {
        
       // if (self.theta > 0.0) {
            [self applyBarnesHutRepulsion];
       // } else {
       //     [self applyBruteForceRepulsion];
       // }
        
    }
    
    if (self.stiffness > 0.0) [self applySprings];
   // [self applyCenterDrift];
   // if (self.gravity) [self applyCenterGravity];
   // [self updateVelocity:deltaTime];
   // [self updatePosition:deltaTime];
}

- (void) applyBruteForceRepulsion 
{
    for (ATParticle *subject in activeParticles_) {
        for (ATParticle *object in activeParticles_) {
            if (subject != object){
                CGPoint d = CGPointSubtract(subject.position, object.position);
                CGFloat distance = MAX( 1.0, CGPointMagnitude(d) );
                CGPoint direction = (CGPointMagnitude(d) > 0.0) ? d : CGPointNormalize( CGPointRandom(1.0) );
                
                // apply force to each end point
                // (consult the cached `real' mass value if the mass is being poked to allow
                // for repositioning. the poked mass will still be used in .applyforce() so
                // all should be well)
                
                CGPoint force = CGPointDivideFloat( 
                                                   CGPointScale(direction, 
                                                                (self.repulsion * object.mass * 0.5) ), 
                                                   (distance * distance * 0.5) );
                
                [subject applyForce:force];
                
                
                force = CGPointDivideFloat(
                                           CGPointScale(direction, 
                                                        (self.repulsion * subject.mass * 0.5) ),
                                           (distance * distance * -0.5) );
                
                [object applyForce:force];
            }
        }
    }
}

- (void) applyBarnesHutRepulsion
{
    NSLog(@"applyBarnesHutRepulsion");
    // build a barnes-hut tree...
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    float widthInMeters = screenSize.width / PTM_RATIO;
    float heightInMeters = screenSize.height / PTM_RATIO;
    
    //keep the bound strangled to window layout for now
    if (1){ // old-fashioned Cartesian one with (0,0) in the center  
       self.bounds  = CGRectMake(-widthInMeters/2*kBoundsRatioToScreen, -heightInMeters/2*kBoundsRatioToScreen, widthInMeters*kBoundsRatioToScreen,heightInMeters*kBoundsRatioToScreen);
    }else{
       self.bounds  = CGRectMake(0, 0, widthInMeters,heightInMeters);
    }
    
    [bhTree_ updateWithBounds:self.bounds theta:self.theta];
    
    for (ATParticle *particle in activeParticles_) {
        [bhTree_ insertParticle:particle];

    }
    
    // ...and use it to approximate the repulsion forces
    for (ATParticle *particle in activeParticles_) {
        [bhTree_ applyForces:particle andRepulsion:self.repulsion];
    }
}

- (void) applySprings 
{
    return;
    NSLog(@"applySprings");
    for (ATSpring *spring in activeSprings_) {
        CGPoint d = CGPointSubtract(spring.target.position, spring.source.position); // the direction of the spring
        NSLog(@"spring.target.physicsPosition.x:%f",spring.target.physicsPosition.x);
        NSLog(@"spring.target.physicsPosition.y:%f",spring.target.physicsPosition.y);
        NSLog(@"spring.source.physicsPosition.x:%f",spring.source.physicsPosition.x);
        NSLog(@"spring.source.physicsPosition.y:%f",spring.source.physicsPosition.y);
        NSLog(@"CGPointMagnitude(d):%f",CGPointMagnitude(d));
        CGFloat displacement = spring.length - CGPointMagnitude(d);
        
        CGPoint direction = CGPointNormalize( (CGPointMagnitude(d) > 0.0) ? d : CGPointRandom(1.0) );
        NSLog(@"direction x:%f y:%f",direction.x,direction.y);

        // BUG:
        // since things oscillate wildly for hub nodes, should probably normalize spring
        // forces by the number of incoming edges for each node. naive normalization 
        // doesn't work very well though. what's the `right' way to do it?
        
        // apply force to each end point
       /* [spring.point1 applyForce:CGPointScale(direction, spring.stiffness * displacement * -0.5) ];
        [spring.point2 applyForce:CGPointScale(direction, spring.stiffness * displacement * 0.5) ];*/
        [spring.point1 applyForce:CGPointScale(direction, displacement  * 0.5) ];
        [spring.point2 applyForce:CGPointScale(direction,  displacement * 0.5) ];
        
    }    
}

- (void) applyCenterDrift 
{
    // find the centroid of all the particles in the system and shift everything
    // so the cloud is centered over the origin
    
    NSUInteger numParticles = 0;
    CGPoint centroid = CGPointZero;
    for (ATParticle *particle in activeParticles_) {
        centroid = CGPointAdd(centroid, particle.physicsPosition);
        numParticles++;
    }
    
    if (numParticles == 0) return;
    
    CGPoint correction = CGPointDivideFloat(centroid, -numParticles);
    for (ATParticle *particle in activeParticles_) {
        [particle applyForce:correction];
    }
}

- (void) applyCenterGravity
{
    NSLog(@"applyCenterGravity");

    for (ATParticle *particle in activeParticles_) {
        CGPoint direction = CGPointScale(particle.physicsPosition, -1.0);
        [particle applyForce:CGPointScale(direction, (self.repulsion / 100.0))];
    }
}

- (void) updateVelocity:(CGFloat)timestep 
{
    NSParameterAssert(timestep > 0.0);
    
    // Without advancement of time, does the simulation have meaning?
    if (timestep <= 0.0) return;
    
    // translate forces to a new velocity for this particle
    for (ATParticle *particle in activeParticles_) {
        if (particle.fixed){
            particle.velocity = CGPointZero;
            particle.force = CGPointZero;
            continue;
        }
        NSLog(@" particle.force x:%f", particle.force.x);
        NSLog(@" particle.force y:%f", particle.force.y);
        
        particle.velocity = CGPointScale(CGPointAdd(particle.velocity, 
                                                    CGPointScale( particle.force, timestep)), 
                                         (1.0 - self.friction));
        
        particle.force = CGPointZero;
        
        // Slow down the particle if it is moving too fast.  Due to large timeStep etc.
        CGFloat speed = CGPointMagnitude(particle.velocity);
        if (speed > self.speedLimit) {
            particle.velocity = CGPointDivideFloat(particle.velocity, speed * speed);   
        }
    }
}

- (void) updatePosition:(CGFloat)timestep 
{
    NSParameterAssert(timestep > 0.0);
    
    // Without advancement of time, does the simulation have meaning?
    if (timestep <= 0.0) return;
    
    // translate velocity to a position delta
    CGFloat sum = 0.0, max = 0.0, n = 0.0;
    CGPoint bottomright = CGPointZero;
    CGPoint topleft     = CGPointZero;
    BOOL firstParticle  = YES;
    
    for (ATParticle *particle in activeParticles_) {
        // move the node to its new position
        //NSLog(@"velocity x:%f",particle.velocity.x);
        //NSLog(@"velocity y:%f",particle.velocity.y);
        
        CGPoint pos = particle.physicsPosition;
        CGPoint v0 = {0,0};
        CGPoint v1 = particle.velocity;
        if (CGPointEqualToPoint(v0,v1)) {
            
        }else{
            particle.physicsPosition = CGPointAdd(pos, CGPointScale(v1, timestep) );
        }

        // keep stats to report in systemEnergy
        CGFloat speed = CGPointMagnitude(particle.velocity);
        CGFloat e = speed * speed;
        sum += e;
        max = MAX(e, max);
        n++;
        
        // update the bounds
        CGPoint pt = particle.physicsPosition;
        
        if (firstParticle) {
            bottomright     = pt;
            topleft         = pt;
            firstParticle   = NO;
        }
        
        if (pt.x > bottomright.x) bottomright.x = pt.x;
        if (pt.y > bottomright.y) bottomright.y = pt.y;          
        if   (pt.x < topleft.x)   topleft.x = pt.x;
        if   (pt.y < topleft.y)   topleft.y = pt.y;
    }
    
    energy_.sum     = sum;
    energy_.max     = max;
    energy_.mean    = sum/n;
    energy_.count   = n;
    
    self.bounds = CGRectMake(topleft.x, topleft.y, bottomright.x - topleft.x, bottomright.y - topleft.y);
}


@end
