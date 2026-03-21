.include "common.inc"

.global _start

// ------------------------------------------------------------
// Entry point
// ------------------------------------------------------------

_start:

    // activar raw mode del terminal
    bl terminal_init

    // inicializar ventana principal
    bl init_windows

// ------------------------------------------------------------
// Main loop
// ------------------------------------------------------------

main_loop:

    // leer teclado
    bl input_poll

    // traducir ASCII → evento
    bl event_translate

    // si no hay evento
    cbz x0, render

    // manejar evento QUIT
    cmp x0, #EVENT_QUIT
    beq exit_program

render:

    bl renderer_frame

    b main_loop


// ------------------------------------------------------------
// Exit
// ------------------------------------------------------------

exit_program:

    // restaurar terminal
    bl terminal_restore

    mov x8, #SYS_EXIT
    mov x0, #0
    svc #0


// ------------------------------------------------------------
// Variables globales
// ------------------------------------------------------------

.section .bss

.global window0
window0:
    .skip WINDOW_SIZE

.global window1
window1:
    .skip WINDOW_SIZE



.section .data

.global windows
windows:
    .quad window0
    .quad window1

.global windows_count
windows_count:
    .quad 2

msg:
    .asciz "Alex Window Manager"
