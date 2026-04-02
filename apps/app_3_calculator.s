// ============================================================
// app_3_calculator.s - Simple Calculator
// ============================================================

.include "common.inc"

.section .data

app3_title:
    .asciz "Calculator"

.section .text

.global app3_render
app3_render:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    
    mov x19, x0          // window pointer
    mov x20, x1          // active flag
    
    // Get window dimensions
    ldr x1, [x19, #WINDOW_X]
    ldr x2, [x19, #WINDOW_Y]
    
    // Draw "Calculator" label
    adrp x4, app3_title
    add x4, x4, :lo12:app3_title
    
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
    
    // Draw display
    adrp x21, app3_display
    add x21, x21, :lo12:app3_display
    
    add x0, x1, #2
    add x1, x1, #1
display_loop:
    ldrb w2, [x21], #1
    cbz w2, display_done
    bl draw_char
    add x0, x0, #1
    b display_loop
display_done:
    
    // Draw keys
    adrp x21, app3_keys
    add x21, x21, :lo12:app3_keys
    
    add x0, x1, #2
    add x1, x1, #1
keys_loop:
    ldrb w2, [x21], #1
    cbz w2, keys_done
    bl draw_char
    add x0, x0, #1
    b keys_loop
keys_done:
    
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.global app3_input
app3_input:
    ret

.global app3_init
app3_init:
    adrp x1, app3_title
    add x1, x1, :lo12:app3_title
    str x1, [x0, #WINDOW_TITLE]
    ret

.global app3_destroy
app3_destroy:
    ret

.section .data

app3_display:
    .asciz "0"

app3_keys:
    .asciz "[7] [8] [9] [/]"
