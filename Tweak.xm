#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// Ignore strict warnings that might stop the build
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wint-conversion"

// Your Offset
#define OFF_GET_DELTATIME 0x297749C

// Setup hook variables
float (*old_get_deltaTime)(void *instance);

float new_get_deltaTime(void *instance) {
    // Code here runs every frame
    return old_get_deltaTime(instance);
}

%ctor {
    // FIX: We explicitly cast the pointer to 'unsigned long'
    // This stops the "incompatible pointer to integer conversion" error
    unsigned long baseAddr = (unsigned long)_dyld_get_image_header(0);
    
    // Calculate final address
    unsigned long finalAddr = baseAddr + OFF_GET_DELTATIME;
    
    // Create the hook
    MSHookFunction((void *)finalAddr, (void *)new_get_deltaTime, (void **)&old_get_deltaTime);
}
