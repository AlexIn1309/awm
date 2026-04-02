// ============================================================
// app_registry.s - App Registry
//
// This file contains the central registry that maps app IDs
// to their function pointers.
//
// Each app has 4 functions:
//   1. render(window*, active)  - Draw the app
//   2. input(window*, event)   - Handle keyboard input
//   3. init(window*)            - Initialize app state
//   4. destroy()                - Clean up resources
//
// Registry Layout:
//   Each app entry is 32 bytes (4 pointers * 8 bytes each)
//
//   App 0 (APP_FILE_MANAGER):
//     +0x00: app1_render
//     +0x08: app1_input
//     +0x10: app1_init
//     +0x18: app1_destroy
//
//   App 1 (APP_TEXT_EDITOR):
//     +0x20: app2_render
//     +0x28: app2_input
//     +0x30: app2_init
//     +0x38: app2_destroy
//
//   App 2 (APP_CALCULATOR):
//     +0x40: app3_render
//     +0x48: app3_input
//     +0x50: app3_init
//     +0x58: app3_destroy
// ============================================================

.section .data
.global app_registry

app_registry:

    // ========================================
    // App 0: APP_FILE_MANAGER
    // A simple file browser demonstration
    // ========================================
    .quad app1_render     // Render function
    .quad app1_input      // Input handler
    .quad app1_init      // Init function
    .quad app1_destroy   // Destroy function

    // ========================================
    // App 1: APP_TEXT_EDITOR
    // A simple text editor demonstration
    // ========================================
    .quad app2_render
    .quad app2_input
    .quad app2_init
    .quad app2_destroy

    // ========================================
    // App 2: APP_CALCULATOR
    // A simple calculator demonstration
    // ========================================
    .quad app3_render
    .quad app3_input
    .quad app3_init
    .quad app3_destroy
