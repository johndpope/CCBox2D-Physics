//
//  ATParticle.h
//  PSArborTouch
//
//  Created by Ed Preston on 19/09/11.
//  Copyright 2011 Preston Software. All rights reserved.
//

#import "ATNode.h"
#import "Box2D.h"
#import "cocos2d.h"




@interface ATParticle : ATNode
{
         float deltaAngle;
     
   
	b2World *_world;      // owned by GameLayer
	b2Body *_body;        // owned by b2World
    
@private
    CGPoint     velocity_;
    CGPoint     force_;
    CGFloat     tempMass_;
    
    NSUInteger  connections_;
        
}
@property (nonatomic,retain) CCSprite *sprite;
@property (nonatomic,retain) UIView *particleView;
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) CGPoint force;
@property (nonatomic, assign) CGFloat tempMass;
@property (nonatomic, assign) NSUInteger connections;

- (id) init;

- (id)initWithWorld:(b2World *)world size:(int)size position:(CGPoint)position angle:(float)angle name:(NSString*)name userData:(NSMutableDictionary*)userData;
- (void) applyForce:(CGPoint)force;
- (void) createPhysicsObject:(b2World *)world;

@end
