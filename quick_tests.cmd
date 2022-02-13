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
pylint graphics_viewer.py -dC0301,C0321,E1101,R1716,R0912,R0914,R0915,W1203
pylint helper.py -dC0301,C0321,E1101,R1716,R0912,R0914,R0915,W1203,W1514,c0209
pylint image_lib.py -dC0301,C0321,E1101,R1716,R0912,R0914,R0915,W1203,R0913
pylint memory.py -dC0301,C0321,E1101,R1716,R0912,R0914,R0915,W1203,R0913

