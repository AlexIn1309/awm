// ============================================================
// window.s - Window rendering
//
// Renders the main window with border and calls the
// active app's render function.
//
// Window structure:
//   +--------------------------------------------------+
//   | [tab1] [tab2] [tab3]                    [AWM]   | <- tab bar
//   +--------------------------------------------------+
//   |                                                  |
//   |              APP CONTENT AREA                    |
//   |                                                  |
//   |                                                  |
//   +--------------------------------------------------+
// ============================================================

.include "common.inc"

.section .text
.global render_window
.global init_window
.global init_windows

// ============================================================
// init_windows - Initialize all windows
//
// Called once at startup to set up the window system.
// ============================================================

init_windows:
    stp x29, x30, [sp, #-16]!
    
    // Initialize the main window
    adrp x0, window0
    add x0, x0, :lo12:window0
    bl init_window
    
    // Set initial app (File Manager = app 0)
    mov x1, #0
    str x1, [x0, #WINDOW_APP_ID]
    
    // Initialize the app (x0 already has window pointer)
    bl app1_init
    
    ldp x29, x30, [sp], #16
    ret

// ============================================================
// init_window - Configure window dimensions
//
// Input:
//   x0 = window pointer
// ============================================================

init_window:
    // Set window position and size
    // Keep within framebuffer bounds (98x30 = 2940 bytes)
    mov x1, #5              // x = 5
    str x1, [x0, #WINDOW_X]
    
    mov x1, #2              // y = 2 (leave room for tab bar at y=3)
    str x1, [x0, #WINDOW_Y]
    
    mov x1, #88             // width = 88
    str x1, [x0, #WINDOW_W]
    
    mov x1, #25             // height = 25 (max y = 2+25-1 = 26 < 30)
    str x1, [x0, #WINDOW_H]
    
    // Set default title
    ldr x1, =window_default_title
    str x1, [x0, #WINDOW_TITLE]
    
    ret

// ============================================================
// render_window - Main window rendering
//
// Draws:
//   1. Border (top, bottom, left, right)
//   2. Tab bar
//   3. App content (by calling app's render function)
//
// Input:
//   x0 = window pointer
// ============================================================

render_window:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    str x25, [sp, #-16]!
    
    mov x19, x0              // x19 = window pointer
    
    // Load window dimensions
    ldr x20, [x19, #WINDOW_X]    // x20 = x
    ldr x21, [x19, #WINDOW_Y]    // x21 = y
    ldr x22, [x19, #WINDOW_W]     // x22 = width
    ldr x23, [x19, #WINDOW_H]     // x23 = height
    
    // ========================================
    // Step 1: Draw window border
    // ========================================
    
    // Top border (y, x to x+width)
    mov x24, #0
top_border_loop:
    cmp x24, x22
    bge top_border_done
    
    add x0, x20, x24
    mov x1, x21
    mov w2, #'-'
    bl draw_char
    
    add x24, x24, #1
    b top_border_loop
top_border_done:
    
    // Bottom border
    add x24, x21, x23
    sub x24, x24, #1        // y_bottom = y + height - 1
    
    mov x0, #0
bottom_border_loop:
    cmp x0, x22
    bge bottom_border_done
    
    // x0 = x position, x1 = y position, w2 = char
    add x0, x20, x0         // x = x_start + i
    mov x1, x24              // y = y_bottom
    mov w2, #'-'             // char = '-'
    bl draw_char
    
    add x0, x0, #1
    b bottom_border_loop
bottom_border_done:
    
    // Left border (y+1 to y+height-1)
    mov x24, #1
left_border_loop:
    cmp x24, x23
    bge left_border_done
    
    mov x0, x20
    add x1, x21, x24
    mov w2, #'|'
    bl draw_char
    
    add x24, x24, #1
    b left_border_loop
left_border_done:
    
    // Right border
    add x24, x20, x22
    sub x24, x24, #1        // x_right = x + width - 1
    
    mov x25, #1             // loop counter (start at 1)
right_border_loop:
    cmp x25, x23
    bge right_border_done
    
    // x0 = x position, x1 = y position, w2 = char
    mov x0, x24              // x = x_right
    add x1, x21, x25         // y = y_start + counter
    mov w2, #'|'             // char = '|'
    bl draw_char
    
    add x25, x25, #1
    b right_border_loop
right_border_done:
    
    // ========================================
    // Step 2: Draw tab bar
    // ========================================
    
    mov x0, x19              // x0 = window pointer
    ldr x1, [x19, #WINDOW_APP_ID]  // x1 = active app ID
    bl render_tabs
    
    // ========================================
    // Step 3: Call app's render function
    // ========================================
    
    // Get current app ID
    ldr x0, [x19, #WINDOW_APP_ID]
    
    // Get render function
    bl app_get_render_fn
    
    // If function exists, call it
    // x0 still contains the function pointer from app_get_render_fn
    cbz x0, skip_app_render
    
    // Save function pointer before overwriting x0
    mov x2, x0              // x2 = function pointer
    mov x0, x19             // x0 = window pointer
    mov x1, #1              // x1 = active flag (1 = active)
    blr x2                  // call the function
    
skip_app_render:
    
    // ========================================
    // Step 4: Draw status bar at bottom
    // ========================================
    
    // Bottom divider line
    add x24, x21, x23
    sub x24, x24, #2        // second-to-last row
    
    mov x0, #1
status_divider_loop:
    cmp x0, x22
    bge status_divider_done
    
    // x0 = x position, x1 = y position, w2 = char
    add x0, x20, x0         // x = x_start + i
    mov x1, x24              // y = divider_y
    mov w2, #'-'             // char = '-'
    bl draw_char
    
    add x0, x0, #1
    b status_divider_loop
status_divider_done:
    
    // Status text: x0 = x, x1 = y, x2 = string
    adrp x2, status_text
    add x2, x2, :lo12:status_text
    
    add x0, x20, #1         // x = x_start + 1
    add x1, x21, x23
    sub x1, x1, #1          // y = y + height - 1
    bl draw_text
    
    // ========================================
    // Cleanup and return
    // ========================================
    
    ldr x25, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.section .data

window_default_title:
    .asciz "AWM v1.0"

status_text:
    .asciz "[TAB] Switch App  [Q] Quit  [WASD] Navigate"
