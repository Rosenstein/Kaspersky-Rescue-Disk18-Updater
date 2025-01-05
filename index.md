# Kaspersky-Rescue-Disk18 & 24
A tool to update the virus definitions of Kaspersky Rescue Disk 18 & 24

Kaspersky Rescue Disk Updater is a tool which can be used to update the virus definitions of the Kaspersky Rescue Disk 18 & 24 ISO.

Kaspersky Rescue Disk 18 can scan and remove viruses without booting into windows. The main disadvantage of Kaspersky Rescue Disk 10 is that it is not updated regularly. Even when it is updated there is no option to update your existing iso with the changes.You will have to download the entire iso.

So if you don't download the rescue disk regularly, the virus definitions become out of date. Even though the rescue disk has an option to update the virus definitions from the internet, it is not very useful as the updates are saved on the computer that you're trying to clean. You have to download all the updates each and every time you use the rescue disk on every computer.

This tool fixes the above problems by updating your existing Kaspersky Rescue Disk ISO with the latest virus definitions from the Kaspersky Servers. This helps in keeping your recue disk up date without having to download a lot of files. Hence saving a lot of time and bandwidth.

>
>1 . Download the Updater as a zip from [https://github.com/Rosenstein/Kaspersky-Rescue-Disk18-Updater/releases/latest](https://github.com/Rosenstein/Kaspersky-Rescue-Disk18-Updater/releases/latest) and extract it to directory of your choice.
>
>2 . Run dlupdate.bat to update definitions for 2018 version.  
>  . Run dlupdate_24.bat to update definitions for 2024 version.  
>   Tool assumes that you already have krd.iso in the same directory, but it will be downloaded if not.
>
>3 . Wait for autopilot to finish.  
>  . Virus database is updated once a day, so tool will check if file is changed on the server since the last download attempt  
>
>5 . After the update is done, original krd.iso is overwritten.  
>
>6 . You can now burn krd.iso to a CD and use it.  
>    Or use this [guide](https://support.kaspersky.com/14226#block1) to write the ISO to a flash drive.
>
 
