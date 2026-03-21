// ------------------------------------------------------------
// framebuffer.s
//
// Implementa el framebuffer del sistema.
//
// El framebuffer es un buffer de memoria donde se dibuja
// la pantalla antes de enviarla al terminal.
//
// Flujo:
//
// draw_char / draw_text
//        ↓
//   framebuffer (memoria)
//        ↓
//     fb_flush
//        ↓
//      terminal
//
// ------------------------------------------------------------

.include "common.inc"


// ------------------------------------------------------------
// Framebuffer memory
//
// Sección .bss = memoria sin inicializar.
// El sistema operativo la llena con ceros al iniciar.
//
// framebuffer tendrá FB_SIZE bytes.
//
// Ejemplo:
// FB_WIDTH  = 80
// FB_HEIGHT = 25
// FB_SIZE   = 2000
// ------------------------------------------------------------

.section .bss

.global framebuffer

framebuffer:
    .skip FB_SIZE


// ------------------------------------------------------------
// Código
// ------------------------------------------------------------

.section .text

.global fb_clear
.global fb_flush


// ------------------------------------------------------------
// fb_clear
//
// Llena el framebuffer con espacios.
//
// Equivalente a:
//
// memset(framebuffer, ' ', FB_SIZE)
//
// ------------------------------------------------------------

fb_clear:

    ldr x0, =framebuffer   // x0 = puntero al framebuffer
    mov x1, #FB_SIZE       // x1 = tamaño
    mov x2, #' '           // x2 = caracter espacio

clear_loop:

    strb w2, [x0], #1      // escribir byte y avanzar puntero

    subs x1, x1, #1        // contador--
    bne clear_loop         // repetir hasta terminar

    ret


// ------------------------------------------------------------
// fb_flush
//
// Envía el framebuffer al terminal usando syscall write.
//
// write(STDOUT, framebuffer, FB_SIZE)
//
// x0 = file descriptor (1 = stdout)
// x1 = buffer
// x2 = tamaño
//
// ------------------------------------------------------------

fb_flush:

    mov x0, #1             // STDOUT
    ldr x1, =framebuffer   // buffer
    mov x2, #FB_SIZE       // tamaño

    mov x8, #SYS_WRITE     // syscall write
    svc #0

    ret
