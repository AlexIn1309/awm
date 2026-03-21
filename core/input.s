.include "common.inc"

.section .bss

// buffer donde se guarda la tecla leída
input_char:
    .skip 1


.section .text
.global input_poll


// ------------------------------------------------------------
// input_poll
//
// Lee una tecla desde stdin.
//
// Retorna:
//   x0 = código ASCII de la tecla
//        0 si no hay input
//
// Usa syscall read:
//   read(STDIN, buffer, 1)
// ------------------------------------------------------------

input_poll:

    mov x0, #0              // fd = stdin
    ldr x1, =input_char     // buffer
    mov x2, #1              // leer 1 byte
    mov x8, #SYS_READ       // syscall read
    svc #0

    // si no se leyó nada → retornar 0
    cmp x0, #0
    ble no_input

    // cargar carácter leído
    ldr x1, =input_char
    ldrb w0, [x1]

    ret

no_input:

    mov x0, #0
    ret
