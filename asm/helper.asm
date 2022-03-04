/*
    This module is here to provide LOTS of great macros to make coding much simpler for the developer.
    My fav ones are the _IF set and _IX set which I use all the time to cut down the number of lines of code and increase readability.
    sample IF statement
      _IF label1, a, 0            <-- All ifs need a label which allows then to be nested if needed. This compares reg A with 0 and if true does the next block
          ; do what ever....
      _ELSE label1                <-- If reg A is NOT zero then it will do this block
          ; otherwise do this....
      _END_IF
    sample IX macros. Imagine you had created a structure, and set IX pointing to that structure, then use these macros to access their offset
        ld ix, p_init_memory_values
        IX_GET b, p_mem.incx              <-- Equivalent to ld a,(IX+p_mem.incx) : ld b,a
        IX_LD p_mem.incx, p_mem.incy      <-- Equivalent to: ld a,(IX+p_mem.incy) : ld (IX+p_mem.incx),a

  ** All the IF MACROS, the first set are short jumps like jr, and the secondf set use JP
	macro	_IF	ifinstance,_reg,_value
	macro	_IF_NOT	ifinstance,_reg,_value
	macro _ELSE ifinstance
	macro	_END_IF ifinstance
	macro	_END_IF_NO_ELSE ifinstance
	macro	_LONG_IF	ifinstance,_reg,_value
	macro	_LONG_IF_NOT	ifinstance,_reg,_value
	macro _LONG_ELSE ifinstance
	macro	_LONG_END_IF ifinstance
	macro	_LONG_END_IF_NO_ELSE ifinstance
	macro	_LONG_IX_IF	ifinstance,_offset,_value
	macro	_IX_IF	ifinstance,_offset,_value

  ** ALL IX macros 
	macro IX_GET _reg?, _offset      
	macro IX_SET _offset,_reg?
	macro IX_LD _offset,_offset2
	macro IX_INC _offset
	macro IX_DEC _offset
	macro IX_ADD _offset, value
	macro IX_SUB _offset, value
	macro IX_CP _offset1, _offset2   
  macro IX_GET2 _reg1?, _reg2?, _offset
  macro IX_SET2 _offset, _reg1?, _reg2?


  ** MEMORY macros which are similar to the IX macros but directly to memory
	macro MEM_SET _mem_loc,_value
	macro MEM_GET reg,_mem_loc
	macro MEM_INC _mem_loc
	macro MEM_DEC _mem_loc
	macro MEM_ADD _mem_loc,_value
	macro MEM_SUB _mem_loc,_value

  ** Dealing with the screen
	macro CALC_SCREEN_LOCATION screenyx8
	macro CALC_SCREEN_LOCATION8x8 screeny8x8
	macro CALC_COLOUR_LOCATION8x8 screeny8x8
	macro CALC_COLOUR_LOCATION screenyx8
	macro INC_Y_SCREEN_LOCATION
	macro INC_Y_COLOR_LOCATION
	macro SET_SCREEN_COLOR color_num
	macro SET_BORDER_COLOR color_num2

  ** Miscellaneous
	macro DIV_8 reg
	macro MIN _arg  ; compare argument with A, A will hold the minimum
	macro MAX _arg  ; compare argument with A, A will hold the maximun
	macro MULTIPLY word_arg, byte_arg
	macro STRING_SIZE mem_loc
	macro CALC_MEMORY_OFFSET mem_start, number
	macro return
	macro CLS
	macro INIT_MEMORY mem_start,mem_length
	macro HEX_TO_STRING
	HEX_TO_STRING_MEM equ helper.hex_to_string_mem
 */

  IFNDEF HELPER_ASM
  define  HELPER_ASM
  jp helper.helper_end

FALSE       equ     0
TRUE        equ     1

; ================================================================
; MACRO IF STATEMENT with SHORT jumps
	macro	_IF	ifinstance,_reg,_value
		ld a,_reg
		cp _value
		jr nz, .ifelse_ifinstance
	endm

	macro	_IF_NOT	ifinstance,_reg,_value
		ld a,_reg
		cp _value
		jr z, .ifelse_ifinstance
	endm

	macro _ELSE ifinstance
		jr .ifend_ifinstance
@.ifelse_ifinstance
	endm

	macro	_END_IF ifinstance
@.ifend_ifinstance
	endm

	macro	_END_IF_NO_ELSE ifinstance
@.ifelse_ifinstance
@.ifend_ifinstance
	endm

; ================================================================
; MACRO IF STATEMENT with LONG jumps
	macro	_LONG_IF	ifinstance,_reg,_value
		ld a,_reg
		cp _value
		jp nz, .ifelselong_ifinstance
	endm

	macro	_LONG_IF_NOT	ifinstance,_reg,_value
		ld a,_reg
		cp _value
		jp z, .ifelselong_ifinstance
	endm

	macro _LONG_ELSE ifinstance
		jp .ifendlong_ifinstance
@.ifelselong_ifinstance
	endm

	macro	_LONG_END_IF ifinstance
@.ifendlong_ifinstance
	endm

	macro	_LONG_END_IF_NO_ELSE ifinstance
@.ifelselong_ifinstance
@.ifendlong_ifinstance
	endm

; ================================================================
; MACROs Useful commands
  macro DIV_8 reg
    .3 srl reg
  endm

  macro MIN _arg  ; compare argument with A, A will hold the minimum
			cp _arg
			jr c, .e1
			ld a,_arg
.e1
  endm

  macro MAX _arg  ; compare argument with A, A will hold the maximun
			cp _arg
			jr nc, .e1
			ld a,_arg
.e1
  endm

; ================================================================
; MACRO FOR MEMORY COMMANDS
  macro MEM_SET _mem_loc,_value
    ld a,_value
    ld (_mem_loc),a
  endm

  macro MEM_GET reg,_mem_loc
    ld a,(_mem_loc)
    ld reg,a
  endm

  macro MEM_INC _mem_loc
    ld a,(_mem_loc)
    inc a
    ld (_mem_loc),a
  endm

  macro MEM_DEC _mem_loc
    ld a,(_mem_loc)
    dec a
    ld (_mem_loc),a
  endm

  macro MEM_ADD _mem_loc,_value
    ld a,(_mem_loc)
    add _value
    ld (_mem_loc),a
  endm

  macro MEM_SUB _mem_loc,_value
    ld a,(_mem_loc)
    sub _value
    ld (_mem_loc),a
  endm



; ================================================================
; MACRO FOR MEMORY COMMANDS with IX register

  macro IX_GET _reg?, _offset          ; Willy memory get offset
    ld _reg?, (ix+_offset)
  endm

  macro IX_GET2 _reg1?, _reg2?, _offset          ; Willy memory get offset
    ld _reg2?, (ix+_offset+0)
    ld _reg1?, (ix+_offset+1)
  endm

  macro IX_SET _offset,_reg?
    ld a,_reg?
    ld (ix+_offset),a
  endm

  macro IX_SET2 _offset, _reg1?,  _reg2?
    ld a,_reg2?
    ld (ix+_offset+0),_reg2?
    ld a,_reg1?
    ld (ix+_offset+1),_reg1?
  endm

  macro IX_LD _offset,_offset2
    ld a,(ix+_offset2)
    ld (ix+_offset),a
  endm

  macro IX_INC _offset
    ld a,(ix+_offset)
    inc a
    ld (ix+_offset),a
  endm

  macro IX_INC2 _offset
    ld a,(ix+_offset)
    inc a
    ld (ix+_offset),a
    cp 0
    jr z,.ixi
    inc (ix+_offset+1)
.ixi    
  endm

  macro IX_DEC _offset
    ld a,(ix+_offset)
    dec a
    ld (ix+_offset),a
  endm

  macro IX_DEC2 _offset
    ld a,(ix+_offset)
    dec a
    ld (ix+_offset),a
    cp 0
    jr z,.ixd
    dec (ix+_offset+1)
.ixd
  endm

  macro IX_ADD _offset, value
    ld a,(ix+_offset)
    add value
    ld (ix+_offset),a
  endm

  macro IX_SUB _offset, value
    ld a,(ix+_offset)
    sub value
    ld (ix+_offset),a
  endm


  macro IX_CP _offset1, _offset2          ; Willy memory get offset
    IX_GET a,_offset2
    IX_SET _offset1,a
  endm

	macro	_LONG_IX_IF	ifinstance,_offset,_value
    IX_GET a,_offset
		cp _value
		jp nz, .ifelselong_ifinstance
	endm

	macro	_IX_IF	ifinstance,_offset,_value
    IX_GET a,_offset
		cp _value
		jr nz, .ifelse_ifinstance
	endm

; ================================================================

  macro CALC_MEMORY_OFFSET mem_start, number
    ld hl,mem_start
    ld a,number
    call helper.priv_calc_memory_offset
  endm

  ; CALC_SCREEN_LOCATION: Given screen position in HL, calculate the actual screen memory location
  ; h = y axis, pixel level
  ; l = x8 axis, char level
  macro CALC_SCREEN_LOCATION screenyx8
    ld hl,screenyx8
    call helper.priv_screen_calc_yx8
  endm

  macro CALC_SCREEN_LOCATION8x8 screeny8x8
    ld hl,screeny8x8
    call helper.priv_screen_calc_8x8
  endm

  macro CALC_COLOUR_LOCATION8x8 screeny8x8
    ld hl,screeny8x8
    call helper.priv_screen_calc_8x8_colour
  endm

  macro CALC_COLOUR_LOCATION screenyx8
    ld hl,screenyx8
    call helper.priv_screen_calc_yx8_colour:
  endm

  macro INC_Y_SCREEN_LOCATION
    call helper.priv_screen_inc_y
  endm

  macro INC_Y_COLOR_LOCATION
    call helper.priv_screen_inc_y_colour
  endm

  macro SET_SCREEN_COLOR color_num
    push af
    ld a,color_num
    or 7
    call helper.priv_set_screen_color_to_a
    pop af
  endm

  macro SET_BORDER_COLOR color_num2
    push af
    ld a,color_num2
    out (#fe),a  
    pop af
  endm

  macro MULTIPLY word_arg, byte_arg
    push af
    ld hl,word_arg
    ld a,byte_arg
    call helper.priv_multiple
    pop af
  endm

  macro STRING_SIZE mem_loc
    push hl
    ld hl,mem_loc
    call helper.priv_string_size
    pop hl
  endm

  macro return
    ret
  endm

  macro CLS
    call helper.priv_cls
  endm

  macro INIT_MEMORY mem_start,mem_length
    push hl
    ld hl,mem_start
    ld bc,mem_length
    call helper.priv_init_memory
    pop hl
  endm

  macro HEX_TO_STRING
    call helper.hex_to_string
  endm

  macro RANDOM	; return a random 8 bit number in A
    call helper.random
  endm

HEX_TO_STRING_MEM equ helper.hex_to_string_mem



  module helper

random_memory
    dw 0000

random
    push hl, de
    ld a,r
    ld e,a
    ld d,0
    ld a,(random_memory)
    ld l,a
    ld a,(random_memory+1)
    ld h,a
    add hl,de
    ld a,h
    cp 16
    jr c, .r1
    ld a,0
    ld h,a
.r1 ld a,l
    ld (random_memory),a
    ld a,h
    ld (random_memory+1),a
    ld a,(hl)
    ld d,a
    inc hl
    ld a,(hl)
    .2 rr a
    xor d
    pop de, hl
    ret


hex_to_string_mem dz "0000"
; de holds memory location to get



hex_to_string
  ; de holds hex to convert into a string
  ; and store in hex_to_string_mem
  push hl, af
  ld hl,hex_to_string_mem
  ld a,d    ; char 1
  and $f0
  .4 rra
  call hex_to_char
  ld (hl),a
  inc hl
  ld a,d    ; char 2
  and $0F  
  call hex_to_char
  ld (hl),a
  inc hl
  ld a,e    ; char 3
  and $f0
  .4 rra
  call hex_to_char
  ld (hl),a
  inc hl
  ld a,e    ; char 4
  and $0F  
  call hex_to_char
  ld (hl),a
  inc hl
  pop af, hl
  ret

hex_to_char
; Convert hex to decimal for the accumulator
  cp 10         ; is A a letter of a number
  jr nc,.char
  add '0'
  jr .end
.char
  add 'A'-10
.end
  ret


priv_string_size
  ; HL will hold the string memory location
  ; A will return the size
  push bc
  ld b,0
.n1
  ld a,(hl)
  cp 0
  jr z, .e1
  inc b
  inc hl
  jr .n1
.e1
  ld a,b
  pop hl
  ret

priv_multiple
; multiple hl by a
; leaving result in hl
  push bc,de
  ld bc,hl      ; ld bc with the continuously doubled number
  ld de,0       ; hold de with the running sum
.s1
  sra a
  jr nc, .n1  ; not to be added
  ld hl,de
  add hl,bc
  ld de,hl
.n1
  ld hl,bc
  add hl,hl
  ld bc,hl
  cp 0
  jr nz, .s1
  ld hl,de
  pop de,bc
  ret


priv_set_screen_color_to_a:
; Accumulator will hold colour
  push hl,de,bc
  ld d,a
  ld hl,$5800   ; color screen location
  ld bc,32*24
.l1
  ld a,d
  ld (hl),a
  inc hl
  dec bc
  ld a,b
  or c
  jr nz, .l1
  pop bc,de,hl
  ret

priv_screen_inc_y:
  ; increase Y value in HL on the screen by 1 pixel
  inc  h
  ld   a,h
  and  7
  ret   nz
  ld   a,h
  sub  8
  ld   h,a
  ld   a,l
  add  a,$20
  ld   l,a
  and  $e0
  ret   nz
  ld   a,h
  add  a,8
  ld   h,a
  ret


priv_screen_inc_y_colour:
  ; Increse Y colour value in HL on the screen colour by 1 char
  ld   a,l
  add  a,$20
  ld   l,a
  and  $e0
  ret  nz
  inc  h
  ret

priv_screen_calc_8x8:
    .3 sla h          ; multiply by 8
    jp priv_screen_calc_yx8 

priv_screen_calc_yx8:
  ; Given screen position in HL, calculate the actual screen memory location
  ; +--------------------------+--------------------------+
  ; | y7 y6 y5 y4 y3 y2 y1 y0  | x7 x6 x5 x4 x3 x2 x1 x0  |
  ; +--------------------------+--------------------------+
  ; | H = Y axis (0-191)       | L = X axis (0-31)        |
  ; | 15 14 13 12 11 10  9  8  |  7  6  5  4  3  2  1  0  |
  ; |  0  1  0 y7 y6 y2 y1 y0  | y5 y4 y3 x4 x3 x2 x1 x0  |
  ; +--------------------------+--------------------------+
  ; h = y axis, pixel level
  ; l = x axis, char level
  push    bc,af
  ld      bc,hl
  ; y-axis 0-191
  ld      a,b           ; y0,1,2    h bits 10,9,8
  and     00000111b
  or      01000000b     ;           h bits 15,14,13
  ld      h,a
  ld      a,b
  and     11000000b     ; y6,7      h bits 12,11
  .3 rra
  or      h
  ld      h,a           ; h, y-axis is now done

  ld      a,b
  and     00111000b     ; y 3,4,5   l bits 7,6,5
  rla 
  rla   
  ld      l,a           ; y3,4,5 stored in l 7,6,5
  ; x-axis 0-31
  ld a,c
  and 00011111b         ; x4,3,2,1,0
  or l
  ld l,a                ; stored in l
  pop     af,bc
  ret


priv_screen_calc_8x8_colour:
    .3 sla h          ; multiply by 8
    jp priv_screen_calc_yx8_colour 

priv_screen_calc_yx8_colour:
  ; Calculate the color location in HL and set HL to this value
  ; Y = h in pixels, so need to shift right 3 times
  ; X = l
  ; Given screen position in HL, calculate the actual screen memory location
  ; +--------------------------+--------------------------+
  ; | y7 y6 y5 y4 y3 y2 y1 y0  | x7 x6 x5 x4 x3 x2 x1 x0  |
  ; +--------------------------+--------------------------+
  ; | H = Y axis (0-191)       | L = X axis (0-31)        |
  ; | 15 14 13 12 11 10  9  8  |  7  6  5  4  3  2  1  0  |
  ; | 80 40 20 10  8  4  2  1  | 80 40 20 10  8  4  2  1  |
  ; |  0  1  0  1  1  0 y6 y7  | y3 y4 y5 x4 x3 x2 x1 x0  |  
  ; +--------------------------+--------------------------+
  ; h = y axis, pixel level
  ; l = x axis, char level
  push af,bc
  ld bc,hl
  ld a,h
  ; y6 and 7 
  ld a,b
  and 11000000b
  .6 rra
  or 01011000b 
  ld h,a
  ; y5,4,3
  ld a,b
  and 00111000b
  .2 rla
  ld l,a
  ; x
  ld a,c
  and 00011111b
  or l
  ld l,a
  pop bc,af
  ret

priv_cls
  ld hl,$4000
  ld bc,$1800
  INIT_MEMORY hl,bc
  ret

priv_init_memory
  push hl,bc,af
.n1
  ld (hl),0
  inc hl
  dec bc
  ld a,b
  or c
  jr nz,.n1
  pop af,bc,hl
  ret

priv_calc_memory_offset
  ; It is common to have a list of addresses in memory,
  ; this function will take the base added and the offset
  ; It will calculate the location of the address
  ; pull these address from memory and store in HL
  ; HL =base address
  ; A  = offset
    push de
    add a,a
    ld e,a
    ld d,0
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    pop de
  ret


helper_end  nop
  endmodule
  ENDIF