#include "utils.h"

bool axIsAuthorized()
{
    if (AXAPIEnabled() != 0) {
        return true;
    }
	
    if (AXIsProcessTrusted() != 0) {
        return true;
    }
	
    return false;
}

AXUIElementRef getFrontMostApp()
{
    pid_t pid;
    ProcessSerialNumber psn;
	
    GetFrontProcess(&psn);
    GetProcessPID(&psn, &pid);
    return AXUIElementCreateApplication(pid);
}

AXUIElementRef getFrontMostWindow()
{
	AXUIElementRef frontMostWindow;
	AXUIElementCopyAttributeValue(getFrontMostApp(), kAXFocusedWindowAttribute,
								  (CFTypeRef *)&frontMostWindow);
	
	return frontMostWindow;
}
