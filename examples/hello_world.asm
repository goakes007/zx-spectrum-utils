; This is a sample program "Hello World" for print_letters asm library
;  0123456789       <-- This is the screen position
;  1     H               Hello starts at 6,1 going down, and italics, and green
;  2     e               World starts at 5,5 lets do this bold and blue
;  3     l
;  4     l
;  5    World

    DEVICE ZXSPECTRUM48                 ; Select 48k spectrum as output device
    ORG $8000                           ; Start the output to $8000 memory address
main:                                   ; Just a label - so that the savesna works
    jp start                            ; Jump to the start of the program
    include print_letters.asm           ; Include the print letters library, hence the need for the previous jump

; //////////////////// MAIN Section     ; This is just a comment
start:                                  ; This is a label that the previous jp jumps to, to start the program
    COOL_PRINT hello_str                ; Call COOL_PRINT with the hello string
    COOL_PRINT world_str                ; Call COOL_PRINT with the world string
l1  jr l1                               ; Nothing else to do here so just continuely loop - you program would go on to do more here

; //////////////////// Data Section
hello_str    dz  pAt,6,1,pDown,pItalic,pInk,Green,"Hello"       ; Notice how this map to the comments
world_str    dz  pRat,5,5,pBold,pInk,Blue,"World"               ;    at the start of this program

    SAVESNA "hello_world.sna", main
