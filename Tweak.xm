#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// This tells the compiler to relax and not panic over small errors
#pragma clang diagnostic ignored "-Wunused-variable"

// The Address you found (Make sure this matches your IDA offset!)
#define OFF_GET_DELTATIME 0x297749C

// Setup the function hook
float (*old_get_deltaTime)(void *instance);

float new_get_deltaTime(void *instance) {
    // This runs every single frame.
    // If we can see this log, the cheat is working.
    // NSLog(@"[CriticalChams] Hook is running!");
    
    return old_get_deltaTime(instance);
}

// The "Main" function that runs when the game starts
%ctor {
    // 1. Get the game's memory location
    unsigned long baseAddr = _dyld_get_image_header(0);
    
    // 2. Calculate the real address of the function
    unsigned long finalAddr = baseAddr + OFF_GET_DELTATIME;
    
    // 3. Hook it!
    MSHookFunction((void *)finalAddr, (void *)new_get_deltaTime, (void **)&old_get_deltaTime);
}
