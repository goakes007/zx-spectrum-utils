@rem emulator should point to your emulator
set emulator=C:\GRAHAM\Games\spectrum\emulators\specemu-3.1.b130220\SpecEmu

@rem sjasm_path should point to your sjasmplus executable
set sjasm_path=C:\GRAHAM\Games\spectrum\dev\sjasmplus-1.18.3.win\sjasmplus

cls
@echo off
@rem set this_filepath to this directory
set this_filepath=%cd%
set asm_filename=%1

if not exist %asm_filename%.asm (
    echo "File %asm_filename%.asm does not exist..."

) else (
    @rem %sjasm_path% %asm_filename%.asm --inc=../asm -DNEX=0
    %sjasm_path% %asm_filename%.asm --inc=../asm -DCMDLINE=1
    IF ERRORLEVEL 1 (
        Echo ------------------------------------------------
        Echo             Error during assembly
        Echo ------------------------------------------------
    ) ELSE (
        Echo Compliled successfully!
        Echo ------------------------------------------------
        Echo           Compliled successfully!
        Echo ------------------------------------------------
        start %emulator% %this_filepath%\%asm_filename%.sna
    )
)


