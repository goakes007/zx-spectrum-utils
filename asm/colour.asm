; 76543210
; FBPPPIII  =  F=Flash, B=Bright, P=Paper/Background, I=Ink/Foreground

    ifndef COLOUR_ASM
    define COLOUR_ASM
Black           equ 0x00
Blue            equ 0x01
Red             equ 0x02
Magenta         equ 0x03
Green           equ 0x04
Cyan            equ 0x05
Yellow          equ 0x06
White           equ 0x07

FgBlack         equ Black
FgBlue          equ Blue
FgRed           equ Red
FgMagenta       equ Magenta
FgGreen         equ Green
FgCyan          equ Cyan
FgYellow        equ Yellow
FgWhite         equ White

BgBlack         equ Black * 8
BgBlue          equ Blue * 8
BgRed           equ Red * 8
BgMagenta       equ Magenta * 8
BgGreen         equ Green * 8
BgCyan          equ Cyan * 8
BgYellow        equ Yellow * 8
BgWhite         equ White * 8

Bright          equ 64
Flash           equ 128
    endif