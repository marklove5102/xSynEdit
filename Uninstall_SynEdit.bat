@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================================
:: xSynEdit 2025.03 Uninstaller for RAD Studio
:: ============================================================================
:: Removes: Win32, Win64, Win64x packages
:: Unregisters: Both 32-bit and 64-bit IDE
:: ============================================================================

title xSynEdit 2025.03 Uninstaller

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

set "RUNTIME_PKG=SynEditDR"
set "DESIGNTIME_PKG=SynEditDD"

set "BACKUP_DIR=%SYNEDIT_ROOT%\Backups"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo.
echo %COLOR_CYAN%============================================================================%COLOR_RESET%
echo %COLOR_CYAN%              xSynEdit 2025.03 Uninstaller for RAD Studio%COLOR_RESET%
echo %COLOR_CYAN%============================================================================%COLOR_RESET%
echo %COLOR_WHITE%  Removes: Win32, Win64, Win64x packages%COLOR_RESET%
echo %COLOR_WHITE%  Unregisters: Both 32-bit and 64-bit IDE%COLOR_RESET%
echo %COLOR_CYAN%============================================================================%COLOR_RESET%
echo.

:: ============================================================================
:: STEP 1: Detect installed RAD Studio versions
:: ============================================================================
echo %COLOR_INFO%[1/5] Detecting installed RAD Studio versions...%COLOR_RESET%
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
echo Found %FOUND_IDES% IDE installation^(s^).
echo.

:: ============================================================================
:: STEP 2: Select IDE version
:: ============================================================================
echo %COLOR_INFO%[2/5] Select RAD Studio version to uninstall from:%COLOR_RESET%
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
echo %COLOR_WARN%Selected: %IDE_NAME% ^(BDS %TARGET_BDS%^)%COLOR_RESET%
echo.

:: Confirm uninstall
echo %COLOR_ERROR%WARNING: This will remove ALL SynEdit components from this IDE!%COLOR_RESET%
echo.
echo   This includes:
echo     - Win32 packages
echo     - Win64 packages
echo     - Win64x packages
echo     - All BPL, DCP files
echo     - IDE registrations ^(32-bit and 64-bit^)
echo.
set /p "CONFIRM=Are you sure you want to continue? (y/n): "
if /i not "%CONFIRM%"=="y" goto :Cancelled

:: ============================================================================
:: Create registry backup
:: ============================================================================
echo.
echo %COLOR_INFO%Creating registry backup before uninstall...%COLOR_RESET%

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "DATETIME=%%I"
set "TIMESTAMP=%DATETIME:~0,4%-%DATETIME:~4,2%-%DATETIME:~6,2%_%DATETIME:~8,2%-%DATETIME:~10,2%-%DATETIME:~12,2%"
set "BACKUP_FILE=%BACKUP_DIR%\BDS_%TARGET_BDS%_BEFORE_uninstall_%TIMESTAMP%.reg"

reg export "HKCU\Software\Embarcadero\BDS\%TARGET_BDS%" "%BACKUP_FILE%" /y >nul 2>&1
if errorlevel 1 (
    echo   %COLOR_WARN%[WARN]%COLOR_RESET% Could not create registry backup
) else (
    echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% Backup saved to: %BACKUP_FILE%
)

:: ============================================================================
:: STEP 3: Unregister from IDE
:: ============================================================================
echo.
echo %COLOR_INFO%[3/5] Unregistering packages from IDE...%COLOR_RESET%
echo.

set "PUBLIC_DOCS=C:\Users\Public\Documents\Embarcadero\Studio\%TARGET_BDS%"
set "BPL_WIN32=%PUBLIC_DOCS%\Bpl"
set "DCP_WIN32=%PUBLIC_DOCS%\Dcp"
set "BPL_WIN64=%PUBLIC_DOCS%\Bpl\Win64"
set "DCP_WIN64=%PUBLIC_DOCS%\Dcp\Win64"
set "BPL_WIN64X=%PUBLIC_DOCS%\Bpl\Win64x"
set "DCP_WIN64X=%PUBLIC_DOCS%\Dcp\Win64x"

set "BDS_SUFFIX=%TARGET_BDS:.=%"
set "BDS_SUFFIX=%BDS_SUFFIX:~0,3%"

set "REG_KEY=HKCU\Software\Embarcadero\BDS\%TARGET_BDS%"

:: Unregister from 32-bit IDE
set "DESIGNTIME_BPL_32=%BPL_WIN32%\%DESIGNTIME_PKG%%BDS_SUFFIX%.bpl"
echo %COLOR_CYAN%--- Unregistering from 32-bit IDE ---%COLOR_RESET%
reg delete "%REG_KEY%\Known Packages" /v "%DESIGNTIME_BPL_32%" /f >nul 2>&1
if %errorlevel%==0 (
    echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% Removed from Known Packages
) else (
    echo   %COLOR_WARN%[--]%COLOR_RESET% Was not registered in 32-bit IDE
)

:: Unregister from 64-bit IDE
set "DESIGNTIME_BPL_64=%BPL_WIN64%\%DESIGNTIME_PKG%%BDS_SUFFIX%.bpl"
echo.
echo %COLOR_CYAN%--- Unregistering from 64-bit IDE ---%COLOR_RESET%
reg delete "%REG_KEY%\Known Packages x64" /v "%DESIGNTIME_BPL_64%" /f >nul 2>&1
if %errorlevel%==0 (
    echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% Removed from Known Packages x64
) else (
    echo   %COLOR_WARN%[--]%COLOR_RESET% Was not registered in 64-bit IDE
)

:: ============================================================================
:: STEP 4: Delete compiled files
:: ============================================================================
echo.
echo %COLOR_INFO%[4/5] Deleting compiled files...%COLOR_RESET%
echo.

:: Win32 files
echo %COLOR_CYAN%--- Win32 files ---%COLOR_RESET%
call :DeleteFile "%BPL_WIN32%\%RUNTIME_PKG%%BDS_SUFFIX%.bpl"
call :DeleteFile "%BPL_WIN32%\%DESIGNTIME_PKG%%BDS_SUFFIX%.bpl"
call :DeleteFile "%DCP_WIN32%\%RUNTIME_PKG%.dcp"
call :DeleteFile "%DCP_WIN32%\%DESIGNTIME_PKG%.dcp"

:: Win64 files
echo.
echo %COLOR_CYAN%--- Win64 files ---%COLOR_RESET%
call :DeleteFile "%BPL_WIN64%\%RUNTIME_PKG%%BDS_SUFFIX%.bpl"
call :DeleteFile "%BPL_WIN64%\%DESIGNTIME_PKG%%BDS_SUFFIX%.bpl"
call :DeleteFile "%BPL_WIN64%\%RUNTIME_PKG%%BDS_SUFFIX%.rsm"
call :DeleteFile "%BPL_WIN64%\%DESIGNTIME_PKG%%BDS_SUFFIX%.rsm"
call :DeleteFile "%DCP_WIN64%\%RUNTIME_PKG%.dcp"
call :DeleteFile "%DCP_WIN64%\%DESIGNTIME_PKG%.dcp"

:: Win64x files
echo.
echo %COLOR_CYAN%--- Win64x files ---%COLOR_RESET%
call :DeleteFile "%BPL_WIN64X%\%RUNTIME_PKG%%BDS_SUFFIX%.bpl"
call :DeleteFile "%BPL_WIN64X%\%DESIGNTIME_PKG%%BDS_SUFFIX%.bpl"
call :DeleteFile "%BPL_WIN64X%\%RUNTIME_PKG%%BDS_SUFFIX%.rsm"
call :DeleteFile "%BPL_WIN64X%\%DESIGNTIME_PKG%%BDS_SUFFIX%.rsm"
call :DeleteFile "%DCP_WIN64X%\%RUNTIME_PKG%.dcp"
call :DeleteFile "%DCP_WIN64X%\%DESIGNTIME_PKG%.dcp"

:: Clean DCU files
echo.
echo %COLOR_CYAN%--- Cleaning DCU files ---%COLOR_RESET%
del /f /q "%DCP_WIN32%\Syn*.dcu" 2>nul && echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% Cleaned Win32 DCU files || echo   %COLOR_WARN%[--]%COLOR_RESET% No Win32 DCU files
del /f /q "%DCP_WIN64%\Syn*.dcu" 2>nul && echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% Cleaned Win64 DCU files || echo   %COLOR_WARN%[--]%COLOR_RESET% No Win64 DCU files
del /f /q "%DCP_WIN64X%\Syn*.dcu" 2>nul && echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% Cleaned Win64x DCU files || echo   %COLOR_WARN%[--]%COLOR_RESET% No Win64x DCU files

:: ============================================================================
:: STEP 5: Remove Library Paths
:: ============================================================================
echo.
echo %COLOR_INFO%[5/5] Removing Library Paths...%COLOR_RESET%
echo.

set /p "REMOVE_PATHS=Remove SynEdit paths from Library configuration? (y/n): "
if /i "%REMOVE_PATHS%"=="y" (
    echo.
    call :RemoveFromLibraryPath "Win32" "Search Path"
    call :RemoveFromLibraryPath "Win32" "Browsing Path"
    call :RemoveFromLibraryPath "Win64" "Search Path"
    call :RemoveFromLibraryPath "Win64" "Browsing Path"
    call :RemoveFromLibraryPath "Win64x" "Search Path"
    call :RemoveFromLibraryPath "Win64x" "Browsing Path"
    echo.
    echo   Removing C++ paths...
    :: Win32
    call :RemoveFromCppPath "Win32" "IncludePath"
    call :RemoveFromCppPath "Win32" "IncludePath_Clang32"
    call :RemoveFromCppPath "Win32" "LibraryPath"
    call :RemoveFromCppPath "Win32" "LibraryPath_Clang32"
    :: Win64
    call :RemoveFromCppPath "Win64" "IncludePath"
    call :RemoveFromCppPath "Win64" "LibraryPath"
    :: Win64x
    call :RemoveFromCppPath "Win64x" "IncludePath"
    call :RemoveFromCppPath "Win64x" "LibraryPath"
)

:: ============================================================================
:: Create post-uninstall backup
:: ============================================================================
echo.
echo Creating post-uninstall registry backup...
set "BACKUP_FILE_AFTER=%BACKUP_DIR%\BDS_%TARGET_BDS%_AFTER_uninstall_%TIMESTAMP%.reg"
reg export "HKCU\Software\Embarcadero\BDS\%TARGET_BDS%" "%BACKUP_FILE_AFTER%" /y >nul 2>&1
echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% Backup saved to: %BACKUP_FILE_AFTER%

:: ============================================================================
:: Done!
:: ============================================================================
echo.
echo %COLOR_SUCCESS%============================================================================%COLOR_RESET%
echo %COLOR_SUCCESS%              Uninstallation completed successfully!%COLOR_RESET%
echo %COLOR_SUCCESS%============================================================================%COLOR_RESET%
echo.
echo %COLOR_WHITE%Removed:%COLOR_RESET%
echo   - Win32 packages ^(BPL, DCP^)
echo   - Win64 packages ^(BPL, DCP^)
echo   - Win64x packages ^(BPL, DCP^)
echo   - IDE registrations ^(32-bit and 64-bit^)
echo.
echo %COLOR_WHITE%Registry backups:%COLOR_RESET%
echo   Before: %BACKUP_FILE%
echo   After:  %BACKUP_FILE_AFTER%
echo.
echo %COLOR_WARN%================================================================%COLOR_RESET%
echo %COLOR_WARN%  IMPORTANT: Restart RAD Studio for changes to take effect!%COLOR_RESET%
echo %COLOR_WARN%================================================================%COLOR_RESET%
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

:DeleteFile
set "FILE_PATH=%~1"
if exist "%FILE_PATH%" (
    del /f "%FILE_PATH%" 2>nul
    if errorlevel 1 (
        echo   %COLOR_WARN%[WARN]%COLOR_RESET% Could not delete: %~nx1
    ) else (
        echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% Deleted: %~nx1
    )
) else (
    echo   %COLOR_WARN%[--]%COLOR_RESET% Not found: %~nx1
)
goto :eof

:RemoveFromLibraryPath
:: Removes SynEdit paths from Library configuration
set "RLP_PLATFORM=%~1"
set "RLP_VALUENAME=%~2"
set "RLP_KEY=HKCU\Software\Embarcadero\BDS\%TARGET_BDS%\Library\%RLP_PLATFORM%"
set "RLP_TEMPFILE=%TEMP%\regvalue_%RANDOM%.txt"

:: Read current value safely
reg query "%RLP_KEY%" /v "%RLP_VALUENAME%" 2>nul | findstr /c:"%RLP_VALUENAME%" > "%RLP_TEMPFILE%"
set "RLP_CURRENT="
for /f "usebackq tokens=2,*" %%a in ("%RLP_TEMPFILE%") do set "RLP_CURRENT=%%b"
del "%RLP_TEMPFILE%" 2>nul

if defined RLP_CURRENT (
    set "RLP_NEW=!RLP_CURRENT!"

    :: Remove our paths (with and without trailing semicolon)
    set "RLP_NEW=!RLP_NEW:%SOURCE_DIR%;=!"
    set "RLP_NEW=!RLP_NEW:%HIGHLIGHTERS_DIR%;=!"
    set "RLP_NEW=!RLP_NEW:%SOURCE_DIR%=!"
    set "RLP_NEW=!RLP_NEW:%HIGHLIGHTERS_DIR%=!"

    :: Clean up double semicolons and trailing semicolons
    set "RLP_NEW=!RLP_NEW:;;=;!"
    if "!RLP_NEW:~-1!"==";" set "RLP_NEW=!RLP_NEW:~0,-1!"

    :: Update registry
    reg add "%RLP_KEY%" /v "%RLP_VALUENAME%" /t REG_SZ /d "!RLP_NEW!" /f >nul 2>&1
    echo   %COLOR_SUCCESS%[OK]%COLOR_RESET% %RLP_PLATFORM% %RLP_VALUENAME%: cleaned
) else (
    echo   %COLOR_WARN%[--]%COLOR_RESET% %RLP_PLATFORM% %RLP_VALUENAME%: not found
)
goto :eof

:RemoveFromCppPath
:: Removes SynEdit paths from C++ configuration (both Debug and Release)
set "RCP_PLATFORM=%~1"
set "RCP_VALUENAME=%~2"
set "RCP_KEY=HKCU\Software\Embarcadero\BDS\%TARGET_BDS%\C++\Paths\%RCP_PLATFORM%"
set "RCP_TEMPFILE=%TEMP%\regvalue_%RANDOM%.txt"
set "RCP_CPPPATH_DEBUG=%SYNEDIT_ROOT%\Packages\11AndAbove\cpp\%RCP_PLATFORM%\Debug"
set "RCP_CPPPATH_RELEASE=%SYNEDIT_ROOT%\Packages\11AndAbove\cpp\%RCP_PLATFORM%\Release"

reg query "%RCP_KEY%" /v "%RCP_VALUENAME%" 2>nul | findstr /c:"%RCP_VALUENAME%" > "%RCP_TEMPFILE%"
set "RCP_CURRENT="
for /f "usebackq tokens=2,*" %%a in ("%RCP_TEMPFILE%") do set "RCP_CURRENT=%%b"
del "%RCP_TEMPFILE%" 2>nul

if defined RCP_CURRENT (
    set "RCP_NEW=!RCP_CURRENT!"
    :: Remove Debug paths
    set "RCP_NEW=!RCP_NEW:%RCP_CPPPATH_DEBUG%;=!"
    set "RCP_NEW=!RCP_NEW:%RCP_CPPPATH_DEBUG%=!"
    :: Remove Release paths
    set "RCP_NEW=!RCP_NEW:%RCP_CPPPATH_RELEASE%;=!"
    set "RCP_NEW=!RCP_NEW:%RCP_CPPPATH_RELEASE%=!"
    :: Clean up
    set "RCP_NEW=!RCP_NEW:;;=;!"
    if "!RCP_NEW:~-1!"==";" set "RCP_NEW=!RCP_NEW:~0,-1!"

    reg add "%RCP_KEY%" /v "%RCP_VALUENAME%" /t REG_SZ /d "!RCP_NEW!" /f >nul 2>&1
)
goto :eof

:Error
echo.
echo %COLOR_ERROR%Uninstallation FAILED!%COLOR_RESET%
echo.
pause
exit /b 1

:Cancelled
echo.
echo Uninstallation cancelled.
pause
exit /b 0

:End
pause
exit /b 0
