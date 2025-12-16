#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#import <stdint.h>

#define OFF_GET_DELTATIME 0x297749C

// Setup the old function storage
float (*old_get_deltaTime)(void *instance);

// Our new function
float new_get_deltaTime(void *instance) {
    return old_get_deltaTime(instance);
}

%ctor {
    // 1. Get Base Address (Safe Cast)
    uintptr_t baseAddr = _dyld_get_image_header(0);
    
    // 2. Add Offset
    uintptr_t finalAddr = baseAddr + OFF_GET_DELTATIME;
    
    // 3. Hook
    MSHookFunction((void *)finalAddr, (void *)new_get_deltaTime, (void **)&old_get_deltaTime);
}
