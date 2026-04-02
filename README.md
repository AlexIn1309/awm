# AWM - Assembly Window Manager

A single-window TUI (Text User Interface) window manager written in ARM64 assembly for Linux. Designed for educational purposes to demonstrate low-level systems programming.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Architecture Overview](#architecture-overview)
3. [Code Flow](#code-flow)
4. [Project Structure](#project-structure)
5. [Key Concepts](#key-concepts)
6. [Adding New Apps](#adding-new-apps)
7. [Syscall Reference](#syscall-reference)

---

## Quick Start

```bash
# Build the project
./build.sh

# Run (use a real terminal!)
./awm

# Controls
TAB   - Switch between apps
Q     - Quit program
WASD  - Navigation (future use)
```

---

## Architecture Overview

```
+------------------------------------------------------------------+
|                         AWM Architecture                         |
+------------------------------------------------------------------+

    +--------------+
    |   main.s    |  Entry point, main loop
    +------+-------+
           |
           v
+------------------------------------------------------------------+
|                        EVENT LOOP                                 |
|                                                                    |
|   +------------+    +-------------+    +--------------------+     |
|   | input_poll |--> |event_trans |--> | Process Event     |     |
|   |            |    |  late      |    | (Quit/Tab/App)    |     |
|   +------------+    +-------------+    +--------+-----------+     |
|                                                   |              |
|                                                   v              |
|                                          +--------------------+   |
|                                          | renderer_frame    |   |
|                                          |                   |   |
|                                          | 1. fb_clear      |   |
|                                          | 2. render_window |   |
|                                          | 3. fb_flush      |   |
|                                          +-------------------+   |
+------------------------------------------------------------------+
           |
           v
+------------------------------------------------------------------+
|                       RENDERING PIPELINE                          |
|                                                                    |
|   +----------------+                                              |
|   |  fb_clear()    |  Fill framebuffer with spaces              |
|   +-------+--------+                                              |
|           |                                                        |
|           v                                                        |
|   +----------------+                                              |
|   | render_window  |  Draw window border + tabs                   |
|   |                |                                              |
|   |  +----------+  |                                              |
|   |  |render_tabs|  |  Draw tab bar                              |
|   |  +----------+  |                                              |
|   |  +----------+  |                                              |
|   |  | app_render|-->  Call active app's render function        |
|   |  +----------+  |                                              |
|   +-------+--------+                                              |
|           |                                                        |
|           v                                                        |
|   +----------------+                                              |
|   |  fb_flush()    |  Write framebuffer to terminal              |
|   +----------------+                                              |
+------------------------------------------------------------------+
```

---

## Code Flow

### 1. Program Startup (`main.s:_start`)

```asm
_start:
    bl terminal_init      // Enable raw mode (no buffering, no echo)
    bl init_windows      // Initialize window structure
    b main_loop          // Enter event loop
```

### 2. Main Event Loop (`main.s:main_loop`)

```asm
main_loop:
    bl input_poll        // Read keyboard (returns ASCII or 0)
    bl event_translate  // Convert ASCII to event code
    cmp x0, EVENT_NONE
    beq render_frame
    
    cmp x0, EVENT_QUIT  // 'q' pressed?
    beq exit_program
    
    cmp x0, EVENT_TAB   // TAB pressed?
    beq switch_app
    
    // Pass event to current app's input handler
    bl app_get_input_fn
    blr x0              // Call app_input(window*, event)
    
    b render_frame
```

### 3. TAB Switching (`main.s:switch_app`)

```asm
switch_app:
    // Get current app_id from window0
    ldr x1, [x0, #WINDOW_APP_ID]
    
    // Increment and wrap: 0->1->2->0
    add x1, x1, #1
    cmp x1, #APP_COUNT
    blt store_new
    mov x1, #0          // Wrap to 0
store_new:
    str x1, [x0, #WINDOW_APP_ID]
    
    // Call new app's init function
    bl app_get_init_fn
    blr x0
    
    b render_frame
```

### 4. Frame Rendering (`render/renderer.s:renderer_frame`)

```asm
renderer_frame:
    bl fb_clear          // Fill with spaces
    bl render_window     // Draw window + tabs + app
    bl fb_flush          // Output to terminal
    ret
```

### 5. Window Rendering (`ui/window.s:render_window`)

```asm
render_window:
    // Step 1: Draw border (top, bottom, left, right)
    draw_top_border()
    draw_bottom_border()
    draw_left_border()
    draw_right_border()
    
    // Step 2: Draw tab bar
    ldr x1, [x19, #WINDOW_APP_ID]
    bl render_tabs
    
    // Step 3: Call app's render function
    bl app_get_render_fn
    mov x2, x0          // Save function pointer
    mov x0, x19         // x0 = window*
    mov x1, #1          // x1 = active flag
    blr x2              // Call app_render()
    
    // Step 4: Draw status bar
    draw_status_bar()
```

---

## Project Structure

```
awm/
|
+-- include/              # Header files with constants and macros
|   |-- common.inc        # Master include (includes all others)
|   |-- constants.inc     # Framebuffer size, termios constants
|   |-- apps.inc         # App IDs (APP_FILE_MANAGER, etc.)
|   |-- app.inc          # App registry structure
|   |-- events.inc       # Event codes (EVENT_QUIT, EVENT_TAB, etc.)
|   |-- keys.inc         # ASCII key codes
|   |-- syscalls.inc     # Linux syscall numbers
|   +-- window.inc       # Window structure offsets
|
+-- core/                 # Core system functionality
|   |-- terminal.s        # Raw terminal mode setup/restore
|   |-- input.s          # Keyboard polling (read stdin)
|   |-- events.s         # ASCII -> Event translation
|   |-- app_manager.s    # Get app functions from registry
|   +-- app_registry.s  # Table mapping app IDs to functions
|
+-- render/               # Rendering system
|   |-- framebuffer.s    # Framebuffer memory + clear/flush
|   |-- draw_primitives.s # draw_char(), draw_text()
|   +-- renderer.s       # Main render loop
|
+-- ui/                   # Window management
|   |-- window.s         # Window rendering (border, tabs, status)
|   +-- tabs.s          # Tab bar rendering
|
+-- apps/                 # Application modules
|   |-- app_1_file_manager.s  # App 0
|   |-- app_2_text_editor.s  # App 1
|   +-- app_3_calculator.s    # App 2
|
+-- main.s               # Entry point
+-- build.sh            # Build script
+-- README.md          # This file
```

---

## Key Concepts

### 1. Framebuffer

A memory buffer (98x30 = 2940 bytes) where we draw the screen before outputting it.

```asm
// draw_char(x, y, char) - writes char at (x,y) in framebuffer
draw_char:
    mul x4, x1, #FB_WIDTH   // offset = y * width
    add x4, x4, x0          // offset += x
    add x5, x4, framebuffer // address = base + offset
    strb w2, [x5]            // write byte
```

### 2. Window Structure

```asm
// Window structure (48 bytes total)
WINDOW_X:       equ 0   // x position (8 bytes)
WINDOW_Y:       equ 8   // y position (8 bytes)
WINDOW_W:      equ 16  // width (8 bytes)
WINDOW_H:      equ 24  // height (8 bytes)
WINDOW_TITLE:  equ 32  // title string pointer (8 bytes)
WINDOW_APP_ID: equ 40  // current app ID (8 bytes)
WINDOW_SIZE:   equ 48  // total size
```

### 3. App Registry

Each app has 4 functions. They're stored in a table:

```asm
// app_registry.s
app_registry:
    // App 0: File Manager
    .quad app1_render    // Render function
    .quad app1_input     // Input handler
    .quad app1_init      // Init function
    .quad app1_destroy   // Cleanup function
    
    // App 1: Text Editor
    .quad app2_render
    .quad app2_input
    .quad app2_init
    .quad app2_destroy
    
    // App 2: Calculator
    .quad app3_render
    .quad app3_input
    .quad app3_init
    .quad app3_destroy
```

### 4. Event System

Events abstract keyboard input:

```asm
// Events (from events.inc)
EVENT_NONE:    equ 0   // No key pressed
EVENT_QUIT:    equ 1   // 'q' pressed
EVENT_TAB:     equ 2   // TAB pressed
EVENT_UP:      equ 3   // 'w' pressed
EVENT_DOWN:    equ 4   // 's' pressed
EVENT_LEFT:    equ 5   // 'a' pressed
EVENT_RIGHT:   equ 6   // 'd' pressed
```

### 5. Raw Terminal Mode

Normal terminal mode is "cooked" - it waits for Enter before giving you input. Raw mode gives us each keystroke immediately.

```asm
// From terminal.s
terminal_init:
    // Get current terminal settings
    mov x0, #0              // stdin
    mov x1, #TCGETS
    ldr x2, =termios_orig
    mov x8, #SYS_IOCTL
    svc #0
    
    // Copy to raw, modify
    // Clear ICANON (no line buffering)
    // Clear ECHO (no echo)
    // Set VMIN=1, VTIME=0 (immediate read)
    
    // Apply raw settings
    mov x0, #0
    mov x1, #TCSETS
    ldr x2, =termios_raw
    mov x8, #SYS_IOCTL
    svc #0
```

---

## Adding New Apps

### Step 1: Define App ID

Edit `include/apps.inc`:

```asm
.equ APP_FILE_MANAGER, 0
.equ APP_TEXT_EDITOR,  1
.equ APP_CALCULATOR,   2
.equ APP_COUNT,        3    // UPDATE THIS!
```

### Step 2: Create App File

Create `apps/app_4_my_app.s`:

```asm
.include "common.inc"

app4_title:
    .asciz "My App"

.section .text

.global app4_render
app4_render:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    
    mov x19, x0
    mov x20, x1
    
    ldr x1, [x19, #WINDOW_X]
    ldr x2, [x19, #WINDOW_Y]
    
    adrp x4, app4_content
    add x4, x4, :lo12:app4_content
    
    add x0, x1, #2
    add x1, x2, #3
    mov x21, x4
draw_loop:
    ldrb w2, [x21], #1
    cbz w2, draw_done
    bl draw_char
    add x0, x0, #1
    b draw_loop
draw_done:
    
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.global app4_input
app4_input:
    ret

.global app4_init
app4_init:
    adrp x1, app4_title
    add x1, x1, :lo12:app4_title
    str x1, [x0, #WINDOW_TITLE]
    ret

.global app4_destroy
app4_destroy:
    ret

.section .data
app4_content:
    .asciz "Hello from my app!"
```

### Step 3: Register in Registry

Edit `core/app_registry.s`:

```asm
    // App 2: Calculator
    .quad app3_render
    .quad app3_input
    .quad app3_init
    .quad app3_destroy

    // App 3: My App (NEW)
    .quad app4_render
    .quad app4_input
    .quad app4_init
    .quad app4_destroy
```

### Step 4: Add Tab Name

Edit `ui/tabs.s` data section:

```asm
tab_name_2:
    .asciz "[Calc]"

tab_name_3:              // NEW
    .asciz "[My App]"
```

---

## Syscall Reference

### Linux Syscalls Used

| Syscall    | Number | Purpose                              |
|------------|--------|--------------------------------------|
| SYS_READ   | 63     | Read from file descriptor (stdin)     |
| SYS_WRITE  | 64     | Write to file descriptor (stdout)     |
| SYS_IOCTL  | 29     | Terminal control (get/set modes)      |
| SYS_EXIT   | 93     | Terminate program                    |

### Common Syscalls (for future expansion)

| Syscall       | Number | Purpose                   |
|---------------|--------|---------------------------|
| SYS_OPENAT    | 56     | Open file                 |
| SYS_CLOSE     | 57     | Close file                |
| SYS_LSEEK     | 62     | Seek in file             |
| SYS_GETDENTS64| 61     | Read directory entries   |

### Syscall Invocation

```asm
// syscall number goes in x8
// Arguments: x0, x1, x2, ...

// Example: write to stdout
mov x0, #1              // fd = stdout
ldr x1, =message        // buffer
mov x2, #13            // length
mov x8, #64            // SYS_WRITE
svc #0                 // invoke syscall

// Example: read from stdin
mov x0, #0              // fd = stdin
ldr x1, =buffer        // buffer
mov x2, #1             // count
mov x8, #63            // SYS_READ
svc #0                 // x0 = bytes read
```

---

## Memory Layout

```
+------------------+ 0x400000 (text segment)
|    .text         |  Code (instructions)
+------------------+
|    .rodata       |  Read-only data (strings, constants)
+------------------+
|    .data         |  Initialized data
+------------------+ 0x411300 (bss segment)
|    .bss          |  Uninitialized data (framebuffer, windows)
+------------------+
|    Heap          |  (future: dynamic allocation)
|         |
|         v
|    Stack         |  Grows downward
+------------------+ 0xffffffffffff
```

---

## Debugging Tips

### With GDB

```bash
gdb ./awm

# Set breakpoint
break renderer_frame

# Run
run

# Step through
next    # Step over function calls
step    # Step into function calls

# Check registers
info registers

# Check memory
x/8gx 0x411300   # Examine 8 quadwords at framebuffer
```

### With strace

```bash
strace ./awm 2>&1 | head -50
```

---

## File Descriptions

| File | Lines | Description |
|------|-------|-------------|
| main.s | ~200 | Entry point, main loop, event handling |
| core/terminal.s | ~100 | Raw mode setup/restore |
| core/input.s | ~50 | Keyboard polling |
| core/events.s | ~70 | ASCII -> Event translation |
| core/app_manager.s | ~100 | Get functions from registry |
| core/app_registry.s | ~65 | Registry table |
| render/framebuffer.s | ~120 | Buffer management |
| render/draw_primitives.s | ~60 | Basic drawing |
| render/renderer.s | ~65 | Render orchestration |
| ui/window.s | ~250 | Window rendering |
| ui/tabs.s | ~100 | Tab bar rendering |
| apps/app_*.s | ~80 each | App implementations |

---

## Version History

- **v1.0**: Initial project structure
- **v2.0**: Single window with tab switching, refactored architecture
