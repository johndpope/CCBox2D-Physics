#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "CCWorldLayer.h"

@interface CCBox2DView : CCLayer {

	//TestEntry* entry;
	//Test* test;
	int		entryID;
}
+(id) viewWithEntryID:(int)entryId;
-(id) initWithEntryID:(int)entryId;
-(NSString*) title;
@end