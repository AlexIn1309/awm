// main.s - Versión 2 (Una ventana, apps intercambiables)
.include "common.inc"
.include "window.inc"
.include "apps.inc"

.global _start
_start:
    bl terminal_init
    bl init_windows      // Inicializa window0 con FILE_MANAGER
    // No necesitamos focus_set (solo una ventana)

main_loop:
    bl input_poll
    bl event_translate
    cbz x0, render
    
    cmp x0, #EVENT_QUIT
    beq exit_program
    
    // TAB cambia la aplicación
    cmp x0, #EVENT_TAB      // Necesitas definir EVENT_TAB en common.inc
    beq switch_app
    
    // Pasar evento a la app actual
    adrp x0, window0
    add x0, x0, :lo12:window0
    ldr x2, [x0, #WINDOW_APP_ID]   // app_id
    bl app_get_input_fn              // obtiene función input de esa app
    cbz x0, render                   // si no hay función, ignorar
    
    // x0 tiene la dirección de la función input
    adrp x1, window0
    add x1, x1, :lo12:window0        // window* en x1
    mov x2, x0                       // guardar función
    mov x0, x1                       // primer parámetro = window*
    // x1 ya tiene el evento? Necesitas cargar evento en x1
    blr x2                           // llamar input_handler(window*, evento)
    
render:
    bl renderer_frame
    b main_loop

switch_app:
    adrp x0, window0
    add x0, x0, :lo12:window0
    ldr x1, [x0, #WINDOW_APP_ID]
    add x1, x1, #1
    cmp x1, #APP_COUNT
    blt 1f
    mov x1, #0
1:
    str x1, [x0, #WINDOW_APP_ID]
    b render

exit_program:
    bl terminal_restore
    mov x8, #SYS_EXIT
    mov x0, #0
    svc #0
