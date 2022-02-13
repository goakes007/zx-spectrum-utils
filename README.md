# ZX Spectrum Utilities: (zx-spectrum-utils)
Here are a few utility programs that can be used with the ZX Spectrum roms.
The langage of choice here is Python so it would help if you have know in this langauge.
The ZX Spectrum is one of the first home computers from the early 1980s.
More information can be found here: https://en.wikipedia.org/wiki/ZX_Spectrum

## 1. Graphics Viewer: graphics_viewer
Can be used to pull in a spectrum file like a snap, z80 or trz file and
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

### Getting Started
* Install python: https://www.python.org/downloads/
* Start a command prompt, clone the repo locally, and change to the root folder
* It is probably best to create a local virtual environment under the root, lets say under venv
  * python -m venv venv
* To active this python version
  * venv\Scripts\activate 
* update pip (optional)
  * python.exe -m pip install --upgrade pip 
* Install all the pre-req modules
  * pip install -r requirements.txt
* Run Graphics Viewer:
  * python graphics_viewer.py

## 2. Developers / Pull Requests
If you would like to contribute to this repo then please submit a pull request.
Code should be compliant to flake8 and pylint.
Pull requests should contain:
* APP_VERSION: An updated version number
* CHANGELOG.md: An entry in the changelog so that we know when things were introduced
* Add any additional files to the quick_test.cmd
* Whatever else you want commit
* Ensure quick_test.cmd runs without any errors
