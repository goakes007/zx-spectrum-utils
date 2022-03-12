;===========================================================================
; input.asm - Input from the keyboard
;===========================================================================
    ifndef INPUT_ASM        ; protect from being included more than once
    define INPUT_ASM
    jp input_asm.input_end

    ifndef DEBUG
        define DEBUG FALSE
    endif

    macro GET_KEYS_PRESSED
        call input_asm.priv_get_keys_pressed
    endm
                ;                       bits
keys            ;              port     4 3 2 1 0   keys  Notes:
keys0  byte 0   ;   01111111b  7F fe    B N MSsSp    0      eg, if b is pressed, then keys0 will be 10000b = $10
keys1  byte 0   ;   10111111b  BF fe    H J K LEn    1      eg, if h+l are pressed then key1 will be 10010b = $12
keys2  byte 0   ;   11011111b  DF fe    Y U I O P    2
keys3  byte 0   ;   11101111b  EF fe    6 7 8 9 0    3
keys4  byte 0   ;   11110111b  F7 fe    5 4 3 2 1    4
keys5  byte 0   ;   11111011b  FB fe    T R E W Q    5
keys6  byte 0   ;   11111101b  FD fe    G F D S A    6
keys7  byte 0   ;   11111110b  FE fe    V C X ZCs    7
keysend

;keys0  byte 0   ;   01111111b  7F fe    B N MSsSp    0      eg, if b is pressed, then keys0 will be 10000b = $10
KEY_BACK_SPACE   db   keys0%256,keys0/256,1
KEY_SPACE   db   keys0%256,keys0/256,1
KEY_SYMBOL_SHIFT   db   keys0%256,keys0/256,2
KEY_M   db   keys0%256,keys0/256,4
KEY_N   db   keys0%256,keys0/256,8
KEY_B   db   keys0%256,keys0/256,$10
; keys1  byte 0   ;   10111111b  BF fe    H J K LEn    1      eg, if h+l are pressed then key1 will be 10010b = $12
KEY_ENTER   db   keys1%256,keys1/256,1
KEY_L   db   keys1%256,keys1/256,2
KEY_K   db   keys1%256,keys1/256,4
KEY_J   db   keys1%256,keys1/256,8
KEY_H   db   keys1%256,keys1/256,$10
;keys2  byte 0   ;   11011111b  DF fe    Y U I O P    2
KEY_P   db   keys2%256,keys2/256,1
KEY_O   db   keys2%256,keys2/256,2
KEY_I   db   keys2%256,keys2/256,4
KEY_U   db   keys2%256,keys2/256,8
KEY_Y   db   keys2%256,keys2/256,$10
; keys3  byte 0   ;   11101111b  EF fe    6 7 8 9 0    3
KEY_0   db   keys3%256,keys2/256,1
KEY_9   db   keys3%256,keys2/256,2
KEY_8   db   keys3%256,keys2/256,4
KEY_7   db   keys3%256,keys2/256,8
KEY_6   db   keys3%256,keys2/256,$10
; keys4  byte 0   ;   11110111b  F7 fe    5 4 3 2 1    4
KEY_1   db   keys4%256,keys2/256,1
KEY_2   db   keys4%256,keys2/256,2
KEY_3   db   keys4%256,keys2/256,4
KEY_4   db   keys4%256,keys2/256,8
KEY_5   db   keys4%256,keys2/256,$10
; keys5  byte 0   ;   11111011b  FB fe    T R E W Q    5
KEY_Q   db   keys5%256,keys2/256,1
KEY_W   db   keys5%256,keys2/256,2
KEY_E   db   keys5%256,keys2/256,4
KEY_R   db   keys5%256,keys2/256,8
KEY_T   db   keys5%256,keys2/256,$10
; keys6  byte 0   ;   11111101b  FD fe    G F D S A    6
KEY_A   db   keys6%256,keys2/256,1
KEY_S   db   keys6%256,keys2/256,2
KEY_D   db   keys6%256,keys2/256,4
KEY_F   db   keys6%256,keys2/256,8
KEY_G   db   keys6%256,keys2/256,$10
; keys7  byte 0   ;   11111110b  FE fe    V C X ZCs    7
KEY_CAPS_SHIFT   db   keys7%256,keys2/256,1
KEY_CAPS_LOCK   db   keys7%256,keys2/256,1
KEY_Z   db   keys7%256,keys2/256,2
KEY_X   db   keys7%256,keys2/256,4
KEY_C   db   keys7%256,keys2/256,8
KEY_V   db   keys7%256,keys2/256,$10

    macro _IF_KEY ifinstance,key
        push hl,bc
        ld a,(key)
        ld l,a
        ld a,(key+1)
        ld h,a
        ld a,(key+2)
        ld b,a          ; and the key press with this
        ld a,(hl)       ; holds if the key was pressed or not
        and b
        pop bc,hl
        cp 0
		jr z, .ifelse_ifinstance
    endm

    module input_asm
priv_get_keys_pressed:
    push af,bc,hl
    ld b,8                  ; number of keys
    ld c,$7f                ; start at keys0
    ld hl,keys
.l1     ld a,c
        in a,($fe)          ; get the keys pressed
        xor $bf             ; this will make it simplier to understand
        ld (hl),a           ; store keys pressed
        inc hl
        rrc c
    djnz .l1
    IF DEBUG                ; If debug is on then print the keys at the bottom of the screen
        call private_print_keys_pressed
    ENDIF

    pop hl,bc,af
    ret


keys_text    dz "Keys"

private_print_keys_pressed
    PRINT_WORD $B800, keys_text, BgBlack+FgYellow
    ld hl,$b804
    ld a,(keys0)
    ld d,a
    ld a,(keys1)
    ld e,a
    PRINT_REGISTER_AT hl,de
    .5 inc hl
    ld a,(keys2)
    ld d,a
    ld a,(keys3)
    ld e,a
    PRINT_REGISTER_AT hl,de
    .5 inc hl
    ld a,(keys4)
    ld d,a
    ld a,(keys5)
    ld e,a
    PRINT_REGISTER_AT hl,de
    .5 inc hl
    ld a,(keys6)
    ld d,a
    ld a,(keys7)
    ld e,a
    PRINT_REGISTER_AT hl,de
    ret

input_end: nop
    endmodule
    endif