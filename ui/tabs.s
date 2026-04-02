// ============================================================
// tabs.s - Tab bar rendering (simplified)
// ============================================================

.include "common.inc"

.section .text
.global render_tabs

render_tabs:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    
    mov x19, x0          // window pointer
    mov x20, x1          // active app ID
    
    // Get window position
    ldr x21, [x19, #WINDOW_X]
    ldr x22, [x19, #WINDOW_Y]
    
    // Tab bar is at window Y + 1
    mov x23, x22
    add x23, x23, #1
    
    // Draw tab labels using draw_text
    cmp x20, #0
    bne tab2
    
    // App 0 is active - draw active tab first
    adrp x2, tab_active
    add x2, x2, :lo12:tab_active
    mov x0, x21
    add x0, x0, #1
    mov x1, x23
    bl draw_text
    
    adrp x2, tab_name_0
    add x2, x2, :lo12:tab_name_0
    mov x0, x21
    add x0, x0, #2
    mov x1, x23
    bl draw_text
    
    b tabs_end
tab2:
    cmp x20, #1
    bne tab3
    
    adrp x2, tab_active
    add x2, x2, :lo12:tab_active
    mov x0, x21
    add x0, x0, #1
    mov x1, x23
    bl draw_text
    
    adrp x2, tab_name_1
    add x2, x2, :lo12:tab_name_1
    mov x0, x21
    add x0, x0, #16
    mov x1, x23
    bl draw_text
    
    b tabs_end
tab3:
    cmp x20, #2
    bne tabs_end
    
    adrp x2, tab_active
    add x2, x2, :lo12:tab_active
    mov x0, x21
    add x0, x0, #1
    mov x1, x23
    bl draw_text
    
    adrp x2, tab_name_2
    add x2, x2, :lo12:tab_name_2
    mov x0, x21
    add x0, x0, #27
    mov x1, x23
    bl draw_text

tabs_end:
    // Draw AWM on the right
    adrp x2, awm_brand
    add x2, x2, :lo12:awm_brand
    ldr x0, [x19, #WINDOW_W]
    sub x0, x0, #8
    add x0, x21, x0
    mov x1, x23
    bl draw_text
    
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.section .data

tab_active:
    .asciz ">"

tab_name_0:
    .asciz "[Files]"

tab_name_1:
    .asciz "[Editor]"

tab_name_2:
    .asciz "[Calc]"

awm_brand:
    .asciz "[AWM]"
