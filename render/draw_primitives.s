.include "common.inc"

.section .text
.global draw_char

draw_char:
    // x0 = x
    // x1 = y
    // w2 = char

    mov x3, #FB_WIDTH
    mul x4, x1, x3
    add x4, x4, x0

    ldr x5, =framebuffer
    add x5, x5, x4

    strb w2, [x5]

    ret


.global draw_text

draw_text:

    // crear stack frame
    stp x29, x30, [sp, -16]!
    mov x29, sp

    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!

    // guardar argumentos
    mov x19, x0
    mov x20, x1
    mov x21, x2

loop_text:

    ldrb w3, [x21], #1
    cbz w3, end_text

    mov x0, x19
    mov x1, x20
    mov w2, w3

    bl draw_char

    add x19, x19, #1
    b loop_text

end_text:

    // restaurar registros
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16

    ldp x29, x30, [sp], #16

    ret
