#import <Cocoa/Cocoa.h>

@interface TilerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;

	NSMutableArray *columns, *widths;
}

- (void)addFrontMostWindow;
- (void)addWindow:(AXUIElementRef)window;
- (void)reflow;
- (void)move:(NSString *)where;
- (void)focus:(NSString *)where;

@property (assign) IBOutlet NSWindow *window;

@end
