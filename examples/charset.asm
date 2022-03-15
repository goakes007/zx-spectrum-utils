; This section is for either running from the command line or in visual studio
; Recommend ignore first 20 lines as it just for visual studio and debugging
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
        DEFINE DO_NOT_USE_COLOUR True
        defs 0x8000 - $
    ENDIF


; Bright Colours
SCREEN_COLOUR   equ BgYellow + FgBlack
GRAPHIC_BLACK   equ FgBlack + BgBlack
GRAPHIC_WHITE   equ FgWhite + BgWhite

; Dark Colours
;SCREEN_COLOUR   equ BgBlue + FgYellow
;GRAPHIC_BLACK   equ FgWhite + BgWhite
;GRAPHIC_WHITE   equ FgBlack + BgBlack


CHARSET_LEN     equ 8*(128-32)

    org $8000
main:
    include print_letters.asm
    include input.asm

    ld ix, vars_memory
    call build_main_screen
    call draw_character_set

    ei
.main_loop
    halt
    IX_DEC vars.cnt
    jr nz, .main_loop
    IX_CP vars.cnt, vars.max
    call draw_big_graphic
    call draw_flashing_cursors
    GET_KEYS_PRESSED
    call move_gxy
    call move_char
    call check_other_keys
    jr .main_loop

check_other_keys
    call check_space_toggle
    call check_charset_change

    _IF_KEY 1, KEY_B
        ld b,pBold
        call perform_action
    _END_IF_NO_ELSE 1

    _IF_KEY 2, KEY_I
        ld b,pItalic
        call perform_action
    _END_IF_NO_ELSE 2

    _IF_KEY 5, KEY_Y
        ld b,pMirrorY
        call perform_action
    _END_IF_NO_ELSE 5

    _IF_KEY 6, KEY_X
        ld b,pMirrorX
        call perform_action
    _END_IF_NO_ELSE 6

    _IF_KEY 10, KEY_R
        ld b,pRotate1
        call perform_action
    _END_IF_NO_ELSE 10

    _IF_KEY 3, KEY_D
        IX_GET l,vars.char
        ld h,0
        .3 add hl,hl
        ld de,$3c00
        add hl,de
        call get_char_memory                            ; we get the memory location of the char
        ld b,8
.l1     ld a,(hl)
        ld (de),a
        inc de
        inc hl
        djnz .l1
        call redraw_screen_character        
    _END_IF_NO_ELSE 3

    ret


; Set b to action to perform
perform_action
    call get_char_memory                            ; we get the memory location of the char
    call get_screen_char_location
    COOL_AT hl, de, SCREEN_COLOUR, b
    ; copy screen char to memory
    CALC_SCREEN_LOCATION8x8 hl
    ld b,8
.l1 ld a,(hl)
    ld (de),a
    inc de
    inc h
    djnz .l1
    ret

check_charset_change
; keys4  byte 0   ;   11110111b  F7 fe    5 4 3 2 1    4
    IX_GET b, vars.cs
    ld c,0
    ld a,(keys4)
    _IF 1, a,1
        ld c,1
    _ELSE 1
        _IF 2, a,2
            ld c,2
        _ELSE 2
            _IF 3, a,4
                ld c,3
            _ELSE 3
                _IF 4, a,8
                    ld c,4
                _END_IF_NO_ELSE 4
            _END_IF 3
        _END_IF 2
    _END_IF 1

    _IF_NOT a1, c,0
        _IF_NOT a2, c,b
            IX_SET vars.cs,c
            call draw_character_set
        _END_IF_NO_ELSE a2
    _END_IF_NO_ELSE a1

    ret

check_space_toggle
    _IF_KEY r1, KEY_BACK_SPACE
        ; Set character set
        call get_char_memory
        IX_GET l,vars.gy
        ld h,0
        add hl,de
        ld c,$80
        IX_GET a,vars.gx
        cp 0
        jr z,.r1a
        ld b,a
.r1b        rr c
            djnz .r1b
.r1a    ld a,(hl)
        xor c
        ld (hl),a

        call redraw_screen_character
    _END_IF_NO_ELSE r1
    ret

redraw_screen_character
    ; Set screen character
    call get_char_memory
    call get_screen_char_location
    PRINT_8x8_GRAPHIC hl, de, SCREEN_COLOUR
    ret

get_screen_char_location
        IX_GET a,vars.char          ; Load HL with y,x screen location
        and 11100000b
        .5 rra
        add a,4
        ld h,a
        IX_GET a,vars.char
        and 00011111b
        ld l,a
        ret



move_gxy
    _IF_KEY 1, KEY_P
        IX_INC_MAX vars.gx, 8, 0
    _END_IF_NO_ELSE 1
    _IF_KEY 2, KEY_O
        IX_DEC_MIN vars.gx, 255, 7
    _END_IF_NO_ELSE 2
    _IF_KEY 3, KEY_A
        IX_INC_MAX vars.gy, 8, 0
    _END_IF_NO_ELSE 3
    _IF_KEY 4, KEY_Q
        IX_DEC_MIN vars.gy, 255, 7
    _END_IF_NO_ELSE 4
    ret


move_char
    _IF_KEY r1, KEY_8
        IX_INC_MAX vars.char, 128, 32
    _END_IF_NO_ELSE r1

    _IF_KEY r2, KEY_5
        IX_DEC_MIN vars.char, 31, 127
    _END_IF_NO_ELSE r2

    _IF_KEY r3, KEY_7
        IX_GET a,vars.char
        sub $20
        cp $20
        jr nc,.d1
        add a,$60
.d1
        IX_SET vars.char,a
    _END_IF_NO_ELSE r3

    _IF_KEY r4, KEY_6
        IX_GET a,vars.char
        add a,$20
        cp $80
        jr c,.d2
        sub $60
.d2
        IX_SET vars.char,a
    _END_IF_NO_ELSE r4

    ret


draw_big_graphic
    call get_char_memory
    ld hl,$5942
    _FOR b, 0, 8, 1
        ld a,(de)
        ld c,8
.loop_c
            add a,a
            jr nc, .blank
            ld (hl),GRAPHIC_BLACK
            jr .next
.blank
            ld (hl),GRAPHIC_WHITE
.next
            inc hl
            dec c
        jr nz, .loop_c
        ld a,l
        add a,32-8
        jr nc,.next2
        inc h
.next2
        ld l,a
        inc de
    _END_FOR b
    ret

draw_flashing_cursors
    ; flash character
    ld hl,$58A0
    ld b,128-32
.l1 ld (hl), SCREEN_COLOUR
    inc hl
    djnz .l1
    ld h,$58
    IX_GET a, vars.char
    add $80
    ld l,a
    RANDOM
    ld (hl),a

    ; flash graphic section
    IX_GET a, vars.gy
    .5 add a,a
    ld e,a
    IX_GET a, vars.gx
    add a,e
    ld e,a
    ld d,0
    ld hl,$5942
    add hl,de
    RANDOM
    ld (hl),a
    ret

build_main_screen
    SET_SCREEN_COLOUR SCREEN_COLOUR
    SET_BORDER_COLOUR SCREEN_COLOUR/8
    COOL_PRINT titleS
    COOL_PRINT charsetS
    COOL_PRINT pickS
    COOL_PRINTS screen_text_border
    COOL_PRINTS screen_text_keys
    ret
screen_text_keys        dw keys1S,keys2S,keys3S,keys4S,keys5S,keys6S,keys7S,keys8S,0
screen_text_border      dw border1S,border2S,border3S,border4S,0

get_char_memory             ; load de with char memory location
    push hl
    IX_GET a, vars.char
    sub $20
    ld l,a
    ld h,0
    .3 add hl,hl
    call get_cs_memory
    add hl,de
    ld de,hl
    pop hl
    ret

get_cs_memory
    push hl
    IX_GET a, vars.cs
    dec a
    .2 add a,a
    ld h,a
    ld l,0
    ld de, cs1
    add hl,de
    ld de,hl        ; de holds start of char set
    pop hl
    ret

draw_character_set
    ; Is character set null?
    call get_cs_memory
    ld hl,de
    ld bc, CHARSET_LEN
.l1 ld a,(de)
    cp 0
    jr nz, .already_have_cs
        inc de
        dec bc
        ld a,b
        or c
        jr nz, .l1
        ; ok, all the memory locations are zero, lets grab the system char set
        push hl
        IX_GET a, vars.cs
        _IF 1, a,4                  ; for CS 4, if empty, then BOLD it
            ld de,hl
            ld hl, $3c00+(8*32)
            ld bc, CHARSET_LEN
.l2         ld a,(hl)
            add a,a
            or (hl)
            ld (de),a
            inc de
            inc hl
            dec bc
            ld a,b
            or c
            cp 0
            jr nz, .l2
        _ELSE 1
            ld de,hl
            ld hl, $3c00+(8*32)
            ld bc, CHARSET_LEN
            ldir
        _END_IF 1
        pop hl

.already_have_cs
    ld de,hl
    _FOR h,5,8,1
        _FOR l,0,32,1
            PRINT_8x8_GRAPHIC hl, de, SCREEN_COLOUR
            .8 inc de
        _END_FOR l
    _END_FOR h

    ; Print character set number
    ld de, $3c00+(8*'0')
    IX_GET a,vars.cs
    .3 add a,a
    ld l,a
    ld h,0
    add hl,de
    ld de,hl
    PRINT_8x8_GRAPHIC $020f, de, SCREEN_COLOUR
    ret

 

    struct  vars
cs      byte    1   ; 1-4
char    byte    32  ; 32-128
gx      byte    0   ; 0-7
gy      byte    0   ; 0-7
max     byte    4   ; 0-...
cnt     byte    0   ; count down to next try the keys
    ends

vars_memory
    db  1       ; charset
    db  65      ; char
    db  3,3     ; g x,y
    db  4,4     ; max, cnt

titleS      dz pRat,3,0,pColour,SCREEN_COLOUR+Bright,pBold,pUnderscore,"Character Set Editor ",pNotItalic,pNotBold,"v0.1"
title2S     dz pRat,3,1,pColour,SCREEN_COLOUR,pMirrorX,"Character Set Editor ",pNotItalic,pNotBold,"v0.1"
charsetS    dz pRat,0,2,pColour,SCREEN_COLOUR,"Character Set: X"
pickS       dz pRat,0,4,pColour,SCREEN_COLOUR,"Pick a char (use 5678 to move)"
border1S    dz pAt,2,9,pUnderscore," ",pRepeat,7
border2S    dz pAt,9,18,pUnderscore,pLeft," ",pRepeat,7
border3S    dz pAt,10,10,pUnderscore,pDown," ",pRepeat,7
border4S    dz pAt,1,17,pUnderscore,pUp," ",pRepeat,7
keys1S      dz pRat,16,9,pColour,SCREEN_COLOUR,pBold,pUnderscore,"Keys"
keys2S      dz pRat,12,10,pColour,SCREEN_COLOUR,pBold,"  1-4 ",pNotBold,"Char set"
keys3S      dz pRat,12,11,pColour,SCREEN_COLOUR,pBold," QAOP ",pNotBold,"Movement"
keys4S      dz pRat,12,12,pColour,SCREEN_COLOUR,pBold,"Space ",pNotBold,"Toggle"
keys5S      dz pRat,12,13,pColour,SCREEN_COLOUR,pBold,"   BI ",pNotBold,"Bold,Italics"
keys6S      dz pRat,12,14,pColour,SCREEN_COLOUR,pBold,"    R ",pNotBold,"Rotate"
keys7S      dz pRat,12,15,pColour,SCREEN_COLOUR,pBold,"   XY ",pNotBold,"Mirror X/Y"
keys8S      dz pRat,12,16,pColour,SCREEN_COLOUR,pBold,"    D ",pNotBold,"Default"



; Character sets are below this line
        align 1024
cs1     block CHARSET_LEN
        align 1024
cs2     block (65-32)*8
  db 0,$3c,$66,$66,$7e,$66,$66,$66,$00
  db $7c,$66,$66,$78,$66,$66,$7c,$00
  db $3c,$66,$60,$60,$60,$66,$3c,$00
  db $7c,$66,$66,$66,$66,$66,$7c,$00
  db $7e,$62,$60,$7c,$60,$62,$7e,$00
  db $7e,$62,$60,$7c,$60,$60,$60,$00
  db $3c,$66,$60,$6e,$62,$62,$3c,$00
  db $66,$66,$66,$7e,$66,$66,$66,$00
  db $7e,$18,$18,$18,$18,$18,$7e,$00
  db $7f,$0c,$0c,$0c,$4c,$4c,$38,$00
  db $66,$66,$6c,$78,$6c,$66,$66,$00
  db $60,$60,$60,$60,$60,$62,$7e,$00
  db $c6,$ee,$d6,$c6,$c6,$c6,$c6,$00
  db $66,$66,$76,$7e,$6e,$66,$66,$00
  db $3c,$66,$66,$66,$66,$66,$3c,$00
  db $7c,$66,$66,$7c,$60,$60,$60,$00
  db $3c,$66,$66,$66,$76,$6c,$3a,$00
  db $7c,$66,$66,$78,$66,$66,$66,$00
  db $3c,$66,$60,$3c,$06,$66,$3c,$00
  db $7e,$18,$18,$18,$18,$18,$18,$00
  db $66,$66,$66,$66,$66,$66,$3c,$00
  db $66,$66,$66,$66,$66,$3c,$18,$00
  db $c6,$c6,$c6,$c6,$d6,$ee,$c6,$00
  db $66,$66,$3c,$18,$3c,$66,$66,$00
  db $66,$66,$3c,$18,$18,$18,$18,$00
  db $7e,$06,$0c,$18,$30,$60,$7e,$00
  db $08,$1c,$3e,$7f,$3e,$1c,$08,$00
  db $00,$00,$00,$00,$00,$00,$00,$00
  db $00,$00,$00,$00,$00,$00,$00,$3c
  db $42,$b9,$a5,$b9,$a5,$42,$3c,$3c
  db $42,$99,$a1,$a1,$99,$42,$3c,$f0
        align 1024
cs3     
    block 8*10
  db $00,$00,$24,$18,$7e,$18,$24,$00
  db $00,$18,$18,$7e,$7e,$18,$18,$00
  db $00,$00,$00,$00,$18,$18,$08,$10
  db $00,$00,$00,$3e,$3e,$00,$00,$00
  db $00,$00,$00,$00,$00,$18,$18,$00
  db $00,$00,$06,$0c,$18,$30,$60,$00
  db $00,$3c,$7e,$66,$66,$66,$3c,$00
  db $00,$1c,$3c,$2c,$0c,$0c,$3e,$00
  db $00,$3c,$7e,$06,$3c,$60,$7e,$00
  db $00,$3c,$7e,$06,$1c,$66,$3c,$00
  db $00,$0c,$1c,$2c,$4c,$7e,$0c,$00
  db $00,$7e,$7e,$60,$7c,$06,$7c,$00
  db $00,$3c,$7e,$60,$7c,$66,$3c,$00
  db $00,$7e,$7e,$06,$0c,$18,$18,$00
  db $00,$3c,$7e,$66,$3c,$66,$3c,$00
  db $00,$3c,$7e,$66,$3e,$06,$3c,$00
  db $00,$00,$18,$18,$00,$18,$18,$00
  db $00,$18,$18,$00,$18,$18,$08,$10
  db $00,$00,$0c,$18,$30,$18,$0c,$00
  db $00,$00,$7e,$7e,$00,$7e,$00,$00
  db $00,$00,$30,$18,$0c,$18,$30,$00
  db $00,$3c,$66,$0c,$18,$00,$18,$00
  db $00,$00,$18,$3c,$3c,$18,$00,$00
  db $00,$3c,$7e,$66,$7e,$66,$66,$00
  db $00,$7c,$7e,$66,$7c,$66,$7c,$00
  db $00,$3c,$7e,$60,$60,$7e,$3c,$00
  db $00,$78,$7c,$66,$66,$7c,$78,$00
  db $00,$7e,$7e,$60,$78,$60,$7e,$00
  db $00,$7e,$7e,$40,$7c,$40,$40,$00
  db $00,$3c,$7e,$60,$6e,$66,$3c,$00
  db $00,$66,$66,$7e,$66,$66,$66,$00
  db $00,$7e,$7e,$18,$18,$18,$7e,$00
  db $00,$06,$06,$06,$66,$66,$3c,$00
  db $00,$66,$6c,$78,$78,$6c,$66,$00
  db $00,$60,$60,$60,$60,$60,$7e,$00
  db $00,$42,$66,$7e,$7e,$66,$66,$00
  db $00,$66,$76,$7e,$6e,$66,$66,$00
  db $00,$3c,$7e,$66,$66,$66,$3c,$00
  db $00,$7c,$7e,$66,$7c,$60,$60,$00
  db $00,$3c,$7e,$62,$6a,$66,$3c,$00
  db $00,$7c,$7e,$66,$7c,$6c,$66,$00
  db $00,$3c,$7e,$60,$3c,$46,$3c,$00
  db $00,$7e,$7e,$18,$18,$18,$18,$00
  db $00,$66,$66,$66,$66,$66,$3c,$00
  db $00,$66,$66,$66,$66,$24,$18,$00
  db $00,$66,$66,$66,$66,$7e,$24,$00
  db $00,$42,$66,$3c,$18,$3c,$66,$00
  db $00,$42,$66,$3c,$18,$18,$18,$00
  db $00,$7e,$7e,$0c,$18,$30,$7e,$00
  db $00,$3c,$3c,$30,$30,$30,$3c,$00
  db $00,$40,$60,$30,$18,$0c,$06,$00
  db $00,$3c,$3c,$0c,$0c,$0c,$3c,$00
  db $00,$18,$3c,$7e,$18,$18,$18,$00
  db $00,$00,$00,$00,$00,$00,$ff,$ff
  db $00,$1c,$3e,$32,$78,$30,$7e,$00

        align 1024
cs4     block CHARSET_LEN




    IF NEX == 0
        SAVESNA "charset.sna", main

    ELSE
; Stack: this area is reserved for the stack
STACK_SIZE: equ 100    ; in words 

; Reserve stack space
        defw 0  ; WPMEM, 2
stack_bottom:
        defs    STACK_SIZE*2, 0
stack_top:
        defw 0  ; WPMEM, 2

        SAVENEX OPEN "examples/charset.nex", main, stack_top
        SAVENEX CORE 2, 0, 0        ; Next core 2.0.0 required as minimum
        SAVENEX CFG 7   ; Border colour
        SAVENEX AUTO
        SAVENEX CLOSE
    ENDIF

