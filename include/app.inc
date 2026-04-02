// ============================================================
// app.inc - App registry structure
//
// Defines how apps are stored in the app registry and
// provides helper macros for accessing app functions.
//
// Each app has 4 functions:
//   - render(window*, active): Draw the app content
//   - input(window*, event): Handle keyboard input
//   - init(window*): Initialize app state
//   - destroy(): Clean up resources
//
// Registry layout (each app occupies 32 bytes):
//   [offset 0]  = render function pointer (8 bytes)
//   [offset 8]  = input function pointer (8 bytes)
//   [offset 16] = init function pointer (8 bytes)
//   [offset 24] = destroy function pointer (8 bytes)
// ============================================================

// Number of bytes per app entry in registry
.equ APP_ENTRY_SIZE, 32

// Offsets within each app entry
.equ APP_RENDER_FN,   0
.equ APP_INPUT_FN,    8
.equ APP_INIT_FN,    16
.equ APP_DESTROY_FN, 24

// ============================================================
// APP_REGISTRY_GET - Macro to get function pointer from registry
//
// Usage: APP_REGISTRY_GET result, app_id, function_offset
// Example: APP_REGISTRY_GET x0, x1, APP_RENDER_FN
// ============================================================

.macro APP_REGISTRY_GET result, app_id, offset
    // Calculate byte offset: app_id * APP_ENTRY_SIZE + offset
    mov x9, #\app_id
    mov x10, #32
    mul x9, x9, x10
    add x9, x9, #\offset
    
    // Load base address of registry
    ldr x10, =app_registry
    
    // Add offset and load function pointer
    add \result, x10, x9
    ldr \result, [\result]
.endm
