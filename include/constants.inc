.equ FB_WIDTH, 80
.equ FB_HEIGHT, 25
.equ FB_SIZE, 2000
// ============================================================
// Termios constants for raw mode
// ============================================================

// ioctl requests
.equ TCGETS, 0x5401
.equ TCSETS, 0x5402
.equ TCSETSW, 0x5403

// termios structure offsets (in bytes)
.equ c_iflag, 0
.equ c_oflag, 4
.equ c_cflag, 8
.equ c_lflag, 12
.equ c_cc, 16

// c_cc indices
.equ VINTR, 0
.equ VQUIT, 1
.equ VERASE, 2
.equ VKILL, 3
.equ VEOF, 4
.equ VTIME, 5
.equ VMIN, 6
.equ VSWTC, 7
.equ VSTART, 8
.equ VSTOP, 9
.equ VSUSP, 10
.equ VEOL, 11
.equ VREPRINT, 12
.equ VDISCARD, 13
.equ VWERASE, 14
.equ VLNEXT, 15
.equ VEOL2, 16

// c_lflag bits
.equ ICANON, 1 << 1    // 2
.equ ECHO,   1 << 3    // 8
.equ ISIG,   1 << 4    // 16
.equ IEXTEN, 1 << 5    // 32

// c_iflag bits (para modo raw completo)
.equ IGNBRK, 1 << 0
.equ BRKINT, 1 << 1
.equ IGNPAR, 1 << 2
.equ PARMRK, 1 << 3
.equ INPCK,  1 << 4
.equ ISTRIP, 1 << 5
.equ INLCR,  1 << 6
.equ IGNCR,  1 << 7
.equ ICRNL,  1 << 8
.equ IXON,   1 << 9
.equ IXOFF,  1 << 10

// c_oflag bits
.equ OPOST,  1 << 0
