cls
@echo off
set asm_filename=%1

if not exist %asm_filename%.asm (
    echo "File %asm_filename%.asm does not exist..."

) else (
    call setenv
    %sjasm_path% %asm_filename%.asm --inc=../asm
    IF %ERRORLEVEL% EQU 0 (
        Echo "Compliled successfully!"
        Echo ------------------------------------------------
        Echo           Compliled successfully!
        Echo ------------------------------------------------
        start %emulator% %this_filepath%\%asm_filename%.sna
    ) ELSE (
        Echo ------------------------------------------------
        Echo             Error during assembly
        Echo ------------------------------------------------
    )
)
