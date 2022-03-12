@rem emulator should point to your emulator
@set emulator=C:\GRAHAM\Games\spectrum\emulators\specemu-3.1.b130220\SpecEmu


@echo off
@rem set this_filepath to this directory
set this_filepath=%cd%
set asm_filename=%1

set snap_filename=%asm_filename:~0,-4%.sna
set extension=%asm_filename:~-4%

if not exist %asm_filename% (
    echo File %asm_filename% does not exist...

) else (

    if NOT %extension% == .sna (
        echo File %asm_filename% has extension [%extension%] not [.sna] as expected

    ) else (
        start %emulator% %this_filepath%\%snap_filename%
    )
)


