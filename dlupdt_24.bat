@echo off
@SETLOCAL
pushd "%~dp0"
color 0A
title Kaspersky Rescue Disk 24 Updater
echo ^ ________________________________________________________________
echo ^|                                                                ^|
echo ^| Kaspersky Rescue Disk 24 Updater by Rosenstein                 ^|
echo ^|    (based on the Bharat Balegere's updater from AgniPulse.Com) ^|
echo ^|                                                                ^|
echo ^|                                                                ^|
echo ^| https://github.com/Rosenstein/Kaspersky-Rescue-Disk18-Updater  ^|
echo ^|                                                                ^|
echo ^|                                                                ^|
echo ^|                                                                ^|
echo ^|                                                                ^|
echo ^|________________________________________________________________^|
echo:

:start
if not exist .\Tools\mkisofs.exe goto mkiso
if not exist .\Tools\7z.exe goto x
if not exist .\krd.iso goto y
if exist .\kavrescue rmdir /S /Q .\kavrescue
if exist .\42-freshbases.srm del .\42-freshbases.srm
if exist .\hashes.txt del .\hashes.txt
if exist .\30-bases.srm del .\30-bases.srm
echo Extracting contents of Kaspersky Rescue Disk
Title Extracting Kaspersky Rescue Disk
.\Tools\7z x -o"kavrescue" -bsp2 -y -x"![BOOT]\*.img" "krd.iso" > nul
if errorlevel 255 goto:user_stopped_the_process
if errorlevel 8 goto:not_enough_memory
if errorlevel 7 goto:command_line_error
if errorlevel 2 goto:fatal_error
if errorlevel 1 goto:ok_warnings
echo Kaspersky Files Extracted to %~dp0kavrescue
:: Check krd version
.\Tools\curl -# -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2024/bases/krd.xml" --ca-native > nul 2>&1
for /F delims^=^"^ tokens^=2 %%G IN ('findstr /R /C:"product_version" "krd.xml"') do set xmlver=%%G
for /f "tokens=4 delims=() " %%F IN ('findstr /L "Kaspersky" ".\kavrescue\krd_version.txt"') do set isover=%%F
for /f %%A in (.\kavrescue\krd_bases_timestamp.txt) do set isostamp=%%A
for /F delims^=^"^ tokens^=2 %%H IN ('FINDSTR /L "databases_timestamp" "krd.xml"') do set xmlstamp=%%H
goto :check

:continue
echo:
echo OK! Updating virus definitions for the KRD on the disk...
echo Notice: New files will not be downloaded if they are unchanged on the server
echo Notice: ISO rebuilding will be skipped if database version is unchanged
echo:
echo:
goto :check2
:cont1
Title Downloading fresh bases
echo Downloading fresh bases for Kaspersky Rescue Disk
echo:
.\Tools\curl -# --etag-compare .\Tools\bases_tag.txt --etag-save .\Tools\bases_tag.txt -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2024/bases/42-freshbases.srm" --ca-native
.\Tools\curl -# --etag-compare .\Tools\hashes_tag.txt --etag-save .\Tools\hashes_tag.txt -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2024/bases/hashes.txt" --ca-native
echo:
echo Renaming files!
if exist 42-freshbases.srm ren "42-freshbases.srm" "30-bases.srm"
echo:
echo:
title Copying Updated Virus Definition Files to your Rescue Disk
echo Copying Updated Virus Definition Base to your Rescue Disk ( if available )
copy /y .\30-bases.srm .\kavrescue\live\KRD\30-bases.srm > nul
echo:
echo %xmlstamp% > .\kavrescue\krd_bases_timestamp.txt & echo: & echo New Bases timestamp is: %xmlstamp%
echo Updated ".\kavrescue\krd_bases_timestamp.txt"
echo:
echo:
echo Successfully Copied Updated Definition Files to your Rescue Disk
echo:
echo:
echo Next Step: Rebuilding the Rescue Disk ISO Image
echo:
echo:
title Creating the Rescue Disk ISO Image
echo Creating the Rescue Disk ISO Image
echo:
SET CDBOOT=
if exist .\kavrescue\boot\grub\i386-pc\eltorito.img set CDBOOT=boot/grub/i386-pc/eltorito.img 
if exist .\kavrescue\boot\grub\grub_eltorito set CDBOOT=boot/grub/grub_eltorito 
if "%CDBOOT%"=="" goto bs
.\Tools\mkisofs -R -J -joliet-long -o krd.iso -b %CDBOOT% -c boot\boot.cat -no-emul-boot -boot-info-table -V "Kaspersky Rescue Disk" -boot-load-size 4 kavrescue
title Kaspersky Rescue Disk 24 Updater
if errorlevel 1 goto :ERR
echo:
echo:
echo NO ERRORS - New "krd.iso" IS CREATED!
:cont2
rmdir /S /Q .\kavrescue
if exist .\30-bases.srm del .\30-bases.srm
if exist .\hashes.txt del .\hashes.txt
echo:
goto :end

:err
echo ERROR! Some problem occurred!
pause
goto :end

:x
echo Missing file  %~dp0Tools\7z.exe.
echo Please re-extract "Tools" folder from downloaded zip file
goto :end

:y
echo !! Kaspersky Rescue Disk Is Not Present !!.
echo:
echo Missing File %~dp0krd.iso
echo:
echo Rescue Disk Will Be Downloaded from:
echo https://rescuedisk.s.kaspersky-labs^.com/updatable/2024/krd.iso
goto downkrd

:bs
echo !! Bootsector is missing !! .\kavrescue\boot\grub\i386-pc\eltorito.img - please use correct version of ISO!
goto :end

:downkrd
echo:
echo:
echo Downloading KRD.iso from Kaspersky Labs server
.\Tools\curl -# -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2024/krd.iso" --ca-native
echo:
Echo krd.iso has been downloaded. Now updating databases.
if exist .\kavrescue rmdir /S /Q .\kavrescue
echo:
goto :start

:mkiso
echo File Missing %~dp0Tools\mkisofs.exe
echo Please re-extract "Tools" folder from downloaded zip file
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
if %xmlver% GTR %isover% (
echo:
echo It seems that there is a new version of Kaspersky Rescue Disk available!
echo Version on the disk: [%isover%] ^| Version on the server: [%xmlver%]
goto :input
) else ( 
goto :continue
)

:check2
if %xmlstamp% == %isostamp% (
title Kaspersky Rescue Disk 24 Updater
echo:
echo Database timestamps are equal!
echo Timestamp on the disk: [%isostamp%] ^| Timestamp on the server: [%xmlstamp%]
echo No update required, exiting.
goto :cont2
) else ( 
goto :cont1
)

:input
echo:
echo Would you like to download the new version? (y or n)
set /p choose=
)
if "%choose%"=="y" goto :downkrd
if "%choose%"=="n" goto :continue

:end
pause
goto :EOF