@echo off
cd /d "%~dp0"
for %%* in (.) do set foldercheck=%%~nx*
set fmiver=1.9.6
title Sonic Forces Mod Installer %fmiver%

if not exist sfmi.config (
echo set cfgversion=1.9.1 >>sfmi.config

echo ::DEBUG:: >>sfmi.config
echo set Debug_Startup=False >>sfmi.config
echo set SkipHMMNotice=True >>sfmi.config

echo ::PLUGINS:: >>sfmi.config
echo set InstalledModsWindow=False >>sfmi.config
)

rename sfmi.config sfmi.bat
call sfmi.bat
rename sfmi.bat sfmi.config
if /i %InstalledModsWindow% EQU True if not exist ".\sfmiplugins\ModsWindow.bat" (
set InstalledModsWindow=False
)

if /i %debug_startup% EQU true (goto runasdebug)
if /i %debug_startup% EQU false (goto nodebug)


:runasdebug
if /I "%foldercheck%" EQU "SonicForces" goto debugrootfolder
if /I "%foldercheck%" EQU "exec" goto debugexecfolder
if /I "%foldercheck%" NEQ "SonicForces" if /I "%foldercheck%" NEQ "exec" (
set worklocation=INCOMPATIBLE\
set workmode=NONE
goto debugend
)

:debugexecfolder
cd ..
cd ..
cd ..
cd ..
title Sonic Forces Mod Installer %fmiver% (Exec Folder Mode)
set worklocation=.\build\main\projects\exec\
set workmode=EXEC
goto debugend
::Game Root Folder Mode
:debugrootfolder
set worklocation=
title Sonic Forces Mod Installer %fmiver% (Root Folder Mode)
set workmode=ROOT
goto debugend


:debugend
cls
set debug_startup=TRUE
echo You're starting SFMI in debug mode...
echo Proceed?
set /p answer=(Y/N)
if /i %answer% EQU Y (goto debugproceed)
if /i %answer% EQU N (set debug_startup=FALSE)

:debugproceed
cls
if /i %debug_startup% EQU true (goto status)
if /i %debug_startup% EQU false (goto fmibegin)



:nodebug
if /I "%foldercheck%" EQU "system32" goto noadmin
if /I "%foldercheck%" EQU "SonicForces" (goto rootfolder)
if /I "%foldercheck%" EQU "exec" (goto execfolder)
if /I "%foldercheck%" NEQ "SonicForces" if /I "%foldercheck%" NEQ "exec" (
  echo ERROR [CODE 01]
  echo ----------
  echo This bat file/mod folder isn't in a compatible folder.
  echo Please put this file/folder in the SonicForces or the exec folder and try again.
  pause >nul
  exit
)

:execfolder
cd ..
cd ..
cd ..
cd ..
title Sonic Forces Mod Installer %fmiver% (Exec Folder Mode)
set worklocation=.\build\main\projects\exec\
set workmode=EXEC
goto fmibegin
::Game Root Folder Mode
:rootfolder
set worklocation=
title Sonic Forces Mod Installer %fmiver% (Root Folder Mode)
set workmode=ROOT
goto fmibegin

:fmibegin
if not exist "%worklocation%PackCPK.exe" (
  echo ERROR [CODE 04]
  echo ----------
  echo Could not find PackCPK.exe!
  pause >nul
  exit
)

if not exist "%worklocation%CpkMaker.dll" (
  echo ERROR [CODE 03]
  echo ----------
  echo Could not find CpkMaker.dll!
  echo Please get CpkMaker.dll from this archive and extract it to the this folder:
  echo https://goo.gl/8Gs5jx
  pause >nul
  exit
)

if exist ".\build\main\projects\exec\d3d11.dll" if exist ".\build\main\projects\exec\HedgeModManager.exe" if /i %SkipHMMNotice% EQU False (
  echo WARNING [CODE 05]
  echo ----------
  echo An instalation of the HedgeModManager code loader 
  echo was detected. Please uninstall the code loader 
  echo to avoid conflicts. 
  echo. 
  echo Press any key to proceed anyway 
  pause >nul
)

md %worklocation%mods
md .\image\x64\disk\mod_installer\
echo Do not delete these folders! These serve as cache for the mod installer! > .\image\x64\disk\mod_installer\readme.txt
if not exist ".\build\main\projects\exec\CpkMaker.dll" if exist ".\build\main\projects\exec\HedgeModManager.exe" (
xcopy /y "CpkMaker.dll" ".\build\main\projects\exec\"
)
cls

if "%~1" EQU "" goto normal


:dragdrop
set confirm=
if not exist %~1\mod.ini (
  cls
  echo Not a valid mod folder.
  echo Forgot to create mod.ini?
  pause >nul
  exit
)

if exist (%~1\sfmi.ini) (
  for /f "tokens=1,2 delims==" %%a in (%~1\sfmi.ini) do (
  if /I %%a==cpk set cpk=%%b
)

  for /f "tokens=1,2 delims==" %%a in (%~1\sfmi.ini) do (
  if /I %%a==custominstall set custom=%%b
)

  for /f "tokens=1,2 delims==" %%a in (%~1\sfmi.ini) do (
  if /I %%a==custominstallbat set custombat=%%b
)
) else (
set cpk=wars_patch
set custom=false
set custombat=
)

  if "%~1" EQU "" (goto normal)
  for /f "tokens=1,2 delims==" %%a in (%~1\mod.ini) do (
  if /I %%a==title set title=%%b
)
  
  for /f "tokens=1,2 delims==" %%a in (%~1\mod.ini) do (
  if /I %%a==author set author=%%b
)

  if exist "%~1/disk/*.cpk"


  echo Do you want to install %title% by %author%?
  echo (Installs to %cpk%)
  echo.
  set /p confirm=(Y/N)
  if "%confirm%" EQU "" goto dragdrop
  if /i %confirm% EQU y goto install
  if /i %confirm% EQU n goto end

:install
echo --------------------------
if not exist ".\image\x64\disk\%cpk%.cpk.backup" (
  echo No backup detected, backing up %cpk%.cpk as %cpk%.cpk.backup...
  echo f|xcopy /y ".\image\x64\disk\%cpk%.cpk" ".\image\x64\disk\%cpk%.cpk.backup" >nul
) else (
  echo Backup of %cpk%.cpk already detected, proceeding instalation...
  echo You have 7 seconds to close this window if this is wrong...
  echo.
  echo If you already installed mods with this, just press any key
  timeout /t 7 >nul
)
echo --------------------------

if /I %custom% EQU true (
  goto custom
  )

echo --------------------------
if exist "%~1\disk\*.cpk" (
echo CPK mod detected. Extracting files...
for %%x in (%~1\disk\*.cpk) do (
  set "cpkinstallation=%%x"
  goto CPKProceedDD
)
:CPKProceedDD
%worklocation%packcpk %cpkinstallation%
echo IF THIS LOOKS STUCK, DON'T DO ANYTHING! IT ISN'T!
  if not exist "image\x64\disk\mod_installer\wars_modinstaller_%cpk%" (
  %worklocation%packcpk ".\image\x64\disk\%cpk%.cpk"
  rename %cpk% wars_modinstaller_%cpk%
  move wars_modinstaller_%cpk% ".\image\x64\disk\mod_installer\" >nul
) else (
  echo Extracted files already found, skipping extraction...
)
echo --------------------------
echo IF THIS LOOKS STUCK, DON'T DO ANYTHING! IT ISN'T!
%worklocation%PackCPK ".\image\x64\disk\mod_installer\wars_modinstaller_%cpk%" ".\image\x64\disk\%cpk%"
echo --------------------------
echo %title% >> %worklocation%mods\SFMIModsDB.ini
echo Done! Press any key to exit!
pause >nul
exit
)

echo IF THIS LOOKS STUCK, DON'T DO ANYTHING! IT ISN'T!
  if not exist "image\x64\disk\mod_installer\wars_modinstaller_%cpk%" (
  %worklocation%packcpk ".\image\x64\disk\%cpk%.cpk"
  rename %cpk% wars_modinstaller_%cpk%
  move wars_modinstaller_%cpk% ".\image\x64\disk\mod_installer\" >nul
) else (
  echo Extracted files already found, skipping extraction...
)
echo --------------------------
echo Copying files...
xcopy /s /y "%~1\disk\%cpk%" ".\image\x64\disk\mod_installer\wars_modinstaller_%cpk%" >nul
echo --------------------------
echo IF THIS LOOKS STUCK, DON'T DO ANYTHING! IT ISN'T!
%worklocation%PackCPK ".\image\x64\disk\mod_installer\wars_modinstaller_%cpk%" ".\image\x64\disk\%cpk%"
echo --------------------------
echo %title% >> %worklocation%mods\SFMIModsDB.ini
echo Done! Press any key to exit!
pause >nul
exit

:normal
cls
echo Loading mod list...
if /i %foldercheck% equ SonicForces (
cd mods
for /r %%a in (.) do @if exist "%%~fa\mod.ini" echo %%~nxa >nul
cd ..
)
if /i %foldercheck% equ exec (
cd %worklocation%mods
for /r %%a in (.) do @if exist "%%~fa\mod.ini" echo %%~nxa >nul
cd ..
cd ..
cd ..
cd ..
cd ..
)
if /i "%debug_startup%" equ "NO" (goto normalnodebug)
if /i %debug_startup% EQU true (goto :eof)
:normalnodebug
set modfoldernormal=
md %worklocation%mods
md .\image\x64\disk\mod_installer\
echo Do not delete these folders! These serve as cache for the mod installer! > .\image\x64\disk\mod_installer\readme.txt
cls
if not exist "mods" (md mods)
if "%InstalledModsWindow%" EQU "" (
start %worklocation%\sfmiplugins\ModsWindow.bat
set InstalledModsWindow=false
)

if /i "%InstalledModsWindow%" EQU "True" (
start %worklocation%\sfmiplugins\ModsWindow.bat
set InstalledModsWindow=false
)
echo Type the mod folder to install that mod
echo Type "!delete" to uninstall all currently installed mods
echo Type "!refresh" to refresh the mod list
echo Type "!check" to check currently installed mods
echo.
echo Mods available in the "mods" folder
echo ------------------------------------
::dir .\mods /ad /b
if /i %foldercheck% equ SonicForces (
cd mods
for /r %%a in (.) do @if exist "%%~fa\mod.ini" echo %%~nxa
cd ..
)
if /i %foldercheck% equ exec (
cd %worklocation%mods
for /r %%a in (.) do @if exist "%%~fa\mod.ini" echo %%~nxa
cd ..
cd ..
cd ..
cd ..
cd ..
)
echo ------------------------------------
echo.
set /p modfoldernormal=Mod folder: 
if /i "%modfoldernormal%" EQU "" (goto normal) 
if /i "%modfoldernormal%" EQU "!delete" (goto uninstall)
if /i "%modfoldernormal%" EQU "!uninstall" (goto uninstall)
if /i "%modfoldernormal%" EQU "!refresh" (goto normal)
if /i "%modfoldernormal%" EQU "!check" (goto check)
if /i "%modfoldernormal%" EQU "!status" (goto status)
if /i "%modfoldernormal%" EQU "!debug" (goto status)
if /i "%modfoldernormal%" EQU "!exit" (exit)

if exist (%worklocation%mods\%modfoldernormal%\sfmi.ini) (
  for /f "tokens=1,2 delims==" %%a in (%worklocation%mods\%modfoldernormal%\sfmi.ini) do (
  if /I %%a==cpk set cpk=%%b
)

  for /f "tokens=1,2 delims==" %%a in (%worklocation%mods\%modfoldernormal%\sfmi.ini) do (
  if /I %%a==custominstall set custom=%%b
)

  for /f "tokens=1,2 delims==" %%a in (%worklocation%mods\%modfoldernormal%\sfmi.ini) do (
  if /I %%a==custominstallbat set custombat=%%b
)
) else (
set cpk=wars_patch
set custom=false
set custombat=
)


  for /f "tokens=1,2 delims==" %%a in (%worklocation%mods\%modfoldernormal%\mod.ini) do (
  if /I %%a==title set title=%%b
)

)
  for /f "tokens=1,2 delims==" %%a in (%worklocation%mods\%modfoldernormal%\mod.ini) do (
  if /I %%a==author set author=%%b
)

:confirmnormal
set confirm=
if not exist %worklocation%mods\%modfoldernormal% (
  cls
  echo Could not find the mod's folder.
  echo ----------------------------------
  echo Please check if the folder has any space in the 
  echo name, and if so, please remove it.
  pause >nul
  goto normal
)

if not exist %worklocation%mods\%modfoldernormal%\mod.ini (
  cls
  echo Could not detect mod.ini in the mod's folder.
  pause >nul
  goto normal
)


cls
echo Do you want to install %title% by %author%?
echo (Installs to "%cpk%")
echo.
set /p confirm=(Y/N)
if /i "%confirm%" EQU "" goto confirmnormal
if /i %confirm% EQU Y goto installnormal
if /i %confirm% EQU n goto normal

:installnormal
echo --------------------------
if not exist ".\image\x64\disk\%cpk%.cpk.backup" (
  echo No backup detected, backing up %cpk%.cpk as %cpk%.cpk.backup...
  echo f|xcopy /y ".\image\x64\disk\%cpk%.cpk" ".\image\x64\disk\%cpk%.cpk.backup" >nul
) else (
  echo Backup of %cpk%.cpk already detected, proceeding instalation...
  echo You have 7 seconds to close this window if this is wrong...
  echo.
  echo If you already installed mods with this, just press any key
  timeout /t 7 >nul
)
echo --------------------------

if /i %custom% EQU true (
  goto customnormal
  )

echo --------------------------
if exist "%worklocation%mods\%modfoldernormal%\disk\*.cpk" (
echo CPK mod detected. Extracting files...
for %%x in (%worklocation%mods\%modfoldernormal%\disk\*.cpk) do (
  set "cpkinstallation=%%x"
  goto CPKProceed
)
:cpkproceed
%worklocation%packcpk %cpkinstallation%
echo IF THIS LOOKS STUCK, DON'T DO ANYTHING! IT ISN'T!
  if not exist "image\x64\disk\mod_installer\wars_modinstaller_%cpk%" (
  %worklocation%packcpk ".\image\x64\disk\%cpk%.cpk"
  rename %cpk% wars_modinstaller_%cpk%
  move wars_modinstaller_%cpk% ".\image\x64\disk\mod_installer\" >nul
) else (
  echo Extracted files already found, skipping extraction...
)
echo --------------------------
echo IF THIS LOOKS STUCK, DON'T DO ANYTHING! IT ISN'T!
%worklocation%PackCPK ".\image\x64\disk\mod_installer\wars_modinstaller_%cpk%" ".\image\x64\disk\%cpk%"
echo --------------------------
echo %title% >> %worklocation%mods\SFMIModsDB.ini
echo Done! Press any key to exit!
pause >nul
exit
)


if not exist "image\x64\disk\mod_installer\wars_modinstaller_%cpk%" (
  echo IF THIS LOOKS STUCK, DON'T DO ANYTHING! IT ISN'T!
  %worklocation%packcpk ".\image\x64\disk\%cpk%.cpk"
  rename %cpk% wars_modinstaller_%cpk%
  move wars_modinstaller_%cpk% ".\image\x64\disk\mod_installer\" >nul
) else (
  echo Extracted files already found, skipping extraction...
)
echo --------------------------
echo Copying files...
xcopy /s /y "%worklocation%mods\%modfoldernormal%\disk\%cpk%" ".\image\x64\disk\mod_installer\wars_modinstaller_%cpk%" >nul
echo --------------------------
echo IF THIS LOOKS STUCK, DON'T DO ANYTHING! IT ISN'T!
%worklocation%PackCPK ".\image\x64\disk\mod_installer\wars_modinstaller_%cpk%" ".\image\x64\disk\%cpk%"
echo --------------------------
echo %title% >> %worklocation%mods\SFMIModsDB.ini
echo Done! Press any key to exit!
pause >nul
exit

:custom
call "%~1\%custombat%"
exit

:customnormal
call "mods\%modfoldernormal%\%custombat%"
exit

:check
cls
echo Currently installed mods:
echo ---------
if not exist "%worklocation%mods\sfmimodsdb.ini" (
  echo No mods are currently installed
) else (
type %worklocation%mods\sfmimodsdb.ini
)
echo ---------
echo Press any key to go back to the menu...
pause >nul
goto normal

:status
if exist ".\build\main\projects\exec\d3d11.dll" if exist ".\build\main\projects\exec\HedgeModManager.exe" (
set HMMInstall=TRUE
) else (
set HMMInstall=FALSE
)

if not exist "%worklocation%mods\sfmimodsdb.ini" (
set moddatabase=FALSE
) else (
set moddatabase=TRUE
)

if not exist "image\x64\disk\wars_patch.cpk.backup" (
set backupstate=FALSE
) else (
set backupstate=TRUE [wars_patch.cpk.backup]
)


if not exist %worklocation%cpkmaker.dll (
set cpkmakerdll=FALSE
) else (
set cpkmakerdll=TRUE
)

if exist .\build\main\projects\exec\steamclient64.dll (
set crackedcopy=TRUE
) else (
set crackedcopy=FALSE
)

if exist .\build\main\projects\exec\steamclient64.dll if exist .\build\main\projects\exec\cpy.ini (
set crackedcopy=TRUE [WITH INI]
)

if not exist %worklocation%PackCPK.exe (
set PackCPKexe=FALSE
) else (
set PackCPKexe=TRUE
)
if /I "%foldercheck%" NEQ "SonicForces" if /I "%foldercheck%" NEQ "exec" (
set statfoldercheck=INCOMPATIBLE
) else (
set statfoldercheck=COMPATIBLE
)
:://///////\\\\\\\\\\\
set status_menu=clear
if /i %statfoldercheck% EQU INCOMPATIBLE (
set staterror=01
goto stat_menu)
if /i %PackCPKexe% EQU FALSE if /i %cpkmakerdll% EQU FALSE (
set staterror=02
goto stat_menu)
if /i %PackCPKexe% EQU TRUE if /i %cpkmakerdll% EQU FALSE (
set staterror=03
goto stat_menu)
if /i %PackCPKexe% EQU FALSE if /i %cpkmakerdll% EQU TRUE (
set staterror=04
goto stat_menu)
if /i %HMMInstall% EQU TRUE (
set staterror=05
goto stat_menu)
if /i %HMMInstall% equ false if /i %packcpkexe% equ true if /i %cpkmakerdll% equ true (
set staterror=00
goto stat_menu)
:stat_menu
cls
echo SFMI VERSION=%fmiver%
echo CONFIG FILE VERSION=%cfgversion%
echo DEBUG_STARTUP=%debug_startup%
echo.
color 17
echo|set /p=STATUS=
if "%staterror%" EQU "" (powershell write-host -foreground red UNKNOWN_ERROR)
if %staterror% EQU 00 (powershell write-host -foreground green OK//CODE=00)
if %staterror% EQU 01 (powershell write-host -foreground red ERROR//CODE=01)
if %staterror% EQU 02 (powershell write-host -foreground red ERROR//CODE=02)
if %staterror% EQU 03 (powershell write-host -foreground red ERROR//CODE=03)
if %staterror% EQU 04 (powershell write-host -foreground red ERROR//CODE=04)
if %staterror% EQU 05 (powershell write-host -foreground yellow OK//CODE=05)
echo TYPE !CODEINFO FOR CODE DESCRIPTION
echo ---------
echo HMM Instalation: %HMMInstall%
echo Instalation Mode: %workmode% (%worklocation%)
echo SFMI Mod Database: %moddatabase%
echo Backup CPK: %backupstate%
echo CpkMaker.dll: %cpkmakerdll%
echo PackCPK.exe: %packcpkexe%
echo Folder Check Status: %statfoldercheck% [%foldercheck%]
echo Cracked Copy: %crackedcopy%
echo ---------
echo INSTALLED MODS:
) else (
if /i "%moddatabase%" EQU "false" (
echo /MOD DATABASE NON EXISTANT\
) else (
type %worklocation%mods\sfmimodsdb.ini
)
set /p status_menu=
if /i %status_menu% EQU !CODEINFO goto codeinfo
if /i %status_menu% EQU clear (
color 7
goto normal
)
:codeinfo
cls
echo ERROR//CODE=01
echo You're running the installed from an incompatible folder. Try and install it in either
echo the "exec" folder, or in the SonicForces folder.
echo.
echo ERROR//CODE=02
echo You don't have both PackCPK.exe nor CpkMaker.dll. Please put those files in the same
echo folder as the bat installer and try again.
echo.
echo ERROR//CODE=03
echo You don't have CpkMaker.dll. Please put that file in the same folder as the bat installer and
echo try again.
echo.
echo ERROR//CODE=04
echo You don't have PackCPK.exe. Please put that file in the same folder as the bat installer and
echo try again.
echo.
echo OK//CODE=05
echo You have HedgeModManager installed. The mod installer can work, but some mods may work incorrectly
echo this way.
echo.
echo OK//CODE=00
echo Everything is working as it should!
pause >nul
goto status

:uninstall
cls
echo Currently installed mods:
echo ---------
if not exist "%worklocation%mods\sfmimodsdb.ini" (
  echo No mods are currently installed
) else (
type "%worklocation%mods\sfmimodsdb.ini"
)
echo ---------
echo This will uninstall all of your currently installed mods
set /p answer=Proceed (Y/N): 
if /i %answer% equ y goto uninstallyes
goto normal

:uninstallyes
if not exist "image\x64\disk\wars_patch.cpk.backup" (
echo ERROR
echo No backup of wars_patch.cpk detected [wars_patch.cpk.backup]!
echo Without a backup, the uninstaller cannot proceed.
pause >nul
goto normal
)

echo Uninstalling mods...
del image\x64\disk\wars_patch.cpk
ren image\x64\disk\wars_patch.cpk.backup wars_patch.cpk
del /q "image\x64\disk\mod_installer\*"
FOR /D %%p IN ("image\x64\disk\mod_installer\*.*") DO rmdir "%%p" /s /q
del /q %worklocation%mods\sfmimodsdb.ini
echo.
echo Done! Press any key to go back to the menu
pause >nul
goto normal


:noadmin
  cls
  echo ERROR
  echo ----------
  echo This script cannot be run with administrator privileges!
  pause >nul
  exit


:end