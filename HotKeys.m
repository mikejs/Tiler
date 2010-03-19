#import "HotKeys.h"
#import "TilerAppDelegate.h"
#import <unistd.h>
#import <Carbon/Carbon.h>

static OSStatus HotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	EventHotKeyID hotKeyID;
	GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,
					  NULL,sizeof(hotKeyID),NULL,&hotKeyID);
	
	if (hotKeyID.signature == 'mjs1' && hotKeyID.id == 1) {
		TilerAppDelegate *appDelegate = (TilerAppDelegate *)userData;
		[appDelegate addFrontMostWindow];
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
	hotKeyID.id = 1;

	error = RegisterEventHotKey(123, cmdKey+optionKey+controlKey, hotKeyID,
								GetEventDispatcherTarget(), 0, &hotKeyRef);

	if(error) {
		NSLog(@"ERROR!!!");
	}
}