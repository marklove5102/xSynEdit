@echo off
cd /d "C:\Users\Platon\Documents\Embarcadero\Studio\37.0\CatalogRepository\SynEdit-13\2025.03\Packages\11AndAbove\Delphi"
call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"
dcc32.exe -B -Q SynEditDR.dpk
echo.
echo Compilation exit code: %errorlevel%
