.include "common.inc"

.section .text
.global render_window
.global init_window
.global init_windows

init_windows:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // cargar &window0
    adrp x0, window0
    add  x0, x0, :lo12:window0
    bl init_window

    // cargar &window1
    adrp x0, window1
    add  x0, x0, :lo12:window1
    bl init_window

    // mover window1
    mov x1, #35
    str x1, [x0, #WINDOW_X]

    ldp x29, x30, [sp], #16
    ret
// ------------------------------------------------------------
// init_window
//
// Inicializa la estructura main_window en memoria.
// Aquí definimos la posición y tamaño inicial de la ventana.
// ------------------------------------------------------------

init_window:

    // main_window.x = 10
    mov x1, #0
    str x1, [x0, #WINDOW_X]

    // main_window.y = 4
    mov x1, #0
    str x1, [x0, #WINDOW_Y]

    // main_window.width = 30
    mov x1, #30
    str x1, [x0, #WINDOW_W]

    // main_window.height = 10
    mov x1, #15
    str x1, [x0, #WINDOW_H]

    // main_window.title = "Alex Window Manager"
    ldr x1, =window_title
    str x1, [x0, #WINDOW_TITLE]

    ret



// ------------------------------------------------------------
// render_window
//
// x0 = window*
//
// Renderiza la ventana dentro del framebuffer.
//
// Dibujamos:
//   - borde superior
//   - borde inferior
//
// Después podrás agregar:
//   - bordes laterales
//   - esquinas
//   - título
// ------------------------------------------------------------

render_window:

    // --------------------------------------------------------
    // Crear stack frame
    // --------------------------------------------------------

    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Guardar registros callee-saved que vamos a usar
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    str x25, [sp, #-16]!



    // --------------------------------------------------------
    // Cargar datos de la ventana
    // --------------------------------------------------------

    mov x19, x0              // guardar puntero window*

    ldr x20, [x19, #WINDOW_X]   // x_start
    ldr x21, [x19, #WINDOW_Y]   // y_start
    ldr x22, [x19, #WINDOW_W]   // width
    ldr x24, [x19, #WINDOW_H]   // height



    // --------------------------------------------------------
    // Calcular y_bottom = y + height - 1
    // --------------------------------------------------------

    add x25, x21, x24
    sub x25, x25, #1



    // ========================================================
    // Dibujar BORDE SUPERIOR
    // ========================================================

    mov x23, #0      // contador = 0

top_loop:

    cmp x23, x22     // if contador >= width
    bge top_done

    // x = x_start + contador
    add x0, x20, x23

    // y = y_start
    mov x1, x21

    // caracter '-'
    mov w2, #'-'

    // dibujar caracter
    bl draw_char

    add x23, x23, #1
    b top_loop


top_done:

    // ========================================================
    // Dibujar BORDE INFERIOR
    // ========================================================

    mov x23, #0

bottom_loop:

    cmp x23, x22
    bge bottom_done

    // x = x_start + contador
    add x0, x20, x23

    // y = y_bottom
    mov x1, x25

    // caracter '-'
    mov w2, #'-'

    bl draw_char

    add x23, x23, #1
    b bottom_loop


bottom_done:
// ========================================================
// BORDE IZQUIERDO
// ========================================================

mov x23, #0

left_loop:

    cmp x23, x24
    bge left_done

    // x = x_start
    mov x0, x20

    // y = y_start + contador
    add x1, x21, x23

    mov w2, #'|'

    bl draw_char

    add x23, x23, #1
    b left_loop

left_done:

// ========================================================
// BORDE DERECHO
// ========================================================

mov x23, #0

right_loop:

    cmp x23, x24
    bge right_done

    // x = x_start + width - 1
    add x0, x20, x22
    sub x0, x0, #1

    // y = y_start + contador
    add x1, x21, x23

    mov w2, #'|'

    bl draw_char

    add x23, x23, #1
    b right_loop

right_done:
    // --------------------------------------------------------
    // Restaurar registros
    // --------------------------------------------------------

    ldr x25, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16

    ldp x29, x30, [sp], #16

    ret



// ------------------------------------------------------------
// Datos
// ------------------------------------------------------------

.section .data

window_title:
    .asciz "Alex Window Manager"
