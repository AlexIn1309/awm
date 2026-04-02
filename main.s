// ============================================================
// main.s - AWM (Assembly Window Manager) Entry Point
//
// A simple single-window TUI window manager with tab-based
// app switching. Written in ARM64 assembly for Linux.
//
// Architecture:
//   +-----------------+
//   |    main.s       |  Entry point and main loop
//   +-----------------+
//          |
//   +------+------+------+
//   |      |      |       |
// +-+---+ +-+---+ +-+---+
// |core| |render| | apps |
// +---+   +---+   +---+
//
// Controls:
//   TAB   - Switch between apps
//   Q     - Quit program
//   WASD  - Navigation (future use by apps)
// ============================================================

.include "common.inc"

.section .text
.global _start

// ============================================================
// _start - Program entry point
//
// Initializes the terminal, sets up windows, and enters
// the main event loop.
// ============================================================

_start:
    // Step 1: Save terminal state and enable raw mode
    bl terminal_init
    
    // Step 2: Initialize window system
    bl init_windows
    
    // Step 3: Enter main event loop
    b main_loop

// ============================================================
// main_loop - Main event processing loop
//
// Flow:
//   1. Poll for keyboard input
//   2. Translate input to event
//   3. Process event (quit, tab, or pass to app)
//   4. Render frame
//   5. Repeat
// ============================================================

main_loop:
    // ---- Step 1: Read keyboard input ----
    // input_poll returns ASCII code in x0 (0 if no input)
    bl input_poll
    
    // ---- Step 2: Translate to event ----
    // event_translate converts ASCII to semantic events
    bl event_translate
    
    // If no event, skip to render
    cmp x0, #EVENT_NONE
    beq render_frame
    
    // ---- Step 3: Process event ----
    
    // Check for QUIT event (user pressed 'q')
    cmp x0, #EVENT_QUIT
    beq exit_program
    
    // Check for TAB event (switch apps)
    cmp x0, #EVENT_TAB
    beq switch_app
    
    // ---- Pass event to current app ----
    // If not QUIT or TAB, pass the event to the
    // currently active app for handling.
    
    // Get window pointer
    adrp x1, window0
    add x1, x1, :lo12:window0
    
    // Get current app ID
    ldr x2, [x1, #WINDOW_APP_ID]
    
    // Get app's input handler
    mov x0, x2
    bl app_get_input_fn
    
    // If handler exists, call it
    cbz x0, render_frame
    
    // Call input handler: input(window*, event)
    mov x2, x0              // x2 = function pointer
    mov x0, x1              // x0 = window*
    mov x1, x3              // x1 = event (from event_translate)
    // Note: x3 still contains the event from earlier
    blr x2
    
    // Fall through to render

// ============================================================
// render_frame - Render a complete frame
//
// Clears the framebuffer, renders all windows,
// and flushes to the terminal.
// ============================================================

render_frame:
    bl renderer_frame
    b main_loop

// ============================================================
// switch_app - Switch to the next app
//
// Cycles through apps: 0 → 1 → 2 → 0 → ...
// When switching:
//   1. Get current app ID
//   2. Increment (wrap to 0 if at end)
//   3. Update window's app ID
//   4. Call new app's init function
// ============================================================

switch_app:
    // Get window pointer
    adrp x19, window0
    add x19, x19, :lo12:window0
    
    // Get current app ID
    ldr x1, [x19, #WINDOW_APP_ID]
    
    // Increment and wrap around
    add x1, x1, #1
    cmp x1, #APP_COUNT
    blt store_new_app
    
    // Wrap to 0
    mov x1, #0
    
store_new_app:
    // Store new app ID
    str x1, [x19, #WINDOW_APP_ID]
    
    // Call new app's init function
    // x1 still has the new app ID
    mov x0, x1              // App ID
    bl app_get_init_fn
    
    // If init function exists, call it
    cbz x0, switch_done
    
    // Save init function pointer before setting x0 to window
    mov x2, x0              // x2 = init function pointer
    mov x0, x19             // x0 = window pointer
    blr x2                   // Call init(window*)
    
switch_done:
    // Redraw with new app
    b render_frame

// ============================================================
// exit_program - Clean up and exit
//
// Restores terminal state and exits with code 0.
// ============================================================

exit_program:
    // Restore terminal to original state
    bl terminal_restore
    
    // Exit with syscall
    mov x8, #SYS_EXIT
    mov x0, #0
    svc #0

// ============================================================
// Data section - Window storage
// ============================================================

.section .bss
.align 8

// Main window structure
.global window0
window0:
    .skip WINDOW_SIZE

// ============================================================
// Registry reference
// ============================================================

.section .data
.global windows
windows:
    .quad window0

.global windows_count
windows_count:
    .quad 1
