// ------------------------------------------------------------
// Linux AArch64 syscalls
// ------------------------------------------------------------

.equ SYS_READ,   63
.equ SYS_WRITE,  64
.equ SYS_IOCTL,  29
.equ SYS_EXIT,   93


// Necessary for file I/O
// .equ SYS_OPENAT, 56
// .equ SYS_CLOSE,  57
// .equ SYS_LSEEK,  62
// .equ SYS_GETDENTS64, 61
