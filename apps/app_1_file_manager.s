// ============================================================
// app_1_file_manager.s - File Manager App (Simplified)
// ============================================================

.include "common.inc"

.section .data

app1_title:
    .asciz "File Manager"

.section .text

.global app1_render
app1_render:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    
    mov x19, x0          // window pointer
    mov x20, x1          // active flag
    
    // Get window dimensions
    ldr x1, [x19, #WINDOW_X]
    ldr x2, [x19, #WINDOW_Y]
    
    // Draw "File Manager" text
    adrp x4, app1_title
    add x4, x4, :lo12:app1_title
    
    // Draw at content area (y+3, x+2)
    add x0, x1, #2       // x = window_x + 2
    add x1, x2, #3       // y = window_y + 3
    mov x21, x4           // x21 = string pointer
title_loop:
    ldrb w2, [x21], #1
    cbz w2, title_done
    bl draw_char
    add x0, x0, #1
    b title_loop
title_done:
    
    // Draw sample file path
    adrp x21, app1_content
    add x21, x21, :lo12:app1_content
    
    add x0, x1, #2       // x = window_x + 2
    add x1, x1, #1      // y = y + 1
content_loop:
    ldrb w2, [x21], #1
    cbz w2, content_done
    bl draw_char
    add x0, x0, #1
    b content_loop
content_done:
    
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.global app1_input
app1_input:
    ret

.global app1_init
app1_init:
    adrp x1, app1_title
    add x1, x1, :lo12:app1_title
    str x1, [x0, #WINDOW_TITLE]
    ret

.global app1_destroy
app1_destroy:
    ret

.section .data

app1_content:
    .asciz "/home/user/documents"
