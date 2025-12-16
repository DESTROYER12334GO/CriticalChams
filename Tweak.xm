#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <vector>

// --- 1.  OFFSETS  ---
#define OFFSET_ShaderFind   0x297749C
#define OFFSET_FindObjects  0x27F4D6C

// --- 2. STRUCTURES ---
template <typename T>
struct UnityArray {
    uintptr_t ob_class;
    uintptr_t monitor;
    uintptr_t bounds;
    int max_length;
    T vector[65535];
};

// --- 3. VARIABLES ---
void* (*ShaderFind)(void* nameString);
UnityArray<void*>* (*FindObjectsOfType)(void* type);

// These will be found automatically by name
void* (*GetMaterial)(void* renderer);
void* (*SetShader)(void* material, void* shader);
void* (*il2cpp_string_new)(const char* str);
void* (*il2cpp_resolve_icall)(const char* str);

// --- 4. HELPERS ---
void* MakeString(const char* str) {
    return il2cpp_string_new(str);
}

// --- 5. THE CHEAT LOGIC ---
void ApplyChams() {
    // 1. Get the "Chams" Shader
    static void* chamsShader = nullptr;
    if (!chamsShader) {
        // We use the exact shader name you found in IDA
        chamsShader = ShaderFind(MakeString("Hidden/Internal-GUITexture"));
    }

    // 2. Get the "Renderer" Type
    static void* rendererType = nullptr;
    if (!rendererType) {
        // Resolve GetType dynamically
        void* (*GetType)(const char*) = (void*(*)(const char*)) il2cpp_resolve_icall("UnityEngine.Type::GetType(System.String)");
        if (GetType) rendererType = GetType("UnityEngine.Renderer, UnityEngine");
    }

    if (!rendererType || !chamsShader) return;

    // 3. Get All Players/Objects
    UnityArray<void*>* renderers = FindObjectsOfType(rendererType);
    if (!renderers) return;

    // 4. Loop and Apply Shader
    for (int i = 0; i < renderers->max_length; i++) {
        void* renderer = renderers->vector[i];
        if (!renderer) continue;

        void* material = GetMaterial(renderer);
        if (material) {
            SetShader(material, chamsShader);
        }
    }
}

// --- 6. THE HOOK (Run Loop) ---
// We hook deltaTime because it runs every frame
float (*old_get_deltaTime)();
float get_deltaTime_Hook() {
    ApplyChams();
    return old_get_deltaTime();
}

// --- 7. STARTUP ---
%ctor {
    // A. Calculate Base Address
    uintptr_t base = _dyld_get_image_header(0);

    // B. Link Your Offsets
    ShaderFind = (void*(*)(void*)) (base + OFFSET_ShaderFind);
    FindObjectsOfType = (void*(*)(void*)) (base + OFFSET_FindObjects);

    // C. Link Helper Functions (Dynamic)
    void* handle = dlopen(NULL, RTLD_NOW);
    il2cpp_string_new = (void*(*)(const char*)) dlsym(handle, "il2cpp_string_new");
    il2cpp_resolve_icall = (void*(*)(const char*)) dlsym(handle, "il2cpp_resolve_icall");

    if (il2cpp_resolve_icall) {
        GetMaterial = (void*(*)(void*)) il2cpp_resolve_icall("UnityEngine.Renderer::get_material");
        SetShader   = (void*(*)(void*, void*)) il2cpp_resolve_icall("UnityEngine.Material::set_shader");
    
        // D. Activate Hook
        void* deltaTimeAddr = il2cpp_resolve_icall("UnityEngine.Time::get_deltaTime");
        if (deltaTimeAddr) {
            MSHookFunction(deltaTimeAddr, (void*)get_deltaTime_Hook, (void**)&old_get_deltaTime);
        }
    }
}

```
