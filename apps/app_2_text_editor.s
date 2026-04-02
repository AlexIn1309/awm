// ============================================================
// app_2_text_editor.s - Simple Text Editor
// ============================================================

.include "common.inc"

.section .data

app2_title:
    .asciz "Text Editor"

.section .text

.global app2_render
app2_render:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    
    mov x19, x0          // window pointer
    mov x20, x1          // active flag
    
    // Get window dimensions
    ldr x1, [x19, #WINDOW_X]
    ldr x2, [x19, #WINDOW_Y]
    
    // Draw "Text Editor" label
    adrp x4, app2_title
    add x4, x4, :lo12:app2_title
    
    add x0, x1, #2
    add x1, x2, #3
    mov x21, x4
title_loop:
    ldrb w2, [x21], #1
    cbz w2, title_done
    bl draw_char
    add x0, x0, #1
    b title_loop
title_done:
    
    // Draw sample content
    adrp x21, app2_content
    add x21, x21, :lo12:app2_content
    
    add x0, x1, #2
    add x1, x1, #1
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

.global app2_input
app2_input:
    ret

.global app2_init
app2_init:
    adrp x1, app2_title
    add x1, x1, :lo12:app2_title
    str x1, [x0, #WINDOW_TITLE]
    ret

.global app2_destroy
app2_destroy:
    ret

.section .data

app2_content:
    .asciz "Hello from Text Editor"
