#import "HotKeys.h"
#import "TilerAppDelegate.h"
#import <unistd.h>
#import <Carbon/Carbon.h>

enum {
	MJS1_ADD,
	MJS1_LEFT,
	MJS1_RIGHT,
	MJS1_UP,
	MJS1_DOWN,
	MJS1_ADD_COLUMN,
	MJS1_FOCUS_RIGHT,
	MJS1_FOCUS_LEFT,
	MJS1_FOCUS_UP,
	MJS1_FOCUS_DOWN,
};

static OSStatus HotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	EventHotKeyID hotKeyID;
	GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,
					  NULL,sizeof(hotKeyID),NULL,&hotKeyID);

	if (hotKeyID.signature == 'mjs1') {
		TilerAppDelegate *appDelegate = (TilerAppDelegate *)userData;
		switch (hotKeyID.id) {
			case MJS1_ADD: [appDelegate addFrontMostWindow];
				break;
			case MJS1_LEFT: [appDelegate move:@"left"];
				break;
			case MJS1_RIGHT: [appDelegate move:@"right"];
				break;
			case MJS1_UP: [appDelegate move:@"up"];
				break;
			case MJS1_DOWN: [appDelegate move:@"down"];
				break;
			case MJS1_FOCUS_RIGHT: [appDelegate focus:@"left"];
				break;
			case MJS1_FOCUS_LEFT: [appDelegate focus:@"right"];
				break;
			case MJS1_FOCUS_UP: [appDelegate focus:@"up"];
				break;
			case MJS1_FOCUS_DOWN: [appDelegate focus:@"down"];
				break;
		}
	}
	return TRUE;
}

void InitHotKeys(void* appDelegate) {
	EventTypeSpec eventType;
	eventType.eventClass = kEventClassKeyboard;
	eventType.eventKind = kEventHotKeyPressed;
	InstallApplicationEventHandler(&HotKeyHandler, 1, &eventType, (void*)appDelegate, NULL);

	OSStatus error;
	EventHotKeyID hotKeyID;
	EventHotKeyRef hotKeyRef;

	hotKeyID.signature = 'mjs1';
	hotKeyID.id = MJS1_ADD;

	error = RegisterEventHotKey(0x31, cmdKey+optionKey+controlKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);

	hotKeyID.id = MJS1_LEFT;

	error = RegisterEventHotKey(0x7B, cmdKey+optionKey+controlKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);
	
	hotKeyID.id = MJS1_RIGHT;
	
	error = RegisterEventHotKey(0x7C, cmdKey+optionKey+controlKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);

	hotKeyID.id = MJS1_UP;
	
	error = RegisterEventHotKey(0x7E, cmdKey+optionKey+controlKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);
	
	hotKeyID.id = MJS1_DOWN;
	
	error = RegisterEventHotKey(0x7D, cmdKey+optionKey+controlKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);
	
	hotKeyID.id = MJS1_FOCUS_LEFT;
	
	error = RegisterEventHotKey(0x7B, cmdKey+optionKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);
	
	hotKeyID.id = MJS1_FOCUS_RIGHT;
	
	error = RegisterEventHotKey(0x7C, cmdKey+optionKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);
	
	hotKeyID.id = MJS1_FOCUS_UP;
	
	error = RegisterEventHotKey(0x7E, cmdKey+optionKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);
	
	hotKeyID.id = MJS1_FOCUS_DOWN;
	
	error = RegisterEventHotKey(0x7D, cmdKey+optionKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);
	if(error) {
		NSLog(@"ERROR!!!");
	}
}