#import <Cocoa/Cocoa.h>

@interface TilerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
//	NSMutableArray *windows;
	NSMutableArray *columns;
}

- (void)addFrontMostWindow;
- (void)addWindow:(AXUIElementRef)window;
- (void)reflow;
- (void)move:(NSString *)where;

@property (assign) IBOutlet NSWindow *window;

@end
