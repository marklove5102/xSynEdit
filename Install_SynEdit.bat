@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================================
:: xSynEdit 2025.03 Installer for RAD Studio
:: ============================================================================
:: Compiles and installs SynEdit packages for Win32, Win64, and Win64x
:: Registers design-time packages in both 32-bit and 64-bit IDE
:: ============================================================================

title xSynEdit 2025.03 Installer

set "COLOR_INFO=[94m"
set "COLOR_SUCCESS=[92m"
set "COLOR_WARN=[93m"
set "COLOR_ERROR=[91m"
set "COLOR_RESET=[0m"
set "COLOR_CYAN=[96m"
set "COLOR_WHITE=[97m"

set "SYNEDIT_ROOT=%~dp0"
set "SYNEDIT_ROOT=%SYNEDIT_ROOT:~0,-1%"
set "SOURCE_DIR=%SYNEDIT_ROOT%\Source"
set "HIGHLIGHTERS_DIR=%SYNEDIT_ROOT%\Source\Highlighters"
set "PACKAGES_DIR=%SYNEDIT_ROOT%\Packages\11AndAbove\Delphi"

set "RUNTIME_PKG=SynEditDR"
set "DESIGNTIME_PKG=SynEditDD"
set "PKG_DESCRIPTION=TurboPack SynEdit Delphi"

set "BACKUP_DIR=%SYNEDIT_ROOT%\Backups"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo.
echo %COLOR_CYAN%============================================================================%COLOR_RESET%
echo %COLOR_CYAN%              xSynEdit 2025.03 Installer for RAD Studio%COLOR_RESET%
echo %COLOR_CYAN%============================================================================%COLOR_RESET%
echo.

:: ============================================================================
:: STEP 1: Detect RAD Studio
:: ============================================================================
echo %COLOR_INFO%[1/8] Detecting installed RAD Studio versions...%COLOR_RESET%
echo.

set "FOUND_IDES=0"
set "IDE_LIST="

call :CheckIDE "24.0" "RAD Studio 11 Alexandria"
call :CheckIDE "23.0" "RAD Studio 12 Athens"
call :CheckIDE "37.0" "RAD Studio 13 Florence"

if %FOUND_IDES%==0 (
    echo %COLOR_ERROR%ERROR: No supported RAD Studio installation found!%COLOR_RESET%
    goto :Error
)

echo.

:: ============================================================================
:: STEP 2: Select IDE
:: ============================================================================
echo %COLOR_INFO%[2/8] Select RAD Studio version:%COLOR_RESET%
echo.

set "IDX=0"
for %%v in (%IDE_LIST%) do (
    set /a IDX+=1
    call :ShowIDEOption !IDX! %%v
)

echo.
set /p "SELECTED_IDE=Enter number (1-%IDX%) or 'q' to quit: "
if /i "%SELECTED_IDE%"=="q" goto :Cancelled

set "IDX=0"
set "TARGET_BDS="
for %%v in (%IDE_LIST%) do (
    set /a IDX+=1
    if "!IDX!"=="%SELECTED_IDE%" set "TARGET_BDS=%%v"
)

if "%TARGET_BDS%"=="" (
    echo %COLOR_ERROR%Invalid selection!%COLOR_RESET%
    goto :Error
)

call :GetIDEInfo "%TARGET_BDS%"

echo.
echo %COLOR_SUCCESS%Selected: %IDE_NAME% ^(BDS %TARGET_BDS%^)%COLOR_RESET%
echo   Root: %IDE_ROOT%
echo.

:: ============================================================================
:: Create backup
:: ============================================================================
echo %COLOR_INFO%Creating registry backup...%COLOR_RESET%
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "DATETIME=%%I"
set "TIMESTAMP=%DATETIME:~0,4%-%DATETIME:~4,2%-%DATETIME:~6,2%_%DATETIME:~8,2%-%DATETIME:~10,2%-%DATETIME:~12,2%"
set "BACKUP_FILE=%BACKUP_DIR%\BDS_%TARGET_BDS%_BEFORE_install_%TIMESTAMP%.reg"
reg export "HKCU\Software\Embarcadero\BDS\%TARGET_BDS%" "%BACKUP_FILE%" /y >nul 2>&1
echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% %BACKUP_FILE%
echo.

:: ============================================================================
:: STEP 3: Check rsvars.bat exists
:: ============================================================================
echo %COLOR_INFO%[3/8] Checking build environment...%COLOR_RESET%
echo.

set "RSVARS=!IDE_ROOT!\bin\rsvars.bat"
if not exist "!RSVARS!" (
    echo !COLOR_ERROR!ERROR: rsvars.bat not found at !RSVARS!!COLOR_RESET!
    goto :Error
)
echo   !COLOR_SUCCESS![OK]!COLOR_RESET! rsvars.bat found
echo.

:: ============================================================================
:: STEP 4: Select platforms
:: ============================================================================
echo %COLOR_INFO%[4/8] Select target platforms:%COLOR_RESET%
echo.
echo   1. Win32 only
echo   2. Win64 only
echo   3. Win32 + Win64 ^(recommended^)
echo   4. Win32 + Win64 + Win64x ^(ALL^)
echo.
set /p "PLATFORM_CHOICE=Enter number (1-4): "

set "COMPILE_WIN32=0"
set "COMPILE_WIN64=0"
set "COMPILE_WIN64X=0"

if "%PLATFORM_CHOICE%"=="1" set "COMPILE_WIN32=1"
if "%PLATFORM_CHOICE%"=="2" set "COMPILE_WIN64=1"
if "%PLATFORM_CHOICE%"=="3" (
    set "COMPILE_WIN32=1"
    set "COMPILE_WIN64=1"
)
if "%PLATFORM_CHOICE%"=="4" (
    set "COMPILE_WIN32=1"
    set "COMPILE_WIN64=1"
    set "COMPILE_WIN64X=1"
)

echo.
echo Selected platforms:
if %COMPILE_WIN32%==1 echo   - Win32
if %COMPILE_WIN64%==1 echo   - Win64
if %COMPILE_WIN64X%==1 echo   - Win64x

:: ============================================================================
:: STEP 5: Setup output directories
:: ============================================================================
echo.
echo %COLOR_INFO%[5/8] Setting up directories...%COLOR_RESET%
echo.

set "PUBLIC_DOCS=C:\Users\Public\Documents\Embarcadero\Studio\%TARGET_BDS%"
set "BPL_WIN32=%PUBLIC_DOCS%\Bpl"
set "BPL_WIN64=%PUBLIC_DOCS%\Bpl\Win64"
set "BPL_WIN64X=%PUBLIC_DOCS%\Bpl\Win64x"
set "DCP_WIN32=%PUBLIC_DOCS%\Dcp"
set "DCP_WIN64=%PUBLIC_DOCS%\Dcp\Win64"
set "DCP_WIN64X=%PUBLIC_DOCS%\Dcp\Win64x"

if not exist "%BPL_WIN32%" mkdir "%BPL_WIN32%"
if not exist "%DCP_WIN32%" mkdir "%DCP_WIN32%"
if %COMPILE_WIN64%==1 (
    if not exist "%BPL_WIN64%" mkdir "%BPL_WIN64%"
    if not exist "%DCP_WIN64%" mkdir "%DCP_WIN64%"
)
if %COMPILE_WIN64X%==1 (
    if not exist "%BPL_WIN64X%" mkdir "%BPL_WIN64X%"
    if not exist "%DCP_WIN64X%" mkdir "%DCP_WIN64X%"
)

:: Calculate version suffix (370 for 37.0, 230 for 23.0)
set "BDS_SUFFIX=%TARGET_BDS:.=%"
set "BDS_SUFFIX=%BDS_SUFFIX:~0,3%"

echo   BPL: %BPL_WIN32%
echo   DCP: %DCP_WIN32%

:: ============================================================================
:: STEP 6: Compile packages
:: ============================================================================
echo.
echo %COLOR_INFO%[6/8] Compiling packages...%COLOR_RESET%
echo.

set "RUNTIME_DPROJ=%PACKAGES_DIR%\%RUNTIME_PKG%.dproj"
set "DESIGNTIME_DPROJ=%PACKAGES_DIR%\%DESIGNTIME_PKG%.dproj"

if not exist "%RUNTIME_DPROJ%" (
    echo %COLOR_ERROR%ERROR: %RUNTIME_DPROJ% not found!%COLOR_RESET%
    goto :Error
)

:: Create temporary build script
set "BUILD_SCRIPT=%TEMP%\synedit_build_%RANDOM%.bat"

:: ============================================================================
:: Compile Win32
:: ============================================================================
if %COMPILE_WIN32%==1 (
    echo %COLOR_CYAN%--- Compiling Win32 ---%COLOR_RESET%

    echo   Building %RUNTIME_PKG% ^(Win32^)...
    > "%BUILD_SCRIPT%" echo @echo off
    >> "%BUILD_SCRIPT%" echo call "!RSVARS!"
    >> "%BUILD_SCRIPT%" echo msbuild.exe "%RUNTIME_DPROJ%" /t:Build /p:Config=Release /p:Platform=Win32 /p:DCC_BplOutput="%BPL_WIN32%" /p:DCC_DcpOutput="%DCP_WIN32%" /v:minimal /nologo
    call "%BUILD_SCRIPT%"
    if errorlevel 1 (
        echo   !COLOR_ERROR!FAILED!!COLOR_RESET!
        del "%BUILD_SCRIPT%" 2>nul
        goto :Error
    )
    echo   !COLOR_SUCCESS![OK]!COLOR_RESET! %RUNTIME_PKG%%BDS_SUFFIX%.bpl

    echo   Building %DESIGNTIME_PKG% ^(Win32^)...
    > "%BUILD_SCRIPT%" echo @echo off
    >> "%BUILD_SCRIPT%" echo call "!RSVARS!"
    >> "%BUILD_SCRIPT%" echo msbuild.exe "%DESIGNTIME_DPROJ%" /t:Build /p:Config=Release /p:Platform=Win32 /p:DCC_BplOutput="%BPL_WIN32%" /p:DCC_DcpOutput="%DCP_WIN32%" /v:minimal /nologo
    call "%BUILD_SCRIPT%"
    if errorlevel 1 (
        echo   !COLOR_ERROR!FAILED!!COLOR_RESET!
        del "%BUILD_SCRIPT%" 2>nul
        goto :Error
    )
    echo   !COLOR_SUCCESS![OK]!COLOR_RESET! %DESIGNTIME_PKG%%BDS_SUFFIX%.bpl
    echo.
)

:: ============================================================================
:: Compile Win64
:: ============================================================================
if %COMPILE_WIN64%==1 (
    echo %COLOR_CYAN%--- Compiling Win64 ---%COLOR_RESET%

    echo   Building %RUNTIME_PKG% ^(Win64^)...
    > "%BUILD_SCRIPT%" echo @echo off
    >> "%BUILD_SCRIPT%" echo call "!RSVARS!"
    >> "%BUILD_SCRIPT%" echo msbuild.exe "%RUNTIME_DPROJ%" /t:Build /p:Config=Release /p:Platform=Win64 /p:DCC_BplOutput="%BPL_WIN64%" /p:DCC_DcpOutput="%DCP_WIN64%" /v:minimal /nologo
    call "%BUILD_SCRIPT%"
    if errorlevel 1 (
        echo   !COLOR_ERROR!FAILED!!COLOR_RESET!
        del "%BUILD_SCRIPT%" 2>nul
        goto :Error
    )
    echo   !COLOR_SUCCESS![OK]!COLOR_RESET! %RUNTIME_PKG%%BDS_SUFFIX%.bpl

    echo   Building %DESIGNTIME_PKG% ^(Win64^)...
    > "%BUILD_SCRIPT%" echo @echo off
    >> "%BUILD_SCRIPT%" echo call "!RSVARS!"
    >> "%BUILD_SCRIPT%" echo msbuild.exe "%DESIGNTIME_DPROJ%" /t:Build /p:Config=Release /p:Platform=Win64 /p:DCC_BplOutput="%BPL_WIN64%" /p:DCC_DcpOutput="%DCP_WIN64%" /v:minimal /nologo
    call "%BUILD_SCRIPT%"
    if errorlevel 1 (
        echo   !COLOR_ERROR!FAILED!!COLOR_RESET!
        del "%BUILD_SCRIPT%" 2>nul
        goto :Error
    )
    echo   !COLOR_SUCCESS![OK]!COLOR_RESET! %DESIGNTIME_PKG%%BDS_SUFFIX%.bpl
    echo.
)

:: ============================================================================
:: Compile Win64x
:: ============================================================================
if %COMPILE_WIN64X%==1 (
    echo %COLOR_CYAN%--- Compiling Win64x ---%COLOR_RESET%

    echo   Building %RUNTIME_PKG% ^(Win64x^)...
    > "%BUILD_SCRIPT%" echo @echo off
    >> "%BUILD_SCRIPT%" echo call "!RSVARS!"
    >> "%BUILD_SCRIPT%" echo msbuild.exe "%RUNTIME_DPROJ%" /t:Build /p:Config=Release /p:Platform=Win64x /p:DCC_BplOutput="%BPL_WIN64X%" /p:DCC_DcpOutput="%DCP_WIN64X%" /v:minimal /nologo
    call "%BUILD_SCRIPT%"
    if errorlevel 1 (
        echo   !COLOR_ERROR!FAILED!!COLOR_RESET!
        del "%BUILD_SCRIPT%" 2>nul
        goto :Error
    )
    echo   !COLOR_SUCCESS![OK]!COLOR_RESET! %RUNTIME_PKG%%BDS_SUFFIX%.bpl
    echo   !COLOR_INFO![INFO]!COLOR_RESET! Design-time not needed for Win64x
    echo.
)

:: Cleanup temp script
del "%BUILD_SCRIPT%" 2>nul

:: ============================================================================
:: STEP 7: Register packages in IDE
:: ============================================================================
echo %COLOR_INFO%[7/8] Registering packages in IDE...%COLOR_RESET%
echo.

set "REG_KEY=HKCU\Software\Embarcadero\BDS\%TARGET_BDS%"

:: Register for 32-bit IDE (Known Packages uses Win32 BPL)
if %COMPILE_WIN32%==1 (
    set "DT_BPL_32=%BPL_WIN32%\%DESIGNTIME_PKG%%BDS_SUFFIX%.bpl"
    echo   Registering in 32-bit IDE...
    reg add "%REG_KEY%\Known Packages" /v "!DT_BPL_32!" /t REG_SZ /d "%PKG_DESCRIPTION% designtime package" /f >nul 2>&1
    echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% Known Packages
)

:: Register for 64-bit IDE (Known Packages x64 uses Win64 BPL)
if %COMPILE_WIN64%==1 (
    set "DT_BPL_64=%BPL_WIN64%\%DESIGNTIME_PKG%%BDS_SUFFIX%.bpl"
    echo   Registering in 64-bit IDE...
    reg add "%REG_KEY%\Known Packages x64" /v "!DT_BPL_64!" /t REG_SZ /d "%PKG_DESCRIPTION% designtime package" /f >nul 2>&1
    echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% Known Packages x64
)
echo.

:: ============================================================================
:: STEP 8: Configure Library Paths
:: ============================================================================
echo %COLOR_INFO%[8/8] Configuring Library Paths...%COLOR_RESET%
echo.

:: Delphi paths - add to Search Path and Browsing Path
if %COMPILE_WIN32%==1 (
    call :AddToLibraryPath "Win32" "Search Path" "%SOURCE_DIR%"
    call :AddToLibraryPath "Win32" "Search Path" "%HIGHLIGHTERS_DIR%"
    call :AddToLibraryPath "Win32" "Browsing Path" "%SOURCE_DIR%"
    call :AddToLibraryPath "Win32" "Browsing Path" "%HIGHLIGHTERS_DIR%"
)

if %COMPILE_WIN64%==1 (
    call :AddToLibraryPath "Win64" "Search Path" "%SOURCE_DIR%"
    call :AddToLibraryPath "Win64" "Search Path" "%HIGHLIGHTERS_DIR%"
    call :AddToLibraryPath "Win64" "Browsing Path" "%SOURCE_DIR%"
    call :AddToLibraryPath "Win64" "Browsing Path" "%HIGHLIGHTERS_DIR%"
)

if %COMPILE_WIN64X%==1 (
    call :AddToLibraryPath "Win64x" "Search Path" "%SOURCE_DIR%"
    call :AddToLibraryPath "Win64x" "Search Path" "%HIGHLIGHTERS_DIR%"
    call :AddToLibraryPath "Win64x" "Browsing Path" "%SOURCE_DIR%"
    call :AddToLibraryPath "Win64x" "Browsing Path" "%HIGHLIGHTERS_DIR%"
)

:: C++ paths (for HPP and LIB files) - add both Debug and Release for each platform
echo   Adding C++ paths...
set "CPP_PATH=%SYNEDIT_ROOT%\Packages\11AndAbove\cpp"

if %COMPILE_WIN32%==1 (
    :: Win32 Debug
    call :AddToCppPath "Win32" "IncludePath" "%CPP_PATH%\Win32\Debug"
    call :AddToCppPath "Win32" "IncludePath_Clang32" "%CPP_PATH%\Win32\Debug"
    call :AddToCppPath "Win32" "LibraryPath" "%CPP_PATH%\Win32\Debug"
    call :AddToCppPath "Win32" "LibraryPath_Clang32" "%CPP_PATH%\Win32\Debug"
    :: Win32 Release
    call :AddToCppPath "Win32" "IncludePath" "%CPP_PATH%\Win32\Release"
    call :AddToCppPath "Win32" "IncludePath_Clang32" "%CPP_PATH%\Win32\Release"
    call :AddToCppPath "Win32" "LibraryPath" "%CPP_PATH%\Win32\Release"
    call :AddToCppPath "Win32" "LibraryPath_Clang32" "%CPP_PATH%\Win32\Release"
)

if %COMPILE_WIN64%==1 (
    :: Win64 Debug
    call :AddToCppPath "Win64" "IncludePath" "%CPP_PATH%\Win64\Debug"
    call :AddToCppPath "Win64" "LibraryPath" "%CPP_PATH%\Win64\Debug"
    :: Win64 Release
    call :AddToCppPath "Win64" "IncludePath" "%CPP_PATH%\Win64\Release"
    call :AddToCppPath "Win64" "LibraryPath" "%CPP_PATH%\Win64\Release"
)

if %COMPILE_WIN64X%==1 (
    :: Win64x Debug
    call :AddToCppPath "Win64x" "IncludePath" "%CPP_PATH%\Win64x\Debug"
    call :AddToCppPath "Win64x" "LibraryPath" "%CPP_PATH%\Win64x\Debug"
    :: Win64x Release
    call :AddToCppPath "Win64x" "IncludePath" "%CPP_PATH%\Win64x\Release"
    call :AddToCppPath "Win64x" "LibraryPath" "%CPP_PATH%\Win64x\Release"
)

:: ============================================================================
:: Done!
:: ============================================================================
echo.
echo %COLOR_SUCCESS%============================================================================%COLOR_RESET%
echo %COLOR_SUCCESS%              Installation completed successfully!%COLOR_RESET%
echo %COLOR_SUCCESS%============================================================================%COLOR_RESET%
echo.
echo %COLOR_WHITE%Compiled packages:%COLOR_RESET%
if %COMPILE_WIN32%==1 (
    echo   Win32:  %BPL_WIN32%\%RUNTIME_PKG%%BDS_SUFFIX%.bpl
    echo           %BPL_WIN32%\%DESIGNTIME_PKG%%BDS_SUFFIX%.bpl
)
if %COMPILE_WIN64%==1 (
    echo   Win64:  %BPL_WIN64%\%RUNTIME_PKG%%BDS_SUFFIX%.bpl
    echo           %BPL_WIN64%\%DESIGNTIME_PKG%%BDS_SUFFIX%.bpl
)
if %COMPILE_WIN64X%==1 (
    echo   Win64x: %BPL_WIN64X%\%RUNTIME_PKG%%BDS_SUFFIX%.bpl
)
echo.
echo %COLOR_WHITE%IDE Registration:%COLOR_RESET%
if %COMPILE_WIN32%==1 echo   32-bit IDE: %COLOR_SUCCESS%Registered%COLOR_RESET%
if %COMPILE_WIN64%==1 echo   64-bit IDE: %COLOR_SUCCESS%Registered%COLOR_RESET%
echo.
echo %COLOR_WARN%============================================================%COLOR_RESET%
echo %COLOR_WARN%  IMPORTANT: Restart RAD Studio to load components!%COLOR_RESET%
echo %COLOR_WARN%============================================================%COLOR_RESET%
echo.
echo Components will appear in Tool Palette:
echo   - "SynEdit" category
echo   - "SynEdit Highlighters" category
echo.
goto :End

:: ============================================================================
:: FUNCTIONS
:: ============================================================================

:CheckIDE
set "BDS_VER=%~1"
set "IDE_NAME_TMP=%~2"
reg query "HKCU\Software\Embarcadero\BDS\%BDS_VER%" /v "RootDir" >nul 2>&1
if %errorlevel%==0 (
    set /a FOUND_IDES+=1
    set "IDE_LIST=!IDE_LIST! %BDS_VER%"
    echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% %IDE_NAME_TMP%
)
goto :eof

:ShowIDEOption
set "OPT_IDX=%~1"
set "OPT_BDS=%~2"
if "%OPT_BDS%"=="24.0" set "OPT_NAME=RAD Studio 11 Alexandria"
if "%OPT_BDS%"=="23.0" set "OPT_NAME=RAD Studio 12 Athens"
if "%OPT_BDS%"=="37.0" set "OPT_NAME=RAD Studio 13 Florence"
echo   %OPT_IDX%. %OPT_NAME%
goto :eof

:GetIDEInfo
set "TARGET_BDS=%~1"
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Embarcadero\BDS\%TARGET_BDS%" /v "RootDir" 2^>nul ^| findstr "RootDir"') do set "IDE_ROOT=%%b"
if "%IDE_ROOT:~-1%"=="\" set "IDE_ROOT=%IDE_ROOT:~0,-1%"
if "%TARGET_BDS%"=="24.0" set "IDE_NAME=RAD Studio 11 Alexandria"
if "%TARGET_BDS%"=="23.0" set "IDE_NAME=RAD Studio 12 Athens"
if "%TARGET_BDS%"=="37.0" set "IDE_NAME=RAD Studio 13 Florence"
goto :eof

:AddToLibraryPath
:: Adds a path to Library Search/Browsing Path if not already present
:: Uses PowerShell to read registry values cleanly (no REG_SZ parsing issues)
set "ALP_PLATFORM=%~1"
set "ALP_VALUENAME=%~2"
set "ALP_NEWPATH=%~3"
set "ALP_KEY=HKCU:\Software\Embarcadero\BDS\%TARGET_BDS%\Library\%ALP_PLATFORM%"
set "ALP_REGKEY=HKCU\Software\Embarcadero\BDS\%TARGET_BDS%\Library\%ALP_PLATFORM%"

:: Read current value via PowerShell (avoids REG_SZ token parsing bug)
set "ALP_CURRENT="
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "(Get-ItemProperty '%ALP_KEY%' -ErrorAction SilentlyContinue).'%ALP_VALUENAME%'"`) do set "ALP_CURRENT=%%a"

:: Check if path already exists (case insensitive)
echo "!ALP_CURRENT!" | findstr /i /c:"%ALP_NEWPATH%" >nul 2>&1
if errorlevel 1 (
    :: Path not found, add it
    if defined ALP_CURRENT (
        set "ALP_NEW=!ALP_CURRENT!;%ALP_NEWPATH%"
    ) else (
        set "ALP_NEW=%ALP_NEWPATH%"
    )
    reg add "%ALP_REGKEY%" /v "%ALP_VALUENAME%" /t REG_SZ /d "!ALP_NEW!" /f >nul 2>&1
    echo   !COLOR_SUCCESS![+]!COLOR_RESET! %ALP_PLATFORM% %ALP_VALUENAME%: added
)
goto :eof

:AddToCppPath
:: Adds a path to C++ Include/Library Path
:: Uses PowerShell to read registry values cleanly (no REG_SZ parsing issues)
set "ACP_PLATFORM=%~1"
set "ACP_VALUENAME=%~2"
set "ACP_NEWPATH=%~3"
set "ACP_KEY=HKCU:\Software\Embarcadero\BDS\%TARGET_BDS%\C++\Paths\%ACP_PLATFORM%"
set "ACP_REGKEY=HKCU\Software\Embarcadero\BDS\%TARGET_BDS%\C++\Paths\%ACP_PLATFORM%"

set "ACP_CURRENT="
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "(Get-ItemProperty '%ACP_KEY%' -ErrorAction SilentlyContinue).'%ACP_VALUENAME%'"`) do set "ACP_CURRENT=%%a"

echo "!ACP_CURRENT!" | findstr /i /c:"%ACP_NEWPATH%" >nul 2>&1
if errorlevel 1 (
    if defined ACP_CURRENT (
        set "ACP_NEW=!ACP_CURRENT!;%ACP_NEWPATH%"
    ) else (
        set "ACP_NEW=%ACP_NEWPATH%"
    )
    reg add "%ACP_REGKEY%" /v "%ACP_VALUENAME%" /t REG_SZ /d "!ACP_NEW!" /f >nul 2>&1
)
goto :eof

:Error
echo.
echo %COLOR_ERROR%Installation FAILED!%COLOR_RESET%
echo.
pause
exit /b 1

:Cancelled
echo.
echo Installation cancelled.
pause
exit /b 0

:End
pause
exit /b 0
