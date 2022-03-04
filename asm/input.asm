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