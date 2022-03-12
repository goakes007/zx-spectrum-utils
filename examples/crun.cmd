@rem emulator should point to your emulator
set emulator=C:\GRAHAM\Games\spectrum\emulators\specemu-3.1.b130220\SpecEmu

@rem sjasm_path should point to your sjasmplus executable
set sjasm_path=C:\GRAHAM\Games\spectrum\dev\sjasmplus-1.18.3.win\sjasmplus

@echo off
@rem set this_filepath to this directory
set this_filepath=%cd%
set asm_filename=%1

set snap_filename=%asm_filename:~0,-4%.sna
set extension=%asm_filename:~-4%

if not exist %asm_filename% (
    echo File %asm_filename% does not exist...

) else (

    if NOT %extension% == .asm (
        echo File %asm_filename% has extension [%extension%] not [.asm] as expected

    ) else (
        @rem %sjasm_path% %asm_filename% --inc=../asm -DNEX=0
        %sjasm_path% %asm_filename% --inc=../asm -DCMDLINE=1
        IF ERRORLEVEL 1 (
            Echo ------------------------------------------------
            Echo             Error during assembly
            Echo ------------------------------------------------
        ) ELSE (
            Echo ------------------------------------------------
            Echo           Compliled successfully!
            Echo ------------------------------------------------
            start %emulator% %this_filepath%\%snap_filename%
        )
    )
)


