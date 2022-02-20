; This is a sample program for print_letters asm library
    DEVICE ZXSPECTRUM48
    ORG $8000
main:
    jp start
    include print_letters.asm

start:
	SET_SCREEN_COLOR BgBlue+Bright
	SET_BORDER_COLOR Blue

    ld hl,str1      :    COOL_PRINT
    ld hl,str2      :    COOL_PRINT
    ld hl,str5      :    COOL_PRINT 
    ld hl,str10     :    COOL_PRINT 
    ld hl,str11     :    COOL_PRINT 
    ld hl,str12     :    COOL_PRINT 
    ld hl,str13     :    COOL_PRINT 
    ld hl,str14     :    COOL_PRINT 
    ld hl,str16     :    COOL_PRINT 
    ld hl,str17     :    COOL_PRINT 
    ld hl,str18     :    COOL_PRINT 
    ld hl,str19     :    COOL_PRINT 
    ld hl,str20     :    COOL_PRINT 
    ld hl,str22     :    COOL_PRINT 
    ld hl,str25     :    COOL_PRINT 
    ld hl,str26     :    COOL_PRINT 
    ld hl,str27     :    COOL_PRINT 
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
str25   dz  pRat,1,3,pDown,"Printing downwards"
str26   dz  pRat,30,20,pUp,pBold,"Print up and bold"
str27   dz  pRat,30,22,pLeft,pBold,pItalic,"Printing ",pInverse,"LEFT",pInverse," in BOLD/Italics"
str30   dz  "Hello World"

    SAVESNA "print_letters_sample.sna", main
