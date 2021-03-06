# ZX Spectrum Utilities: (zx-spectrum-utils)
In here you will find lots of assembler macros and callable routines to make your
development of ZX Spectrum assembler code much faster and easier.
There are routines for printing, screen calculations, if statements, for loops, keyboard presses
and much much more. There are also some python scripts to manipulate z80 graphics and pull/rip them from old roms.

The ZX Spectrum is one of the first home computers from the early 1980s.
More information can be found here: https://en.wikipedia.org/wiki/ZX_Spectrum

## 1. A library of ASM macros and definitions
It is recommended to start with the samples in the next section which will hopefully whet your appetite.
Macros, callable routines and definitions have been supplied in the asm folder.
If you would like to understand these in detail then you could 
open colour.asm, input.asm, helper.asm and print_letters.asm.
This will give you a good understanding of what they can be used for.
Note: that the assembler of choice is [sjasmplus](https://github.com/sjasmplus/sjasmplus) as it is very powerful.

### Run the samples
This is a good first step to understanding what is available with only a few lines of code.
If you would like to run these from the command line then 
1. Clone this repo and 
2. cd examples
3. Edit run.cmd file 
4. Update the top of the file.
* Set **emulator** to point to your emulator and 
5. use **run filename** to run the examples.
* For example:      zx-spectrum-utils> **run hello_world.sna**
* or zx-spectrum-utils> **run charset.sna**
* or zx-spectrum-utils> **run print_letters_sample.sna**
* or zx-spectrum-utils> **run draw.sna**
5. You can now open each file but with the .asm extension to view what the code looks like and see how
easy it is to produce these programs

### Assemble and run the samples
This is a good second step to understanding what is available with only a few lines of code.
Assuming the above steps have been completed. 
If you would like to run these from the command line then 
1. Install [sjasmplus](https://github.com/sjasmplus/sjasmplus)
2. Edit arun.cmd file 
3. Update at the top of the file.
* Set **emulator** to point to your emulator and 
* set **sjadm_path** to the sjasmplus executable. 
4. use **run filename** to run the examples.
* For example:      zx-spectrum-utils> **arun hello_world.asm**
* or zx-spectrum-utils> **arun charset.asm**
* or zx-spectrum-utils> **arun print_letters_sample.asm**
5. You can now open each file but with the .asm extension to view what the code looks like and see how
easy it is to produce these programs

### Create Hello World program
The next section walks through the creation of the hello_world.asm program. 
If you prefer to watch videos then here's one for the hello world example or you can read about it below.
[![Getting Started](https://i9.ytimg.com/vi/HWNXIYY29Jc/mq3.jpg?sqp=CMyMtJEG&rs=AOn4CLDSai5uOBEtUNUGNuX9UCv_CDxHgw)]
(https://youtu.be/HWNXIYY29Jc)

Getting for hello_world.asm: https://docs.google.com/presentation/d/15R4BytHgwOTKLnwlgieuS_XoJJmri6D3qJiumF-eZEU/edit#slide=id.p

Lets look at the hello_world.asm first. It can be broken into the following sections:

#### Section 1 - this is just some comments at the top - please read them
Think of the numbers are the screen co-ordinates
```
; This is a sample program "Hello World" for print_letters asm library
;  0123456789       <-- This is the screen position
;  1     H               Hello starts at 6,1 going down, and italics, and green
;  2     e               World starts at 5,5 lets do this bold and blue
;  3     l
;  4     l
;  5    World
```

#### Section  2 - some assembler directives. 
Comments have been added after the ; for your understanding
```text
    DEVICE ZXSPECTRUM48                 ; Select 48k spectrum as output device
    ORG $8000                           ; Start the output to $8000 memory address
main:                                   ; Just a label - so that the savesna works
    jp start                            ; Jump to the start of the program
    include print_letters.asm           ; Include the print letters library, hence the need for the previous jump
```

#### Section 3 - the main section. 
Comments have been added after the ; for your understanding

```text
; //////////////////// MAIN Section     ; This is just a comment
start:                                  ; This is a label that the previous jp jumps to, to start the program
    COOL_PRINT hello_str                ; Call COOL_PRINT to print the hello string
    COOL_PRINT world_str                ; Call COOL_PRINT to print the world string
l1  jr l1                               ; Nothing else to do here so just continuely loop - you program would go on to do more here
```
Importantly, writing this code is super easy to print stuff to the screen!

#### Section 4
The data section, which is how you can define the hello and world strings that were previously printed.
Notice the pAt,pDown,pInk and so on - these are controls that are part of the string 
to get cool print to do special things.
Understanding these controls will allow you to make perform power actions on the screens. 
Check out print_letters.asm for all these controls.
```text
; //////////////////// Data Section
hello_str    dz  pAt,6,1,pDown,pItalic,pInk,Green,"Hello"       ; Notice how this map to the comments
world_str    dz  pRat,5,5,pBold,pInk,Blue,"World"               ;    at the start of this program
```
#### Section 5
lastly, just create the snap file. Importantly, this is the same name as the asm file.
```text
    SAVESNA "hello_world.sna", main
```
#### section 6
Running this sample as follows: **run hello_world.asm**

The output looks as follows: 

![hello_world](images/hello_world.png)

In your program you will just need to pull in the include, add some strings, then call cool print.
A more elaborate example can be found with print_letters_sample.asm. 
The output of this looks like this:

![print_letters_sample](images/print_letters_sample.png)

Notice there are many control characters here for things like bold, italic, strike through,
underscore, rotation, mirroring, colours, flashing, bright, and many others.
These can all be combined with each other as needed.
One thing that is not so obvious is that as you set controls in place they stay in place.
This can be reset back to defaults by either calling pReset or pRat which is a reset followed by a screen location.

### Colours Module (colour.asm)
Simply has a list of colours that you can use.

### Input Module (input.asm)
Is an easy way to find what keys have been pressed. 
Just include it at the top of your program, 
add the macro "GET_KEYS_PRESSED" to your game loop.
Finally, test if a key is pressed using something like:
```text
    include "input.asm"             ; 1. Include it!
    ...
game_loop
    GET_KEYS_PRESSED                ; 2. Call it at the top of the game loop
    ...
    _IF_KEY 1, KEY_P                ; 3. This test for the "P" key being pressed
        call move_right_key_pressed ; call the routine to deal with p pressed
    _END_IF_NO_ELSE label1
```
### Helper module (Helper.asm)
This module is here to provide LOTS of great macros to make coding much 
simpler for the assembler developer. 
Here is a brief explanation of what they are at a high level.
The developers favourite ones are the _IF set and _IX set which 
he uses all the time to cut down the number of lines of code and 
increase readability.

```text
      ; sample IF statement
      _IF label1, a, 0            <-- All ifs need a label which allows then to be nested if needed. This compares reg A with 0 and if true does the next block
          ; do what ever....
      _ELSE label1                <-- If reg A is NOT zero then it will do this block
          ; otherwise do this....
      _END_IF label1
```

```text
    ; Sample IX macros. Imagine you had created a structure, and set IX pointing to that structure, then use these macros to access their offset
    ld ix, p_init_memory_values
    IX_GET b, p_mem.incx              <-- Equivalent to ld a,(IX+p_mem.incx) : ld b,a
    IX_LD p_mem.incx, p_mem.incy      <-- Equivalent to: ld a,(IX+p_mem.incy) : ld (IX+p_mem.incx),a
```

#### All the IF MACROS
The first set are short jumps like jr, and the second set use JP
```text
    ; ** Relative local jumps
    macro _IF	ifinstance,_reg,_value
    macro _IF_NOT	ifinstance,_reg,_value
    macro _ELSE ifinstance
    macro _END_IF ifinstance
    macro _END_IF_NO_ELSE ifinstance
    ; ** Long jumps
    macro _LONG_IF	ifinstance,_reg,_value
    macro _LONG_IF_NOT	ifinstance,_reg,_value
    macro _LONG_ELSE ifinstance
    macro _LONG_END_IF ifinstance
    macro _LONG_END_IF_NO_ELSE ifinstance
    ; ** Jumps depending on IX
    macro _LONG_IX_IF	ifinstance,_offset,_value
    macro _IX_IF ifinstance,_offset,_value
```

Example - if a=0 then b=1 else b=2
```
    _IF ind1, a, 0
        ld b, 1
    _ELSE ind1
        ld b,2
    _END_IF ind1
```



#### For macros
For loop allows a loop for a register
```text
    macro _FOR     reg, _start, end, step
    macro _END_FOR reg,
```

Example from draw.asm: This draws a nice pattern on the screen
```text
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
```

#### ALL IX macros
This is a great way of manipulating structures which I use loads!
```text
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
```

Example from charset.asm
```text
    struct  vars                                            ;
cs      byte    1   ; 1-4                                   ;
char    byte    32  ; 32-128                                ;
gx      byte    0   ; 0-7                                   ;
gy      byte    0   ; 0-7                                   ; THIS
max     byte    4   ; 0-...                                 ; 
cnt     byte    0   ; count down to next try the keys       ; IS
    ends                                                    ;
                                                            ; ALL
vars_memory                                                 ;
    db  1       ; charset                                   ; STANDARD
    db  65      ; char                                      ;
    db  3,3     ; g x,y                                     ; ASSEMBLER
    db  4,4     ; max, cnt                                  ;
    
    ld ix, vars_memory      ; Set IX to point to the structure
    IX_GET a,vars.char      ; ** set a to the char value in var structure
    IX_INC vars.gx          ; inc gx value in vars structure
```

#### MEMORY macros
Which are similar to the IX macros but directly to memory
```text
    macro MEM_SET _mem_loc,_value
    macro MEM_GET reg,_mem_loc
    macro MEM_INC _mem_loc
    macro MEM_DEC _mem_loc
    macro MEM_ADD _mem_loc,_value
    macro MEM_SUB _mem_loc,_value
```

#### Dealing with the screen
```text
    macro CALC_SCREEN_LOCATION screenyx8
    macro CALC_SCREEN_LOCATION8x8 screeny8x8
    macro CALC_COLOUR_LOCATION8x8 screeny8x8
    macro CALC_COLOUR_LOCATION screenyx8
    macro INC_Y_SCREEN_LOCATION
    macro INC_Y_COLOUR_LOCATION
    macro SET_SCREEN_COLOUR colour_num
    macro SET_BORDER_COLOUR colour_num2
    macro CLS
```

#### Drawing
Routines for plotting and drawing on the screen
```text
    macro PLOT1 x,y                             ; 2 (1 byte) args
    macro PLOT2 xy                              ; 1 (2 bytes) arg
    macro DRAW1 x1,y1,x2,y2                     ; 4 (1 byte) args
    macro PLOT2 xy1,xy2                         ; 1 (2 bytes) args
```

#### Miscellaneous
```text
    macro DIV_8 reg
    macro MIN _arg                              ; compare argument with A, A will hold the minimum
    macro MAX _arg                              ; compare argument with A, A will hold the maximun
    macro MULTIPLY word_arg, byte_arg
    macro STRING_SIZE mem_loc
    macro CALC_MEMORY_OFFSET mem_start, number
    macro INIT_MEMORY mem_start,mem_length
    macro HEX_TO_STRING
    macro RANDOM	                            ; return a random 8 bit number in A
```

## 2. Graphics Viewer: graphics_viewer
Lets start with a Python program,
**graphics_viewer** that can be used to pull in a spectrum file like a snap, z80 or trz file and
see the content as images. 
The idea of this tool is to allow the user to find graphics in the old games
and be able to have fun seeing them and also display the assembler DBs that
would be required to created them. 
Below is a screen shot

![graphics_viewer](images/graphics_viewer_screen.png)

There are a few key concepts to understand when using this program:
* file: You are displaying the content of a file on the screen in a graphical format in the hopes to find graphics
* memory: The memory pointer is shown in the top left corner and this is controlled by the arrow keys
* increase: Is the value that memory will change when certain keys are pressed. Changing this number will allow you to move around memory either more quickly or more refined
* columns: There are several columns and these are described below
* moving image: Images can be seen as moving by placing them on top of each other over time. For this we need an image count and size. In the example shown in the screen shot above it is using a 2x2 image size and an image count of 4. The red text "2x2" would need to be pressed.
* image count: the number of images in the moving image section from 1 to 8.
* red text: This is the size of the image you are interested in displaying for the moving graphic

### Getting Started
* Install python: https://www.python.org/downloads/
* Start a command prompt, clone the repo locally, and change to the root folder then into src folder
* It is probably best to create a local python virtual environment under this src, lets say under venv
  * python -m venv venv
* To active this python version
  * venv\Scripts\activate 
* update pip (optional)
  * python.exe -m pip install --upgrade pip 
* Install all the pre-req modules
  * pip install -r requirements.txt
* Run Graphics Viewer:
  * python graphics_viewer.py

### Important concepts
**Columns**
* first column: Is the memory location, see how the number increase as it goes down the screen
* Green text: This is the actual content of that memory location
* 8 - 8 bit sized images
* 16 - 16 bit sized images
* 24 - 24 bit sized images
* 32 - 32 bit sized images
* 64 - 64 bit sized images

**Keys**
* Up/down - move the memory pointer by the increase amount (fast memory movement)
* Left/right - move memory pointer by 1 (refined/slow movement)
* Page up/down - change the memory increase amount
* f - Read a new file
* d - Show assembler DBs for the moving image
* 1,2,3,4,5,6,7,8 - the number of images in the moving image
* q - quit (or escape)

**Mouse Control**
* Click green text: Move the memory pointer to that value
* Click numbered column (8, 16, 24, 32, 64): Dumps that columns assember DBs
* Click red text: Select the moving image size. For example 2x2


## 3. Developers / Pull Requests
If you would like to contribute to this repo then please submit a pull request.
Code should be compliant to flake8 and pylint.
Pull requests should contain:
* APP_VERSION: An updated version number
* CHANGELOG.md: An entry in the changelog so that we know when things were introduced
* Add any additional files to the quick_test.cmd
* Whatever else you want commit
* Ensure quick_test.cmd runs without any errors
