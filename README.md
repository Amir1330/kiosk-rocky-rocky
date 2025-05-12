
# rocky linux installation 


install [rocky linux](https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.5-x86_64-dvd.iso) ISO and burn it to usb stick using [rufus](https://github.com/pbatard/rufus/releases/download/v4.7/rufus-4.7p.exe) if on windows or dd if on linux. <br>

1. Boot from USB with rocky linux, and select "install rocky linux" <br>
![boot](screenshots/photo_49_2025-05-11_22-23-29.jpg)

2. select English and then Continue <br>
![language](screenshots/photo_55_2025-05-11_22-23-29.jpg)

3. go to "instalation destination" and select apropriate disk
![disk](screenshots/photo_56_2025-05-11_22-23-29.jpg)

3.1 if there is another OS on disk u have to reclaim space just by seecting disk --> "Done"(top left corner) it will display this
![reclaim](screenshots/photo_2025-05-12_17-47-01.jpg)

press "reclaim space" and in opened window press "delete all" and then "reclaim space" again 

![space](screenshots/photo_2025-05-12_17-47-28.jpg)

4. go to "Time & Date" and select ur timezone and "done"
![time](screenshots/photo_57_2025-05-11_22-23-29.jpg
)

5. go to "Software selection" and select "workstation" and "done"
![asas](screenshots/photo_58_2025-05-11_22-23-29.jpg)

6. go to "security profile" disable it and "done"
![sec](screenshots/photo_60_2025-05-11_22-23-29.jpg)

7. go to "root password" deselect and then select again "lock root accaunt"
![root](screenshots/photo_62_2025-05-11_22-23-29.jpg)

8. go to "User creation" fill everithing like on photo and make sure that "make this user administrator" is checked then press "done" twice 
![acc](screenshots/photo_64_2025-05-11_22-23-29.jpg)

9. finaly press "Begin installation" and wait untill done and then press "reboot"
![inst](screenshots/photo_46_2025-05-11_22-23-29.jpg)


# System setup

## Settings
when booting first time it will advice you to take a tour, just ignore that and press "No thanks"
![welcum](screenshots/photo_65_2025-05-11_22-23-29.jpg)

press "win" key on keyboard type terminal and open it, then enter this command 
```bash
sudo dnf update -y --refresh
```
after command is finished reboot ur system

open terminal again and clone this repo
```bash
git clone https://github.com/Amir1330/kiosk-rocky-rocky
```

when finished press "win" key type and open "settings"
![aa](screenshots/photo_40_2025-05-11_22-23-29.jpg)

go to "background" open and select new background from directory
![aa](screenshots/photo_2_2025-05-11_22-23-29.jpg)

go to "Home/kiosk-rocky-rocky" and select "bromart.png"
![aa](screenshots/photo_4_2025-05-11_22-23-29.jpg)

![aa](screenshots/photo_5_2025-05-11_22-23-29.jpg)

go to "notification" tab and turn on "Do not distrub"
![aa](screenshots/photo_7_2025-05-11_22-23-29.jpg)

go to "multitasking" tab and turn off multitasking and and select "fixed number of workspaces" and reduce it to 1  
![aa](screenshots/photo_9_2025-05-11_22-23-29.jpg)

go to "power" tab select "perfomance", turn off "Dim screen" and set "screen blank" to never
![aa](screenshots/photo_11_2025-05-11_22-23-29.jpg)
![aa](screenshots/photo_12_2025-05-11_22-23-29.jpg)

go to "Display" tab and set display to whatever needed
![aa](screenshots/photo_14_2025-05-11_22-23-29.jpg)


go to "keyboard" tab and add rus layout
![aa](screenshots/photo_15_2025-05-11_22-23-29.jpg)

go to "accessebility" tab and turn on "Screen keyboard"
![aa](screenshots/photo_18_2025-05-11_22-23-29.jpg)

go to "User" tab press "Unlock" and enter password, when unlocked turn on "Autologin" 
![aa](screenshots/photo_21_2025-05-11_22-23-29.jpg)

go to "date and time" and turn on automatick date and time
![aa](screenshots/photo_23_2025-05-11_22-23-29.jpg)

## firefox

open firefox, and open this repo and install extensions below
**extensions** <br>
[1. hide top bar](https://extensions.gnome.org/extension/545/hide-top-bar/)  <br>
open and install extension by clicking on the link
![aa](screenshots/photo_24_2025-05-11_22-23-29.jpg)
confirm and install
![aa](screenshots/photo_25_2025-05-11_22-23-29.jpg)

refresh the page and turn on extension
![aa](screenshots/photo_27_2025-05-11_22-23-29.jpg)
press install and refresh page again
![aa](screenshots/photo_28_2025-05-11_22-23-29.jpg)
after refreshing click on tools icon 
![aa](screenshots/photo_29_2025-05-11_22-23-29.jpg)
in opened window follow this settings
![aa](screenshots/photo_30_2025-05-11_22-23-29.jpg)
![aa](screenshots/photo_31_2025-05-11_22-23-29.jpg)
![aa](screenshots/photo_33_2025-05-11_22-23-29.jpg)


[2. disable gestures 2021](https://extensions.gnome.org/extension/4049/disable-gestures-2021/)  <br>
![aa](screenshots/photo_34_2025-05-11_22-23-29.jpg)

[3. No overview at start-up](https://extensions.gnome.org/extension/4099/no-overview/)  <br> 
![aa](screenshots/photo_35_2025-05-11_22-23-29.jpg)

## Le final

open terminal again and cd into "kiosk-rocky-rocky"

```bash
cd kiosk-rocky-rocky
```
![aa](screenshots/photo_36_2025-05-11_22-23-29.jpg)

start script

```bash
./install.sh
```
![aa](screenshots/photo_37_2025-05-11_22-23-29.jpg)

now u can enter desired domen
![aa](screenshots/photo_38_2025-05-11_22-23-29.jpg)

after script is finished u can reboot

![aa](screenshots/photo_39_2025-05-11_22-23-29.jpg)





