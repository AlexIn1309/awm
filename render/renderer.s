.include "common.inc"

.section .text
.global renderer_frame

// ------------------------------------------------------------
// renderer_frame
//
// Renderiza un frame completo del sistema.
//
// Flujo:
//
//   clear framebuffer
//   render windows
//   flush framebuffer
//
// ------------------------------------------------------------

renderer_frame:

    // stack frame
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    // limpiar framebuffer
    bl fb_clear

    // x19 = windows[]
    ldr x19, =windows

    // x20 = índice
    mov x20, #0

render_loop:

    // cargar número de ventanas
    ldr x21, =windows_count
    ldr x21, [x21]

    cmp x20, x21
    bge render_done

    // cargar puntero a window
    ldr x0, [x19, x20, lsl #3]

    bl render_window

    add x20, x20, #1
    b render_loop

render_done:

    // enviar framebuffer a terminal
    bl fb_flush

    // restaurar registros
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    ret
