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
	windows = [NSMutableArray new];
}

- (void)addFrontMostWindow {
	[self addWindow:getFrontMostWindow()];
	[self reflow];
}

- (void)addWindow:(AXUIElementRef)window {
	if (![windows containsObject:window]) {
		[windows insertObject:window atIndex:0];
	}
}

- (void)reflow {
	AXValueRef temp;
	CGSize windowSize;
	CGSize menuSize;
	CGPoint windowPosition;
	AXUIElementRef menuBar;
	NSRect frame;
	int i = 0, rightCount;

	frame = [[NSScreen mainScreen] frame];

	AXUIElementCopyAttributeValue(getFrontMostApp(), kAXMenuBarAttribute, (CFTypeRef *)&menuBar);
	AXUIElementCopyAttributeValue(menuBar, kAXSizeAttribute, (CFTypeRef *)&temp);
	AXValueGetValue(temp, kAXValueCGSizeType, &menuSize);
	CFRelease(temp);

	frame.origin.y += menuSize.height;
	frame.size.height -= menuSize.height;

	rightCount = [windows count] - 1;

	for (int i = 0; i < [windows count]; i++) {
		AXUIElementRef window = (AXUIElementRef)[windows objectAtIndex:i];
		AXUIElementCopyAttributeValue(window, kAXSizeAttribute,
									  (CFTypeRef *)&temp);
		AXValueGetValue(temp, kAXValueCGSizeType, &windowSize);
		CFRelease(temp);

		AXUIElementCopyAttributeValue(window, kAXPositionAttribute,
									  (CFTypeRef *)&temp);
		AXValueGetValue(temp, kAXValueCGPointType, &windowPosition);
		CFRelease(temp);

		if (i == 0) {
			// Primary window
			windowPosition.x = frame.origin.x;
			windowPosition.y = frame.origin.y;
			windowSize.height = frame.size.height;
			windowSize.width = frame.size.width / 2;
		} else {
			windowPosition.x = frame.origin.x + (frame.size.width / 2);
			windowPosition.y = frame.origin.y + (frame.size.height / rightCount) * (i - 1);
			windowSize.height = frame.size.height / rightCount;
			windowSize.width = frame.size.width / 2;
		}

		temp = AXValueCreate(kAXValueCGPointType, &windowPosition);
		AXUIElementSetAttributeValue(window, kAXPositionAttribute, temp);
		CFRelease(temp);

		temp = AXValueCreate(kAXValueCGSizeType, &windowSize);
		AXUIElementSetAttributeValue(window, kAXSizeAttribute, temp);
		CFRelease(temp);
	}
}

- (void)left {
	AXUIElementRef window;
	int index;

	window = getFrontMostWindow();
	index = [windows indexOfObject:window];

	if (index != NSNotFound) {
		if (index == 0) {
			[windows removeObjectAtIndex:index];
			[windows addObject:window];
		} else if (index == 1) {
			window = [windows objectAtIndex:0];
			[windows removeObjectAtIndex:0];
			[windows addObject:window];
		} else {
			[windows removeObjectAtIndex:index];
			[windows insertObject:window atIndex:index - 1];
		}
	}

	[self reflow];
}

@end
