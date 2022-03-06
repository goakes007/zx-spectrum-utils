; This is a sample program for print_letters asm library

    DEVICE ZXSPECTRUM48
    ORG $8000
main:
    jp start
    include ../asm/print_letters.asm

start:
	SET_SCREEN_COLOUR BgBlue+Bright
	SET_BORDER_COLOUR Blue

    COOL_PRINT str1
    COOL_PRINT str2
    COOL_PRINT str5
    COOL_PRINT str10
    COOL_PRINT str11
    COOL_PRINT str12
    COOL_PRINT str13
    COOL_PRINT str14
    COOL_PRINT str16
    COOL_PRINT str17
    COOL_PRINT str18
    COOL_PRINT str19
    COOL_PRINT str20
    COOL_PRINT str22
    COOL_PRINT str23
    COOL_PRINT str25
    COOL_PRINT str26
    COOL_PRINT str27
    COOL_PRINT str30
    COOL_PRINT mm1
    COOL_PRINT mm2
    COOL_PRINT mm3
    COOL_PRINT mm4
    COOL_PRINT mm5
    PRINT_WORD $B800, str30, FgBlue+BgYellow
    PRINT_REGISTER IX
    PRINT_REGISTER_AT $0018, HL
l1  jr l1

str1    dz  pAt,1,1,pBold,"Cool Printing",pAt,3,4,pInk,Blue,"Ink colours"
str2    dz  pAt,3,3,pPaper,Yellow,"Paper colours",pAt,20,3,pBright,"Bright"
str5    dz  pAt,20,4,pFlash,"Flashing"
str10   dz  pRat,3,6,pBold,"BOLD"   ; pRat as it resets all bolds, flashing, colours etc
str11   dz  pRat,15,6,pStrikeThrough,"STRIKE through"
str12   dz  pRat,3,7,pUnderscore,"Underscore"
str13   dz  pRat,15,7,pBold,pItalic,"Combos"
str14   dz  pRat,3,9,pRotate,1,"Rotate 90",pRat,15,9,pRotate,2,"Rotate 180"
str16   dz  pRat,17,10,pIncx,-1,"Print backwards"
str17   dz  pRat,28,11,pRotate,2,pIncx,-1,"Rotate and print Backwards"
str18   dz  pRat,3,13,pMirrorX,"Mirror X"
str19   dz  pRat,15,13,pMirrorY,pBold,"Mirror Y"
str20   dz  pRat,3,15,"Change Memory Pointer:", pRat,25,15,pMemory,$00,$2c,"ABCD"
str22   dz  pRat,25,17,pLeft,pInk,Blue,pPaper,Green,pBold,pBright,"Big Combo ",pInverse,"Inverse",pInverse," YAY!"
str23   dz  pRat,3,19,"Repeat x",pRepeat,10
str25   dz  pRat,1,3,pDown,"Printing downwards"
str26   dz  pRat,30,20,pUp,pBold,"Print up and bold"
str27   dz  pRat,30,22,pLeft,pBold,pItalic,"Printing ",pInverse,"LEFT",pInverse," in BOLD/Italics"
str30   dz  "Hello World"
mm1     dz  pRat,0,0,pMemory,memory_cap_a_low,memory_cap_a_high,pColour,BgYellow+FgRed,"A",pRepeat,21
mm2     dz  pRat,0,0,pIncx,0,pIncy,1,pMemory,memory_cap_a_low,memory_cap_a_high,pColour,BgYellow+FgRed,"A",pRepeat,21
mm3     dz  pRat,0,21,pMemory,memory_cap_a_low,memory_cap_a_high,pColour,BgYellow+FgRed,"A",pRepeat,21
mm4     dz  pRat,20,20,pMemory,memory_cap_a_low,memory_cap_a_high,pColour,BgBlue+FgGreen,"B"
mm5     dz  pRat,21,1,pMemory,memory_cap_a_low,memory_cap_a_high,pColour,BgBlue+FgYellow,"C"

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
g_baddy_8x8         ; B
  dg  -1---1--
  dg  --1-1---
  dg  1--1-1--
  dg  -1-1---1
  dg  --11-1-1
  dg  11-1-11-
  dg  -1-11---
  dg  ---1----
g_baddy2_8x8        ; C
  dg  11111111
  dg  1111111-
  dg  -111111-
  dg  -11111--
  dg  -1--11--
  dg  -1--11--
  dg  ----1---
  dg  ----1---

    SAVESNA "print_letters_sample.sna", main
