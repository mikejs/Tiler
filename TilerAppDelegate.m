#import "TilerAppDelegate.h"
#import "utils.h"
#import <unistd.h>
#import <Carbon/Carbon.h>

@implementation TilerAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	initHotKeys();
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
	if (![col containsObject:(id)window]) {
		[col insertObject:(id)window atIndex:0];
	}
}

- (void)reflow {
	AXValueRef temp;
	CGSize windowSize;
	CGSize menuSize;
	CGPoint windowPosition;
	AXUIElementRef menuBar;
	NSRect frame;

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

- (void)move:(direction)where {
	AXUIElementRef window;
	NSUInteger pos;
	
	window = getFrontMostWindow();	
	
	for (int col = 0; col < [columns count]; col++) {
		NSMutableArray *column = [columns objectAtIndex:col];
		
		NSUInteger index = [column indexOfObject:(id)window];
		
		if (index != NSNotFound) {
			NSMutableArray *to_col;
			
			switch(where) {
				case LEFT:
					if (col <= 0) {
						to_col = [columns lastObject];
					} else {
						to_col = [columns objectAtIndex:col-1];
					}
					pos = 0;
					break;
				case RIGHT:
					if (col >= [columns count]) {
						to_col = [columns objectAtIndex:0];
					} else {
						to_col = [columns objectAtIndex:col+1];
					}
					pos = 0;
					break;
				case UP:
					if (index <= 0) {
						pos = [column count] - 1;
					} else {
						pos = index - 1;
					}
					to_col = column;
					break;
				case DOWN:
					if (index >= [column count] - 1) {
						pos = 0;
					} else {
						pos = index + 1;
					}
					to_col = column;
					break;
				default:
					NSLog(@"Bad where %@", where);
					exit(1);
			}
			
			[column removeObjectAtIndex:index];
			[to_col insertObject:(id)window atIndex:pos];
			
			[self reflow];

			return;
		}
	}
}

- (void)focus:(direction)where {
	AXUIElementRef window = getFrontMostWindow();
	
	NSUInteger col_count = [columns count];
	for (int col = 0; col < col_count; col++) {
		NSArray *column = [columns objectAtIndex:col];
		NSUInteger win_count = [column count];
		
		NSUInteger win = [column indexOfObject:(id)window];

		if (win != NSNotFound) {
			int to_col, to_win;

			switch(where) {
				case LEFT:
					if (col <= 0) {
						to_col = col_count - 1;
					} else {
						to_col = col - 1;
					}
					to_win = 0;
					break;
				case RIGHT:
					if (col >= col_count - 1) {
						to_col = 0;
					} else {
						to_col = col + 1;
					}
					to_win = 0;
					break;
				case UP:
					if (win <= 0) {
						to_win = win_count - 1;
					} else {
						to_win = win - 1;
					}
					to_col = col;
					break;
				case DOWN:
					if (win >=win_count - 1) {
						to_win = 0;
					} else {
						to_win = win + 1;
					}
					to_col = col;
					break;
				default:
					NSLog(@"Bad where %@", where);
					exit(1);
			}

			NSLog(@"%d, %d", to_col, to_win);
			
			AXUIElementRef to_window = (AXUIElementRef)[[columns objectAtIndex:to_col] objectAtIndex:to_win];
			pid_t pid;
			AXUIElementGetPid(to_window, &pid);
			ProcessSerialNumber psn;
			GetProcessForPID(pid, &psn);
			SetFrontProcessWithOptions(&psn, kSetFrontProcessFrontWindowOnly);
			
			AXUIElementPerformAction(to_window, (CFStringRef)@"AXRaise");
			
			return;
		}
	}
}

@end
