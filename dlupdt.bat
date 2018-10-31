@echo off
color 0A
title Kaspersky Rescue Disk 18 Updater
echo ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
echo Ý                                                                Þ
echo Ý Kaspersky Rescue Disk 18 Updater by Rosenstein                 Þ
echo Ý    (based on the Bharat Balegere's updater from AgniPulse.Com) Þ
echo Ý                                                                Þ
echo Ý                                                                Þ
echo Ý https://github.com/Rosenstein/Kaspersky-Rescue-Disk18-Updater  Þ
echo Ý                                                                Þ
echo ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
echo:
echo:
echo:
:START
if not exist .\Tools\mkisofs.exe goto mkiso
if not exist .\Tools\7z.exe goto x
if not exist .\krd.iso goto y
if exist .\kavrescue rmdir /S /Q .\kavrescue
if exist .\042-freshbases.srm del .\042-freshbases.srm
if exist .\hashes.txt del .\hashes.txt
if exist .\005-bases.srm del .\005-bases.srm
if exist .\005-bases.srm.sha512 del .\005-bases.srm.sha512
if exist .\krd.xml del .\krd.xml
if exist .\krd_new.iso del .\krd_new.iso

echo Extracting the contents of Kaspersky Rescue Disk
Title Extracting Kaspersky Rescue Disk
.\Tools\7z x -o"kavrescue" -bsp2 -y -x"![BOOT]\*.img" "krd.iso" > nul
if errorlevel 255 goto:user_stopped_the_process
if errorlevel 8 goto:not_enough_memory
if errorlevel 7 goto:command_line_error
if errorlevel 2 goto:fatal_error
if errorlevel 1 goto:ok_warnings
echo Kaspersky Files Extracted to %~dp0kavrescue
echo:
echo:

Title Downloading fresh bases
echo Downloading fresh bases for Kaspersky Rescue Disk
echo:
.\Tools\curl -# -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2018/bases/042-freshbases.srm"
.\Tools\curl -# -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2018/bases/hashes.txt"
.\Tools\curl -# -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2018/bases/krd.xml"
echo:
echo Renaming files!
ren "042-freshbases.srm" "005-bases.srm" > nul 2>&1
ren "hashes.txt" "005-bases.srm.sha512" > nul 2>&1
echo:
echo:

title Copying the Updated Virus Definition Files to your Rescue Disk
echo Copying the Updated Virus Definition Base to your Rescue Disk
copy /y .\005-bases.srm .\kavrescue\data\005-bases.srm > nul
copy /y .\005-bases.srm.sha512 .\kavrescue\data\005-bases.srm.sha512 > nul
echo:
FOR /F delims^=^"^ tokens^=2 %%G IN ('FINDSTR /L "databases_timestamp" "krd.xml"')  DO ECHO %%G > .\kavrescue\krd_bases_timestamp.txt & echo: & echo Base timestamp is: %%G
echo Updating "krd_bases_timestamp.txt"
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
.\Tools\mkisofs -R -J -joliet-long -o krd_new.iso -b %CDBOOT% -c boot\boot.cat -no-emul-boot -boot-info-table -V "Kaspersky Rescue Disk" -boot-load-size 4 kavrescue > nul  2>&1
if errorlevel 1 goto :ERR
echo NO ERRORS - new krd_new.iso IS MADE!
rmdir /S /Q .\kavrescue
del .\005-bases.srm
del .\005-bases.srm.sha512
del .\krd.xml
echo:
goto :end
:ERR
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
echo https://rescuedisk.s.kaspersky-labs^.com/updatable/2018/krd.iso
goto downkrd

:bs
echo !! Bootsector is missing !! .\kavrescue\boot\grub\i386-pc\eltorito.img - please use correct version of ISO!
goto :end

:downkrd
.\Tools\curl -# -O "https://rescuedisk.s.kaspersky-labs.com/updatable/2018/krd.iso"
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

:end
pause
goto :EOF

