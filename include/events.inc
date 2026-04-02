// ============================================================
// events.inc - Event codes
//
// Events are the internal representation of user input.
// They abstract away the actual key codes and allow
// the UI code to work with semantic events.
// ============================================================

.equ EVENT_NONE,     0     // No event (no key pressed)
.equ EVENT_QUIT,     1     // Quit application
.equ EVENT_TAB,      2     // Tab key pressed (switch app)
.equ EVENT_UP,       3     // Navigate up
.equ EVENT_DOWN,     4     // Navigate down
.equ EVENT_LEFT,     5     // Navigate left
.equ EVENT_RIGHT,    6     // Navigate right
.equ EVENT_ENTER,    7     // Enter/select key
.equ EVENT_BACKSPACE,8     // Backspace key
