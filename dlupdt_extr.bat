@echo off
color 0A
title Kaspersky Rescue Disk 18 Updater on USB
echo:
echo:
echo  Kaspersky Rescue Disk 18 Updater by Edoardo                 
echo     (based on the Rosenstein Kaspersky-Rescue-Disk18-Updater)
echo:
echo:
echo:
echo:
echo:

:START
if not exist .\Tools\curl.exe goto ce
if not exist .\Tools\curl-ca-bundle.crt goto cc
:: Get letter of device
set /p letvol1="Get letter of KRD device:  "
set letvol2=%letvol1%:
for /f %%D IN ('wmic volume get DriveLetter') DO (IF %%D EQU %letvol2% (set usb=%letvol2%))
color 0C
IF %usb% EQU 0 (echo Volume %letvol2% doesn't exist
goto :end)
echo
color 0E
if not exist %usb%\krd_version.txt goto y
if exist .\042-freshbases.srm del .\042-freshbases.srm
if exist .\hashes.txt del .\hashes.txt
if exist .\005-bases.srm del .\005-bases.srm
if exist .\005-bases.srm.sha512 del .\005-bases.srm.sha512
if exist .\krd.xml del .\krd.xml

:: Check krd version
.\Tools\curl -# -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2018/bases/krd.xml" > nul 2>&1
FOR /F delims^=^"^ tokens^=2 %%G IN ('findstr /R /C:"\<version\>" "krd.xml"')  DO set xmlver=%%G
FOR /F delims^=^"^ tokens^=2 %%G IN ('findstr /R /C:"\<system_patch\>" "krd.xml"')  DO set xmlpatch=%%G
for /f "tokens=4 delims=() " %%F IN ('findstr /L "Kaspersky" "%usb%\krd_version.txt"') do set isover=%%F
for /f "tokens=5 delims=() " %%F IN ('findstr /L "Kaspersky" "%usb%\krd_version.txt"') do set isopatch=%%F
goto :check

:CONTINUE
echo:
echo OK! Updating virus definitions for the KRD on the disk...
echo:
echo:
Title Downloading fresh bases
echo Downloading fresh bases for Kaspersky Rescue Disk
echo:
.\Tools\curl -# -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2018/bases/042-freshbases.srm"
.\Tools\curl -# -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2018/bases/hashes.txt"
echo:
echo Renaming files!
ren "042-freshbases.srm" "005-bases.srm" > nul 2>&1
for /f "tokens=1" %%i in ('FINDSTR /L "042-freshbases.srm" "hashes.txt"') do echo %%i *005-bases.srm> 005-bases.srm.sha512
echo:
echo:

:: Update files
title Copying Updated Virus Definition Files to your Rescue Disk
echo Copying Updated Virus Definition Base to your Rescue Disk
copy /y .\005-bases.srm %usb%\data\005-bases.srm > nul
copy /y .\005-bases.srm.sha512 %usb%\data\005-bases.srm.sha512 > nul
echo:
FOR /F delims^=^"^ tokens^=2 %%G IN ('FINDSTR /L "databases_timestamp" "krd.xml"')  DO ECHO %%G > %usb%\krd_bases_timestamp.txt & echo: & echo Base timestamp is: %%G
echo Updating "krd_bases_timestamp.txt"
echo:
echo:
echo Successfully Copied Updated Definition Files to your Rescue Disk
echo:
echo:
echo NO ERRORS - KRD bases IS UPDATED!
echo:
echo:
del .\005-bases.srm
del .\005-bases.srm.sha512
del .\hashes.txt
del .\krd.xml
echo:
goto :end

:ERR
echo ERROR! Some problem occurred!
pause
goto :end
:ce
echo Missing file  %~dp0Tools\curl.exe.
echo Please re-extract "Tools" folder from downloaded zip file
goto :end
:cc
echo Missing file  %~dp0Tools\curl-ca-bundle.crt.
echo Please re-extract "Tools" folder from downloaded zip file
goto :end
:y
echo !! Kaspersky Rescue Disk Is Not Installed on %usb% Volume !!.
echo:
echo Rescue Disk Will Be Downloaded from:
echo https://rescuedisk.s.kaspersky-labs^.com/updatable/2018/krd.iso
goto :input
:downkrd
echo:
echo:
echo Downloading KRD.iso from Kaspersky Labs server
.\Tools\curl -# -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2018/krd.iso"
echo:
Echo krd.iso has been downloaded. Now extract on device.
if exist .\krd.xml del .\krd.xml
echo:
goto :end
:user_stopped_the_process
echo User stopped the process
goto :end
:not_enough_memory
echo Not enough memory for operation
goto :end
:command_line_error
echo Command line option error
goto :end
:fatal_error
echo A fatal error occurred
goto :end
:ok_warnings
echo Non fatal error(s) occurred
goto :end
:check
IF %xmlver%%xmlpatch% GTR %isover%%isopatch% (
echo:
echo It seems that there is a new version of Kaspersky Rescue Disk available!
echo Version on the disk: %isover%%isopatch% Þ Version on the server: %xmlver%%xmlpatch%
goto :input
) ELSE ( 
goto :continue
)
:input
echo:
echo Would you like to download the new version? (Y / N)
set /p choc=
)
if "%choc%"=="y" goto :downkrd
if "%choc%"=="n" goto :end

:end
pause
goto :EOF
