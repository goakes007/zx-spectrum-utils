/*
; In this module are many routines to print words on the spectrum display

** COOL_PRINT 
    This takes a string and displays it on the screen. Sounds simple, but has LOADs of controls that can be specified. For example:
        dw  pAt,3,10,pInk,Blue,pPaper,Yellow,pBright,pBold,pDown"Hello World"
    This will print at screen location x=3,y=10, with blue ink, yellow paper, bright, bold writing down (not right) the words "Hello World".
    This is great for building fun text screens like for adventures. Here's a list of possible controls:
        pAt                pColour            pInk               pPaper             pBright            pNotBright         
        pFlash             pNotFlash          pBold              pNotBold           pUnderscore        pNotUnderscore     
        pStrikeThrough     pNotStrikeThrough  pItalic            pNotItalic         pMirrorX           pNotMirrorX       
        pMirrorY           pNotMirrorY        pReset             pDefault           pInverse           pIncx              
        pIncy              pRotate            pSizex             pSizey             pMemory            pRight             
        pLeft              pDown              pUp                pRat               
    Note: Since this is SO rich with function it does come with the price of slower performance.

** PRINT_WORD screenyx, memory_loc, colour
    This is a macro that takes 3 parameters. 
        - screenxy - The screen location: y=0-191, x=0-31
        - memory_loc - the location of a zero terminated string
        - colour - standard speccy colour format:     [flash][bright][paper][ink]

** PRINT_8x8_GRAPHIC screenyx, memory_loc, colour
    This is a macro that takes 3 parameters. 
        - screenxy - The screen location: y=0-191, x=0-31
        - memory_loc - the location of graphic
        - colour - standard speccy colour format:     [flash][bright][paper][ink]

** PRINT_REGISTER reg
    This will print the value of a register to the bottom right of the screen. Parameters:
        - reg - the register to print.
    Note: This is useful for debugging

** PRINT_REGISTER_AT screenyx8, reg
    This will print the value of a register at the location specified to the screen. Parameters:
        - screenyx8 - The screen location: y=0-191, x=0-31
    Note: This is useful for debugging
 */

    ifndef PRINT_LETTERS_ASM
    define PRINT_LETTERS_ASM
    jp PRINT_LETTERS.print_letters_end

  include colour.asm
  include helper.asm

  ; COOL_PRINT: A great way of printing text to the screen with lots of widgets
  ; memory_str = holds the memory location of a zero terminated string. Many special characters can be used
  macro COOL_PRINT memory_str
    push hl
    ld hl, memory_str
    call PRINT_LETTERS.cool_print
    pop hl
  endm

  ; PRINT_WORD: on the screen
  ; h = y axis, pixel level
  ; l = x8 axis, char level
  macro PRINT_WORD screenyx8, memory_loc, colour
    push hl,de,bc
    ld c, colour
    ld hl, screenyx8
    ld de, memory_loc
    call PRINT_LETTERS.priv_print_word
    pop bc,de,hl
  endm

  ; PRINT_8x8_GRAPHIC: on the screen
  ; h = y axis, pixel level
  ; l = x8 axis, char level
  macro PRINT_8x8_GRAPHIC screeny8x8, memory_loc, colour
    push hl,de,bc
    ld c, colour
    ld hl, screeny8x8
    .3 sla h
    ld de, memory_loc
    call PRINT_LETTERS.priv_print_8x8_graphic
    pop bc,de,hl
  endm

  macro PRINT_REGISTER reg
    push de
    ld de,reg
    call PRINT_LETTERS.print_hex
    pop de
  endm

  macro PRINT_REGISTER_AT screenyx8, reg
    push de,hl
    ld de,reg
    ld hl,screenyx8
    call PRINT_LETTERS.print_hex_at
    pop hl,de
  endm

pAt                     equ     $81               ; x(0-31),y(0-24)   location
pColour                 equ     $82               ; c(0-255)          colour: flash(0/1),bright(0/1),paper(0/7),ink(0/7)
pInk                    equ     $83               ; ink (0-7)
pPaper                  equ     $84               ; paper (0-7)

pBright                 equ     $85               ; 
pNotBright              equ     $86               ;
pFlash                  equ     $87               ; 
pNotFlash               equ     $88               ;
pBold                   equ     $89               ;
pNotBold                equ     $8a               ;
pUnderscore             equ     $8b               ;
pNotUnderscore          equ     $8c               ;
pStrikeThrough          equ     $8d               ;
pNotStrikeThrough       equ     $8e               ;
pItalic                 equ     $8f               ;
pNotItalic              equ     $90               ;
pMirrorX                equ     $91               ;
pNotMirrorX             equ     $92               ;
pMirrorY                equ     $93               ;
pNotMirrorY             equ     $94               ;

pReset                  equ     $95               ; Reset all colours, x, y etc back to default values
pDefault                equ     $96               ; Make the present configuration the new default
pInverse                equ     $97               ; reverse the paper and ink colours
pIncx                   equ     $98               ; -x to x will be added to x and then and 32
pIncy                   equ     $99               ; -x to x will be added to y and then and 32
pRotate                 equ     $9a               ; 0,1,2,3: 0:None, 1:90 degress, 2:180 degress, 3:270 degress
pSizex                  equ     $9b               ; 1-4
pSizey                  equ     $9c               ; 1-4
pMemory                 equ     $9d               ; memory address
pRight                  equ     $9e               ; Reset all turning stuff, and print right
pLeft                   equ     $9f               ; Reset all turning stuff, and print left
pDown                   equ     $a0               ; Reset all turning stuff, and print downwards
pUp                     equ     $a1               ; Reset all turning stuff, and print upwards
pRat                    equ     $a2               ; Reset and print at
pRepeat                 equ     $a3               ; Repeat the last character

    MODULE PRINT_LETTERS

;   To dos: reset 1,2,3,4, size x,y

                        struct  p_mem
x                       byte 8
y                       byte 0
colour                  byte 0
incx                    byte 1
incy                    byte 0
bold                    byte 0
underscore              byte 0
strikethrough           byte 0
italic                  byte 0
mirrorx                 byte 0
mirrory                 byte 0
rotate                  byte 0
sizex                   byte 0
sizey                   byte 0
memory                  word $3c00
                        ends

p_init_memory_values
                        db 0                      ; x
                        db 0                      ; y
                        db BgWhite+FgBlack        ; colour
                        db 1                      ; move right - inc x
                        db 0                      ; dont move down - inc y
                        db FALSE                  ; bold or not
                        db FALSE                  ; underscore or not
                        db FALSE                  ; strikethrough or not
                        db FALSE                  ; italic or not
                        db FALSE                  ; mirrorx or not
                        db FALSE                  ; mirrory or not
                        db 0                      ; rotate 0,1,2,3
                        db 1                      ; size x
                        db 1                      ; size y
                        dw $3c00                  ; Memory location to find the characters
p_default_memory_values
                        db 0                      ; x
                        db 0                      ; y
                        db BgWhite+FgBlack        ; colour
                        db 1                      ; move right - inc x
                        db 0                      ; dont move down - inc y
                        db FALSE                  ; bold or not
                        db FALSE                  ; underscore or not
                        db FALSE                  ; strikethrough or not
                        db FALSE                  ; italic or not
                        db FALSE                  ; mirrorx or not
                        db FALSE                  ; mirrory or not
                        db 0                      ; rotate 0,1,2,3
                        db 1                      ; size x
                        db 1                      ; size y
                        dw $3c00                  ; Memory location to find the characters


call_control_table
                        dw  private_pAt, private_pColour
                        dw  private_pInk, private_pPaper
                        dw  private_pBright, private_pNotBright
                        dw  private_pFlash, private_pNotFlash
                        dw  private_pBold, private_pNotBold
                        dw  private_pUnderscore, private_pNotUnderscore
                        dw  private_pStrikeThrough, private_pNotStrikeThrough
                        dw  private_pItalic, private_pNotItalic
                        dw  private_pMirrorX, private_pNotMirrorX
                        dw  private_pMirrorY, private_pNotMirrorY
                        dw  private_pReset, private_pDefault
                        dw  private_pInverse
                        dw  private_pIncx, private_pIncy
                        dw  private_pRotate
                        dw  private_pSizeX, private_pSizeY
                        dw  private_pMemory
                        dw  private_pRight, private_pLeft
                        dw  private_pDown, private_pUp
                        dw  private_pRat, private_pRepeat


; hl holds pointer to string which is zero terminated
cool_print_work_area
    db  0   ; +0    last char printed

cool_print
    push ix, hl, de, bc
    ld ix, p_init_memory_values

.next1
    ld a,(hl)
    CP 0
    _IF_NOT 0, a,0

        cp $80      ; if greater than $80 then it's a control character
        jr nc, .control_char
        ld (cool_print_work_area+0),a
        call print_next_letter      ; print the letter
        call move_xy_screen_pointers
        inc hl
        jr .next1

.control_char                       ; get the callable location from callable control table
        push hl
        sub pAt
        add a,a
        ld e,a
        ld d,0
        ld hl, call_control_table
        add hl,de
        ld e,(hl)
        inc hl
        ld d,(hl)
        ld bc,.l2
        pop hl
        push bc                     ; Push .l2 which is the next part of this routine which will be used on ret
        push de                     ; Push the callable routine, then return to call that routine
        ret
.l2     inc hl
        jp .next1

    _END_IF_NO_ELSE 0
    pop bc, de, hl, ix
    ret


move_xy_screen_pointers
    push bc
    IX_GET b,p_mem.incx         ; move x
    IX_GET a,p_mem.x
    add a,b
    and $1f
    IX_SET p_mem.x,a
    IX_GET b,p_mem.incy         ; move y
    IX_GET a,p_mem.y
    add a,b
    and $1f
    IX_SET p_mem.y,a
    pop bc
    ret

/////////////////////////////////////////////////////////////////////////////////////
// CONTROL CHARACTERS:
/////////////////////////////////////////////////////////////////////////////////////
private_pRat            ; RESET and AT
            call private_pReset
            inc hl  :     IX_SET p_mem.x,(hl)
            inc hl  :     IX_SET p_mem.y,(hl)
            ret

private_pAt            ; AT
            inc hl  :     IX_SET p_mem.x,(hl)
            inc hl  :     IX_SET p_mem.y,(hl)
            ret
private_pColour            ; COLOUR
            inc hl  :     IX_SET p_mem.colour,(hl)
            ret
private_pInk            ; INK
            inc hl
            ld a,(hl)
            and 7
            ld b,a
            IX_GET a,p_mem.colour
            and 11111000b
            or b
            IX_SET p_mem.colour,a
            ret
private_pPaper            ; PAPER
            inc hl
            ld a,(hl)
            and 7
            .3 add a,a
            ld b,a
            IX_GET a,p_mem.colour
            and 11000111b
            or b
            IX_SET p_mem.colour,a
            ret
private_pBright            ; BRIGHT
            IX_GET a,p_mem.colour
            or 01000000b
            IX_SET p_mem.colour,a
            ret
private_pNotBright    
            IX_GET a,p_mem.colour
            and 10111111b
            IX_SET p_mem.colour,a
            ret
private_pFlash              ; FLASH
            IX_GET a,p_mem.colour
            or 10000000b
            IX_SET p_mem.colour,a
            ret
private_pNotFlash
            IX_GET a,p_mem.colour
            and 10111111b
            IX_SET p_mem.colour,a
            ret
private_pBold           ; BOLD
            IX_SET p_mem.bold,$ff
            ret
private_pNotBold
            IX_SET p_mem.bold,0
            ret
private_pUnderscore     ; UNDERSCORE
            IX_SET p_mem.underscore,$ff
            ret
private_pNotUnderscore
            IX_SET p_mem.underscore,0
            ret
private_pStrikeThrough      ; STRIKE THROUGH
            IX_SET p_mem.strikethrough,$ff
            ret
private_pNotStrikeThrough
            IX_SET p_mem.strikethrough,0
            ret
private_pItalic         ; ITALIC
            IX_SET p_mem.italic,$ff
            ret
private_pNotItalic
            IX_SET p_mem.italic,0
            ret
private_pMirrorX            ; MIRROR X
            IX_SET p_mem.mirrorx,$ff
            ret
private_pNotMirrorX
            IX_SET p_mem.mirrorx,0
            ret
private_pMirrorY            ; MIRROR Y
            IX_SET p_mem.mirrory,$ff
            ret
private_pNotMirrorY
            IX_SET p_mem.mirrory,0
            ret
private_pRotate            ; ROTATE
            inc hl
            ld a,(hl)
            and 3
            IX_SET p_mem.rotate,a
            ret
private_pInverse            ; INVERSE
            IX_GET a,p_mem.colour
            ld c,a
            and 7
            .3 add a,a
            ld b,a
            ld a,c
            and 00111000b
            DIV_8 a
            or b
            ld b,a
            ld a,c
            and 11000000b
            or b
            IX_SET p_mem.colour,a
            ret
private_pIncx                                     ; INCX
            inc hl      :    IX_SET p_mem.incx,(hl)
            ret
private_pIncy                                     ; INCY
            inc hl      :    IX_SET p_mem.incy,(hl)
            ret
private_pReset                                    ; RESET - set all values back to the default value
            push hl
            ld hl,p_default_memory_values
            ld de,p_init_memory_values
            ld b,0
            ld c,p_default_memory_values-p_init_memory_values
            ldir
            pop hl
            ret
private_pDefault                                  ; DEFAULT - Set these values as the new default
            push hl
            ld hl,p_init_memory_values
            ld de,p_default_memory_values
            ld b,0
            ld c,p_default_memory_values-p_init_memory_values
            ldir
            pop hl
            ret
private_pSizeX                                    ; SIZE X
            inc hl      :     IX_SET p_mem.sizex,(hl)
            ret

private_pSizeY                                    ; SIZE y
            inc hl      :     IX_SET p_mem.sizey,(hl)
            ret

private_pRepeat                                   ; REPEAT number
            inc hl
            ld a,(hl)
            and $1f
            ld b,a
            cp 0
            jr z, .end1
            ld a,(cool_print_work_area+0)
            ld c,a

.repeat         ld a,c
                call print_next_letter      ; print the letter
                call move_xy_screen_pointers
                djnz .repeat
.end1
            ret

private_pMemory            ; MEMORY
            inc hl
            ld e,(hl)
            inc hl
            ld d,(hl)
            IX_SET p_mem.memory+0,e
            IX_SET p_mem.memory+1,d
            ret
private_pRight
            IX_SET p_mem.incx,1
            IX_SET p_mem.incy,0
            IX_SET p_mem.mirrorx,0
            IX_SET p_mem.mirrory,0
            IX_SET p_mem.rotate,0
            ret
private_pLeft
            IX_SET p_mem.incx,-1
            IX_SET p_mem.incy,0
            IX_SET p_mem.mirrorx,0
            IX_SET p_mem.mirrory,0
            IX_SET p_mem.rotate,2
            ret
private_pDown
            IX_SET p_mem.incx,0
            IX_SET p_mem.incy,1
            IX_SET p_mem.mirrorx,0
            IX_SET p_mem.mirrory,0
            IX_SET p_mem.rotate,1
            ret
private_pUp
            IX_SET p_mem.incx,0
            IX_SET p_mem.incy,-1
            IX_SET p_mem.mirrorx,0
            IX_SET p_mem.mirrory,0
            IX_SET p_mem.rotate,3
            ret


/////////////////////////////////////////////////////////////////////////////////////
// CREATING CHARACTERS:
/////////////////////////////////////////////////////////////////////////////////////
                align 8
p_work_area     db  0,0,0,0,0,0,0,0
p_work_area2    db  0,0,0,0,0,0,0,0

; ix holds p_mem structure
print_next_letter:
    push hl,bc
    call create_next_letter
    call rotate_and_mirror
    call draw_next_letter
    pop bc,hl
    ret

rotate_and_mirror
    push ix
    IX_GET a,p_mem.rotate
    cp 0
    jr z, .n1
    ld b,a
.n2
    call rotate90
    djnz .n2
.n1
    ; mirror?
    IX_GET a,p_mem.mirrorx
    cp 0
    call nz, image_mirrorx

    IX_GET a,p_mem.mirrory
    cp 0
    call nz, image_mirrory

    pop ix
    ret

image_mirrorx
    push hl, de, bc
    ld b,8
    ld de, p_work_area
    ld hl, p_work_area2+7
.l  ld a,(de)
    ld (hl),a
    inc de
    dec hl
    djnz .l
    call copy_workarea2_back_to_1
    pop bc, de, hl
    ret

image_mirrory
    push ix, hl, de, bc
    ; mirror the original sprite but put into work_area2
    call clear_work_area_2
    ld hl, p_work_area
    ld ix,p_work_area2
    ld b,8
.l2     ld e,(hl)
        ld d,0
        ld c,8
.l1         sla e
            rr d
            dec c
            jr nz, .l1
        ld (ix),d
        inc ix
        inc hl
        djnz .l2

    ; Copy the image back to the original work area
    call copy_workarea2_back_to_1
    pop bc, de, hl, ix


rotate90
    push ix, hl, de, bc

    ; Rotate the original sprite but put into work_area2
    call clear_work_area_2
    ld hl, p_work_area
    ld e,1                  ; e holds position in new sprite
    ld b,8
.l2     ld c,8
        ld ix,p_work_area2+7
        ld d,(hl)           ; d holds original sprite line
.l1     srl d
        jr nc, .n2
            ld a,(ix)
            or e
            ld (ix),a
.n2     dec ix
        dec c
        jr nz, .l1
    sla e
    inc hl
    djnz .l2

    ; Copy the image back to the original work area
    call copy_workarea2_back_to_1

    pop bc, de, hl, ix
    ret

clear_work_area_2
    ld hl, p_work_area2
    ld b,8
.l1 ld (hl),0
    inc hl
    djnz .l1
    ret

copy_workarea2_back_to_1
    ld hl, p_work_area2
    ld de, p_work_area
    ld bc,8
    ldir
    ret

create_next_letter:
    push bc,de,hl
    ld b,a
    IX_GET  l, p_mem.x
    IX_GET  h, p_mem.y
    IX_GET  c, p_mem.colour
    CALC_COLOUR_LOCATION8x8 hl
    ld (hl), c

    ld hl, p_work_area
    ld a, b
    call    priv_get_letter_address
    ld      b, 8h
.pll1:  ld      a,(de)
        ld      c,a
        IX_GET  a,p_mem.bold
        cp 0
        jr z, .n1
        ld      a,c
        add     a,a
        or      c
        ld      c,a
.n1     IX_GET  a,p_mem.italic
        cp 0
        jr z, .i2
        ; ITALICS
            ld a,l
            and 7
            cp 3
            jr nc, .i1
                ld a,c
                srl a
                ld c,a
                jr .i2
.i1         cp 5
            jr c, .i2
                ld a,c
                add a,a
                ld c,a
.i2     ld      a,c
        ld      (hl),a
        inc     de
        inc     l
        dec     b
        jr      nz, .pll1

    dec l
    IX_GET a,p_mem.underscore
    cp 0
    jr z,.n2
        ; UNDERSCORE
        ld (hl),$ff
.n2 IX_GET a,p_mem.strikethrough
    cp 0
    jr z,.n3
        ; STRIKE THROUGH
        ld a,l
        and 11111011b
        ld l,a
        ld a,(hl)
        or $0f
        ld (hl),a
        inc l
        ld a,(hl)
        or $f0
        ld (hl),a
.n3 pop hl,de,bc
    ret

priv_get_letter_address:
    ; Set a to the character of interest
    ; Return the start location for DE in memory of the graphic letter
    push    hl
    ld  d,0
    ld  e,a
    rl e : rl d
    rl e : rl d
    rl e : rl d
    IX_GET h,p_mem.memory+1
    IX_GET l,p_mem.memory
    add hl,de
    ld    d,h
    ld    e,l
    pop   hl
    ret

priv_get_letter_addr:
  ; Set a to the character of interest
  ; Return the start location for DE in memory of the graphic letter
    push    hl
    ld  d,0
    ld  e,a
    rl e : rl d
    rl e : rl d
    rl e : rl d
    ld   hl, $3c00
    add  hl,de
    ld   d,h
    ld   e,l
    pop  hl
    ret

/////////////////////////////////////////////////////////////////////////////////////
// PRINTING CHARACTERS:
/////////////////////////////////////////////////////////////////////////////////////
draw_next_letter
    IX_GET  l,p_mem.x
    IX_GET  h,p_mem.y
    CALC_SCREEN_LOCATION8x8 hl
    ld      de, p_work_area
    ld      b, 8h
.n1     ld a,(de)
        ld (hl),a
        inc h
        inc de
        djnz .n1
    ret

print_hex
  ; de holds hex to convert into a string
  ; and store in hex_to_string_mem
  HEX_TO_STRING
  PRINT_WORD $b81c, HEX_TO_STRING_MEM, FgWhite+BgBlack
  ret

print_hex_at
  ; de holds hex to convert into a string
  ; and store in hex_to_string_mem
  ; hl - screen location
  HEX_TO_STRING
  PRINT_WORD hl, HEX_TO_STRING_MEM, FgWhite+BgBlack
  ret

; h down            0-191
; l across          0-31
; de - memory location of word
priv_print_word:
  push af
.pw1:
    ld      a, (de)
    cp      0
    jr      z, .pw2
    call    priv_print_letter
    inc     de
    inc     l
    jr      .pw1
.pw2:
  pop af
  ret

; h down            0-23
; l across          0-31
; c colour
; a letter
priv_print_letter:
  push bc,de,hl
  CALC_SCREEN_LOCATION hl
  call    priv_get_letter_addr
  ld      b, 8h
.pll1:
    ld      a,(de)
    ld      (hl),a
    inc     de
    INC_Y_SCREEN_LOCATION
    dec     b
    jr      nz, .pll1
    ; colour our letter
    pop hl  ; grab the screen location
    push hl
    CALC_COLOUR_LOCATION hl
    ld (hl),c
  pop hl,de,bc
  ret


; h down            0-23
; l across          0-31
; c colour
; de memory of graphic
priv_print_8x8_graphic
  push bc,de,hl
  CALC_SCREEN_LOCATION hl
  ld      b, 8h
.pll1:
    ld      a,(de)
    ld      (hl),a
    inc     de
    INC_Y_SCREEN_LOCATION
    dec     b
    jr      nz, .pll1
    ; colour our letter
    pop hl  ; grab the screen location
    push hl
    CALC_COLOUR_LOCATION hl
    ld (hl),c
  pop hl,de,bc
  ret

print_letters_end: nop
   ENDMODULE
   ENDIF