// ============================================================
// keys.inc - ASCII key codes
//
// Contains ASCII codes for special keys used in the system.
// ============================================================

.equ KEY_ESCAPE,    0x1B    // Escape key
.equ KEY_TAB,       0x09    // Tab key
.equ KEY_ENTER,     0x0A    // Enter key
.equ KEY_BACKSPACE, 0x7F    // Backspace key
.equ KEY_DELETE,    0x7F    // Delete key

// Arrow keys (using escape sequences)
// These are detected by reading ESC [ A/B/C/D
.equ KEY_UP,        0x41    // Part of ESC[A sequence
.equ KEY_DOWN,      0x42    // Part of ESC[B sequence
.equ KEY_RIGHT,     0x43    // Part of ESC[C sequence
.equ KEY_LEFT,      0x44    // Part of ESC[D sequence

// ============================================================
// Control characters
// ============================================================

.equ CTRL_C,        0x03    // Ctrl+C (SIGINT)
.equ CTRL_D,        0x04    // Ctrl+D (EOF)
.equ CTRL_Q,        0x11    // Ctrl+Q (XON)
.equ CTRL_S,        0x13    // Ctrl+S (XOFF)
