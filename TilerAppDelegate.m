#import "TilerAppDelegate.h"
#import "HotKeys.h"
#import <unistd.h>
#import <Carbon/Carbon.h>

static AXUIElementRef getFrontMostWindow();

static bool amIAuthorized()
{
    if (AXAPIEnabled() != 0) {
        return true;
    }

    if (AXIsProcessTrusted() != 0) {
        return true;
    }

    return false;
}

static AXUIElementRef getFrontMostApp()
{
    pid_t pid;
    ProcessSerialNumber psn;

    GetFrontProcess(&psn);
    GetProcessPID(&psn, &pid);
    return AXUIElementCreateApplication(pid);
}

static AXUIElementRef getFrontMostWindow()
{
	AXUIElementRef frontMostWindow;

    AXUIElementCopyAttributeValue(getFrontMostApp(), kAXFocusedWindowAttribute,
                                  (CFTypeRef *)&frontMostWindow);

	return frontMostWindow;
}

@implementation TilerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	InitHotKeys();
	columns = [NSMutableArray new];
	[columns insertObject:[NSMutableArray new] atIndex:0];
	[columns insertObject:[NSMutableArray new] atIndex:0];
}

- (void)addFrontMostWindow {
	[self addWindow:getFrontMostWindow()];
	[self reflow];
}

- (void)addWindow:(AXUIElementRef)window {
	NSMutableArray *col = [columns lastObject];
	if (![col containsObject:window]) {
		[col insertObject:window atIndex:0];
	}
}

- (void)reflow {
	AXValueRef temp;
	CGSize windowSize;
	CGSize menuSize;
	CGPoint windowPosition;
	AXUIElementRef menuBar;
	NSRect frame;
	int i = 0;

	frame = [[NSScreen mainScreen] frame];

	AXUIElementCopyAttributeValue(getFrontMostApp(), kAXMenuBarAttribute, (CFTypeRef *)&menuBar);
	AXUIElementCopyAttributeValue(menuBar, kAXSizeAttribute, (CFTypeRef *)&temp);
	AXValueGetValue(temp, kAXValueCGSizeType, &menuSize);
	CFRelease(temp);

	frame.origin.y += menuSize.height;
	frame.size.height -= menuSize.height;

	int col_count = [columns count];
	for (int col = 0; col < col_count; col++) {
		NSMutableArray *column = [columns objectAtIndex:col];
		int win_count = [column count];

		for (int i = 0; i < win_count; i++) {
			AXUIElementRef window = (AXUIElementRef)[column objectAtIndex:i];
			AXUIElementCopyAttributeValue(window, kAXSizeAttribute,
										  (CFTypeRef *)&temp);
			AXValueGetValue(temp, kAXValueCGSizeType, &windowSize);
			CFRelease(temp);

			AXUIElementCopyAttributeValue(window, kAXPositionAttribute,
										  (CFTypeRef *)&temp);
			AXValueGetValue(temp, kAXValueCGPointType, &windowPosition);
			CFRelease(temp);

			windowPosition.x = frame.origin.x + col * (frame.size.width / col_count);
			windowPosition.y = frame.origin.y + i * (frame.size.height / win_count);
			windowSize.height = frame.size.height / win_count;
			windowSize.width = frame.size.width / col_count;

			temp = AXValueCreate(kAXValueCGPointType, &windowPosition);
			AXUIElementSetAttributeValue(window, kAXPositionAttribute, temp);
			CFRelease(temp);

			temp = AXValueCreate(kAXValueCGSizeType, &windowSize);
			AXUIElementSetAttributeValue(window, kAXSizeAttribute, temp);
			CFRelease(temp);
		}
	}
}

- (void)move:(NSString *)where {
	AXUIElementRef window;
	NSUInteger pos;
	
	window = getFrontMostWindow();	
	
	for (int col = 0; col < [columns count]; col++) {
		NSMutableArray *column = [columns objectAtIndex:col];
		
		NSUInteger index = [column indexOfObject:window];
		
		if (index != NSNotFound) {
			NSMutableArray *to_col;

			if ([where isEqualToString:@"left"]) {
				if (col <= 0) {
					to_col = [columns lastObject];
				} else {
					to_col = [columns objectAtIndex:col-1];
				}
				pos = 0;
			} else if([where isEqualToString:@"right"]) {
				if (col >= [columns count]) {
					to_col = [columns objectAtIndex:0];
				} else {
					to_col = [columns objectAtIndex:col+1];
				}
				pos = 0;
			} else if([where isEqualToString:@"up"]) {
				if (index <= 0) {
					pos = [column count] - 1;
				} else {
					pos = index - 1;
				}
				to_col = column;
			} else if([where isEqualToString:@"down"]) {
				if (index >= [column count] - 1) {
					pos = 0;
				} else {
					pos = index + 1;
				}
				to_col = column;
			} else {
				NSLog(@"Bad where %@", where);
				exit(1);
			}
			
			[column removeObjectAtIndex:index];
			[to_col insertObject:window atIndex:pos];
			
			[self reflow];

			return;
		}
	}
}

@end
