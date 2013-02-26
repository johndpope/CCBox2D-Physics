#import <UIKit/UIKit.h>
#import "BaseAppController.h"
#import "ATSystem.h"

@class Box2DView;

@interface Box2DAppDelegate : BaseAppController
@property (nonatomic,retain)ATSystem *system;
@end
