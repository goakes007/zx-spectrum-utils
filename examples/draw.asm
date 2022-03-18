    DEVICE ZXSPECTRUM48                 ; Select 48k spectrum as output device
    ORG $8000                           ; Start the output to $8000 memory address
main:                                   ; Just a label - so that the savesna works

SCREEN_COLOUR   equ BgYellow + FgBlue

    include helper.asm
    include colour.asm

    SET_SCREEN_COLOUR SCREEN_COLOUR
    SET_BORDER_COLOUR SCREEN_COLOUR/8

    DRAW2 $8080, $9090
    DRAW1 120,120,140,150

    PLOT1 190,30
    PLOT1 190,31
    PLOT1 190,33

MAX             equ 190
STEP            equ 10
    ld h,160
    ld l,0
    ld d,0
    _FOR e, 0,MAX+STEP,STEP
        ld a,MAX
        sub e
        ld h,a
        DRAW2 hl, de
    _END_FOR e

.l1 jr .l1

    SAVESNA "draw.sna", main
