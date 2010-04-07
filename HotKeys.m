#import "HotKeys.h"
#import "TilerAppDelegate.h"
#import <unistd.h>
#import <Carbon/Carbon.h>

enum {
	MJS1_MOVE_LEFT,
	MJS1_MOVE_RIGHT,
	MJS1_MOVE_UP,
	MJS1_MOVE_DOWN,
	MJS1_FOCUS_LEFT,
	MJS1_FOCUS_RIGHT,
	MJS1_FOCUS_UP,
	MJS1_FOCUS_DOWN,
	MJS1_ADD,
	MJS1_ADD_COLUMN,
};

static OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	EventHotKeyID hotKeyID;
	GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,
					  NULL,sizeof(hotKeyID),NULL,&hotKeyID);

	if (hotKeyID.signature == 'mjs1') {
		TilerAppDelegate *appDelegate = (TilerAppDelegate *)userData;
		switch (hotKeyID.id) {
			case MJS1_MOVE_LEFT:
			case MJS1_MOVE_RIGHT:
			case MJS1_MOVE_UP:
			case MJS1_MOVE_DOWN:
				[appDelegate move:hotKeyID.id];
				break;
			case MJS1_FOCUS_RIGHT:
			case MJS1_FOCUS_LEFT:
			case MJS1_FOCUS_UP:
			case MJS1_FOCUS_DOWN:
				[appDelegate focus:hotKeyID.id - 4];
				break;
			case MJS1_ADD:
				[appDelegate addFrontMostWindow];
				break;
		}
	}
	return TRUE;
}

void initHotKeys(void* appDelegate) {
	EventTypeSpec eventType;
	eventType.eventClass = kEventClassKeyboard;
	eventType.eventKind = kEventHotKeyPressed;
	InstallApplicationEventHandler(&hotKeyHandler, 1, &eventType, (void*)appDelegate, NULL);

	OSStatus error;
	EventHotKeyID hotKeyID;
	EventHotKeyRef hotKeyRef;

	hotKeyID.signature = 'mjs1';
	hotKeyID.id = MJS1_ADD;

	error = RegisterEventHotKey(0x31, cmdKey+optionKey+controlKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);

	hotKeyID.id = MJS1_MOVE_LEFT;

	error = RegisterEventHotKey(0x7B, cmdKey+optionKey+controlKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);
	
	hotKeyID.id = MJS1_MOVE_RIGHT;
	
	error = RegisterEventHotKey(0x7C, cmdKey+optionKey+controlKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);

	hotKeyID.id = MJS1_MOVE_UP;
	
	error = RegisterEventHotKey(0x7E, cmdKey+optionKey+controlKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);
	
	hotKeyID.id = MJS1_MOVE_DOWN;
	
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