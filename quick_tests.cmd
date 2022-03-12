call src\venv\Scripts\activate

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
flake8 src --exclude src/venv
@echo:
@echo:

echo About to running pylint...
pause
echo Running...
set skip=C0200,C0209,C0301,C0321,E1101,R0912,R0914,R0915,R0913,R1716,W1514,W1203
pylint src -d%skip% --ignore-paths=src/venv


@rem pylint graphics_viewer.py -d%skip%
@rem pylint helper.py -d%skip%
@rem pylint image_lib.py -d%skip%
@rem pylint memory.py -d%skip%
@rem pylint create_sprite_with_interlace.py -d%skip%
@rem pylint sprite.py -d%skip%