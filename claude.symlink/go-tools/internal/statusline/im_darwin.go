//go:build darwin

package statusline

/*
#cgo LDFLAGS: -framework Carbon
#include <Carbon/Carbon.h>
#include <stdlib.h>

// getCurrentInputSourceID returns the current keyboard input source ID.
// Caller must free the returned string.
const char* getCurrentInputSourceID() {
    TISInputSourceRef source = TISCopyCurrentKeyboardInputSource();
    if (source == NULL) return NULL;

    CFStringRef sourceID = (CFStringRef)TISGetInputSourceProperty(source, kTISPropertyInputSourceID);
    if (sourceID == NULL) {
        CFRelease(source);
        return NULL;
    }

    CFIndex length = CFStringGetLength(sourceID);
    CFIndex maxSize = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
    char *buffer = (char *)malloc(maxSize);
    if (buffer == NULL) {
        CFRelease(source);
        return NULL;
    }

    if (!CFStringGetCString(sourceID, buffer, maxSize, kCFStringEncodingUTF8)) {
        free(buffer);
        CFRelease(source);
        return NULL;
    }

    CFRelease(source);
    return buffer;
}

// selectInputSource selects the input source by its ID string.
// Returns 0 on success, -1 on failure.
int selectInputSource(const char* sourceIDStr) {
    CFStringRef targetID = CFStringCreateWithCString(kCFAllocatorDefault, sourceIDStr, kCFStringEncodingUTF8);
    if (targetID == NULL) return -1;

    const void *keys[] = { kTISPropertyInputSourceID };
    const void *values[] = { targetID };
    CFDictionaryRef filter = CFDictionaryCreate(kCFAllocatorDefault,
        keys, values, 1,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    CFArrayRef sources = TISCreateInputSourceList(filter, false);
    CFRelease(filter);
    CFRelease(targetID);

    if (sources == NULL || CFArrayGetCount(sources) == 0) {
        if (sources) CFRelease(sources);
        return -1;
    }

    TISInputSourceRef targetSource = (TISInputSourceRef)CFArrayGetValueAtIndex(sources, 0);
    OSStatus status = TISSelectInputSource(targetSource);
    CFRelease(sources);

    return (status == noErr) ? 0 : -1;
}
*/
import "C"

import "unsafe"

// nativeGetCurrentIM returns the current input method ID using Carbon API.
func nativeGetCurrentIM() string {
	cStr := C.getCurrentInputSourceID()
	if cStr == nil {
		return ""
	}
	defer C.free(unsafe.Pointer(cStr))
	return C.GoString(cStr)
}

// nativeSetIM selects the input method by ID using Carbon API.
func nativeSetIM(sourceID string) bool {
	cStr := C.CString(sourceID)
	defer C.free(unsafe.Pointer(cStr))
	return C.selectInputSource(cStr) == 0
}

// nativeIMAvailable returns true on macOS where Carbon API is available.
func nativeIMAvailable() bool {
	return true
}
