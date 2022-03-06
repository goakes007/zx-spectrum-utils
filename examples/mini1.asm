; This section is for either running from the command line or in visual studio
        SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    IFDEF CMDLINE
        DEVICE ZXSPECTRUM48
        DISPLAY "Running from Command Line"
NEX     equ 0
        IFNDEF DEBUG
            define DEBUG FALSE
        ENDIF
    ELSE
        DEVICE ZXSPECTRUMNEXT
        DISPLAY "Running In Visual Studio"
NEX     equ 1
        ORG 0x4000
        defs 0x6000 - $    ; move after screen area
screen_top: defb    0   ; WPMEMx
        DEFINE DO_NOT_USE_COLOR True
        defs 0x8000 - $
    ENDIF





    org $8000
main:
    include print_letters.asm

    SET_SCREEN_COLOR BgBlue+FgWhite
    SET_BORDER_COLOR Black
  
    _FOR h, 3, 23, 2
        _FOR l, 2, 30, 2
            PRINT_8x8_GRAPHIC hl, g_coin_8x8, BgBlue+FgYellow
        _END_FOR l
    _END_FOR h

    COOL_PRINT title
    COOL_PRINT top
    COOL_PRINT bottom
    COOL_PRINT left
    COOL_PRINT right
    COOL_PRINT obs1
    COOL_PRINT obs2
    COOL_PRINT obs3
    COOL_PRINT obs4
    COOL_PRINT guy


.loop    jr .loop

title       dz pRat,0,0,pInk,Yellow,pPaper,Blue,pBright,pBold,"MINI",pNotBold," Coins xxx Time xxx Best xxx"
top         dz pRat,0,1,pMemory,memory_cap_a_low,memory_cap_a_high,pColour,BgYellow+FgRed,"A",pRepeat,31
bottom      dz pAt,0,23,"A",pRepeat,31
left        dz pAt,0,1,pIncx,0,pIncy,1,"A",pRepeat,22
right       dz pAt,31,1,"A",pRepeat,22

obs1        dz pAt,5,6,pIncx,1,pIncy,0,"A",pRepeat,20
obs2        dz pAt,5,18,"A",pRepeat,20
obs3        dz pAt,25,7,pIncx,0,pIncy,1,"A",pRepeat,3
obs4        dz pAt,5,14,"A",pRepeat,3
guy         dz pRat,15,12,pMemory,memory_cap_a_low,memory_cap_a_high,pColour,FgYellow+BgBlue,"C"


; Get the memory location of Graphic, then calculate the high and low bytes for it
memory_cap_a        equ g_wall_8x8-('A'*8)  ; given where the graphic is located (g_wall_8x8), take away 'A'*8, so that we can reference it via A
memory_cap_a_high   equ memory_cap_a/256    ; get the high byte location of graphics
memory_cap_a_low    equ memory_cap_a%256    ; get the low byte location of graphics

g_wall_8x8:         ; A
    dg 11-111-1
    dg --------
    dg -111-111
    dg --------
    dg 11-111-1
    dg --------
    dg -111-111
    dg --------
g_coin_8x8:         ; B
    dg --111---
    dg -1---1--
    dg 1--1--1-
    dg 1--1--1-
    dg 1--1--1-
    dg -1---1--
    dg --111---
    dg --------
g_guy_8x8:         ; C
    dg -11111--
    dg 1-111-1-
    dg ---1----
    dg 1111111-
    dg ---1----
    dg --1-1---
    dg 11---11-
    dg --------





    IF NEX == 0
        SAVESNA "mini1.sna", main

    ELSE
; Stack: this area is reserved for the stack
STACK_SIZE: equ 100    ; in words

; Reserve stack space
        defw 0  ; WPMEM, 2
stack_bottom:
        defs    STACK_SIZE*2, 0
stack_top:
        defw 0  ; WPMEM, 2

        SAVENEX OPEN "examples/mini1.nex", main, stack_top
        SAVENEX CORE 2, 0, 0        ; Next core 2.0.0 required as minimum
        SAVENEX CFG 7   ; Border color
        SAVENEX AUTO
        SAVENEX CLOSE
    ENDIF
