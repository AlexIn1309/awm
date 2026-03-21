.include "common.inc"

.section .bss

// ------------------------------------------------------------
// Estructuras termios
// ------------------------------------------------------------

// configuración original del terminal
termios_orig:
    .skip 64

// configuración modificada
termios_raw:
    .skip 64


.section .text
.global terminal_init
.global terminal_restore


// ------------------------------------------------------------
// terminal_init
//
// Guarda configuración actual del terminal
// y desactiva canonical mode y echo.
// ------------------------------------------------------------

terminal_init:

    // ioctl(STDIN, TCGETS, &termios_orig)

    mov x0, #0              // stdin
    mov x1, #0x5401         // TCGETS
    ldr x2, =termios_orig
    mov x8, #SYS_IOCTL
    svc #0

    // copiar estructura original → raw

    ldr x3, =termios_orig
    ldr x4, =termios_raw

    mov x5, #8

copy_loop:

    ldr x6, [x3], #8
    str x6, [x4], #8

    subs x5, x5, #1
    bne copy_loop

    // desactivar ICANON y ECHO
    // flags están en c_lflag (offset aproximado 12)

    ldr x4, =termios_raw

    // VMIN = 1
    mov w6, #1
    strb w6, [x4, #23]

    // VTIME = 0
    mov w6, #0
    strb w6, [x4, #22]
    ldr w6, [x4, #12]

    mov w7, #(1 << 1)       // ICANON
    bic w6, w6, w7

    mov w7, #(1 << 3)       // ECHO
    bic w6, w6, w7

    str w6, [x4, #12]

    // aplicar configuración raw

    mov x0, #0
    mov x1, #0x5402         // TCSETS
    ldr x2, =termios_raw
    mov x8, #SYS_IOCTL
    svc #0

    ret


// ------------------------------------------------------------
// terminal_restore
//
// Restaura configuración original del terminal.
// ------------------------------------------------------------

terminal_restore:

    mov x0, #0
    mov x1, #0x5402
    ldr x2, =termios_orig
    mov x8, #SYS_IOCTL
    svc #0

    ret
