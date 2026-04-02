// ============================================================
// app_manager.s - App registry management
//
// Provides functions to access app functions from the registry.
// The registry is an array of app entries, each containing
// pointers to the app's render, input, init, and destroy functions.
//
// Usage:
//   mov x0, #APP_FILE_MANAGER   // app ID
//   bl app_get_render_fn         // returns function pointer in x0
// ============================================================

.include "common.inc"

.section .text

// ============================================================
// app_get_render_fn
//
// Get the render function pointer for an app.
//
// Input:
//   x0 = app ID
//
// Output:
//   x0 = function pointer (or 0 if not found)
// ============================================================

.global app_get_render_fn
app_get_render_fn:
    // Calculate offset: app_id * APP_ENTRY_SIZE + APP_RENDER_FN
    // APP_ENTRY_SIZE = 32, so we shift left 5 bits instead of multiply
    mov x1, #32
    mul x1, x0, x1
    add x1, x1, #APP_RENDER_FN
    
    // Load registry base and add offset
    ldr x2, =app_registry
    add x0, x2, x1
    
    // Return function pointer
    ldr x0, [x0]
    ret

// ============================================================
// app_get_input_fn
//
// Get the input handler function pointer for an app.
//
// Input:
//   x0 = app ID
//
// Output:
//   x0 = function pointer (or 0 if not found)
// ============================================================

.global app_get_input_fn
app_get_input_fn:
    mov x1, #32
    mul x1, x0, x1
    add x1, x1, #APP_INPUT_FN
    
    ldr x2, =app_registry
    add x0, x2, x1
    ldr x0, [x0]
    ret

// ============================================================
// app_get_init_fn
//
// Get the init function pointer for an app.
//
// Input:
//   x0 = app ID
//
// Output:
//   x0 = function pointer (or 0 if not found)
// ============================================================

.global app_get_init_fn
app_get_init_fn:
    mov x1, #32
    mul x1, x0, x1
    add x1, x1, #APP_INIT_FN
    
    ldr x2, =app_registry
    add x0, x2, x1
    ldr x0, [x0]
    ret

// ============================================================
// app_get_destroy_fn
//
// Get the destroy function pointer for an app.
//
// Input:
//   x0 = app ID
//
// Output:
//   x0 = function pointer (or 0 if not found)
// ============================================================

.global app_get_destroy_fn
app_get_destroy_fn:
    mov x1, #32
    mul x1, x0, x1
    add x1, x1, #APP_DESTROY_FN
    
    ldr x2, =app_registry
    add x0, x2, x1
    ldr x0, [x0]
    ret
