#import <Cocoa/Cocoa.h>

@interface TilerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSMutableArray *windows;
}

- (void)addFrontMostWindow;
- (void)addWindow:(AXUIElementRef)window;
- (void)reflow;
- (void)left;

@property (assign) IBOutlet NSWindow *window;

@end
