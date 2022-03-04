echo off
@cls

@echo:
@echo:
@type APP_VERSION
@echo:
@echo:
@type CHANGELOG.md
@echo:
@echo:

echo About to run flake8...
pause
flake8 .
@echo:
@echo:

echo About to running pylint...
pause
echo Running...
set skip=C0200,C0209,C0301,C0321,E1101,R0912,R0914,R0915,R0913,R1716,W1514,W1203
pylint graphics_viewer.py -d%skip%
pylint helper.py -d%skip%
pylint image_lib.py -d%skip%
pylint memory.py -d%skip%
pylint create_sprite_with_interlace.py -d%skip%
pylint sprite.py -d%skip%