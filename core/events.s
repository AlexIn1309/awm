.include "common.inc"

.section .text
.global event_translate

// ------------------------------------------------------------
// event_translate
//
// Convierte ASCII → evento del sistema
//
// Entrada:
//   x0 = carácter ASCII
//
// Salida:
//   x0 = código de evento
// ------------------------------------------------------------

event_translate:

    // si no hay input
    cbz x0, no_event

    // q → salir
    cmp w0, #'q'
    beq event_quit

    // w → arriba
    cmp w0, #'w'
    beq event_up

    // s → abajo
    cmp w0, #'s'
    beq event_down

    // a → izquierda
    cmp w0, #'a'
    beq event_left

    // d → derecha
    cmp w0, #'d'
    beq event_right

no_event:

    mov x0, #EVENT_NONE
    ret

event_quit:

    mov x0, #EVENT_QUIT
    ret

event_up:

    mov x0, #EVENT_UP
    ret

event_down:

    mov x0, #EVENT_DOWN
    ret

event_left:

    mov x0, #EVENT_LEFT
    ret

event_right:

    mov x0, #EVENT_RIGHT
    ret
