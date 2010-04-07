#import <Cocoa/Cocoa.h>
#import "HotKeys.h"

@interface TilerAppDelegate : NSObject <NSApplicationDelegate> {
	NSMutableArray *columns;
}

- (void)addFrontMostWindow;
- (void)addWindow:(AXUIElementRef)window;
- (void)reflow;
- (void)move:(direction)where;
- (void)focus:(direction)where;

@end
