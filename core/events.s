// ============================================================
// events.s - Event translation
//
// Converts keyboard input (ASCII codes) into semantic events
// that the UI can understand.
//
// Input flow:
//   input_poll() → event_translate() → main event handler
//
// Supported keys:
//   q      → EVENT_QUIT
//   TAB    → EVENT_TAB (switch app)
//   w/W    → EVENT_UP
//   s/S    → EVENT_DOWN
//   a/A    → EVENT_LEFT
//   d/D    → EVENT_RIGHT
//   Enter  → EVENT_ENTER
//   Del    → EVENT_BACKSPACE
// ============================================================

.include "common.inc"

.section .text
.global event_translate

// ============================================================
// event_translate - Convert ASCII to event code
//
// Input:
//   x0 = ASCII character code
//
// Output:
//   x0 = Event code (EVENT_NONE if no match)
// ============================================================

event_translate:
    // No input = no event
    cbz x0, no_event
    
    // ========================================
    // Check for TAB key
    // ========================================
    cmp w0, #KEY_TAB
    beq event_tab
    
    // ========================================
    // Check for quit key
    // ========================================
    cmp w0, #'q'
    beq event_quit
    cmp w0, #'Q'
    beq event_quit
    
    // ========================================
    // Check for navigation keys
    // ========================================
    cmp w0, #'w'
    beq event_up
    cmp w0, #'W'
    beq event_up
    
    cmp w0, #'s'
    beq event_down
    cmp w0, #'S'
    beq event_down
    
    cmp w0, #'a'
    beq event_left
    cmp w0, #'A'
    beq event_left
    
    cmp w0, #'d'
    beq event_right
    cmp w0, #'D'
    beq event_right
    
    // ========================================
    // Check for enter key
    // ========================================
    cmp w0, #KEY_ENTER
    beq event_enter
    
    // ========================================
    // Check for backspace
    // ========================================
    cmp w0, #KEY_BACKSPACE
    beq event_backspace
    
    // No matching key found
    b no_event

// ============================================================
// Event return handlers
// ============================================================

no_event:
    mov x0, #EVENT_NONE
    ret

event_quit:
    mov x0, #EVENT_QUIT
    ret

event_tab:
    mov x0, #EVENT_TAB
    ret

event_up:
    mov x0, #EVENT_UP
    ret

event_down:
    mov x0, #EVENT_DOWN
    ret

event_left:
    mov x0, #EVENT_LEFT
    ret

event_right:
    mov x0, #EVENT_RIGHT
    ret

event_enter:
    mov x0, #EVENT_ENTER
    ret

event_backspace:
    mov x0, #EVENT_BACKSPACE
    ret
