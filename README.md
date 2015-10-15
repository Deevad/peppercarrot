# Pepper & Carrot

![alt tag](http://www.peppercarrot.com/extras/logos/Peppercarrot-logo_alpha_512.png)

Welcome!

You found the main repository of tools,resources and script to build the open-source webcomic [Pepper&Carrot](http://wwww.peppercarrot.com). Also, the official [ Wiki ](https://github.com/Deevad/peppercarrot/wiki) is attached to this repository. This Wiki exist in the purpose to build together a better entertaining world around Pepper&Carrot, better character-design and better future episodes.

## Screenshot gallery

**1.** The **launcher icon** within the main menu ( Linux Mint 17.2 Menu )
![alt tag](http://www.peppercarrot.com/data/images/lab/2015-10-15-peppercarrot-script/2015-10-15_peppercarrot-script_screenshot_000_net.jpg)

**2.** The graphical **main menu** interface (left) calling for action "Edit all README.md" from all episodes, executed by Geany text editor(right)
![alt tag](http://www.peppercarrot.com/data/images/lab/2015-10-15-peppercarrot-script/2015-10-15_peppercarrot-script_screenshot_001_net.jpg)

**3.** After the selection of an episode in the menu, the **submenu** ( eg. episode 8, Pepper's Birthday Party ) and a list of service. On right, executing the **renderfarm** ; all graphics ( GFX ) and translations (LANG ) are up-to-date.
![alt tag](http://www.peppercarrot.com/data/images/lab/2015-10-15-peppercarrot-script/2015-10-15_peppercarrot-script_screenshot_002_net.jpg)

**4.** On left the **submenu** focused on episode 10 Summer special. On right, Nemo file manager opening the target folder direclty ( with RabbitCVS for GIT preview over the folder with emblems ). On right (under), the **FTP update**. Files changed or rendered are pushed to the main server this way.
![alt tag](http://www.peppercarrot.com/data/images/lab/2015-10-15-peppercarrot-script/2015-10-15_peppercarrot-script_screenshot_003_net.jpg)

## Dependencies/Libraries

Only free/libre and open-sources tools :
* **Bash** ( >= 4.3.11 ) _Command line language in terminal._
* **Git** ( >= 1.9.1 ) _Utility to manage distributed revision control_
* **Krita** ( >= 2.9.8 ) _Digital painting software, for *.kra artworks comic page source files._
* **Inkscape** ( >= 0.91 ) _Vector graphic software, for *.svg translation source files._
* **Imagemagick** ( >= 6.7.7.10 ) _Utility to manipulate images._
* **Zenity** ( >= 3.8.0 ) _Utility to create simple graphical user interface GTK dialog._
* **Gnome-terminal** ( >= 3.6.2 ) _Terminal software to access a shell in Gnome environment_
* **Unzip** ( >= 6.0 ) _Utility to unzip *.zip files._
* **Wget** ( >= 1.15 ) _Utility to download files._
* **Diff** ( >= 3.3 ) _Utility to compare files,folders._
* **Parallel** ( >= 20130922 ) _Utility to exectute jobs in parallel._
* **Notify-send** ( >= 0.7.6 ) _Utility to send notification to operating system._
* **Lftp** ( >= 4.6.4 ) _Utility to perform FTP transfer._

Note: I'm using **Linux Mint 17.2** 64bit with Cinnamon (default). The package versions here are the one from all Ubuntu 14.04 based system (via the package manager). One exeption: **Krita**; you need to install via the [Krita Lime PPA](https://launchpad.net/~dimula73/+archive/ubuntu/krita). I'm also building Lftp from source for getting a new option, but this option is 'optionnal' and a previous version of Lftp will also work.

## Install

The script **install.sh** can auto-install all for you:

**1.** Create on your disk an empty target folder with around 50GB free space:
```
cd $HOME
mkdir peppercarrot
cd peppercarrot
```
**2.** Get the install.sh file and launch it:
```
wget https://raw.githubusercontent.com/Deevad/peppercarrot/master/install.sh
chmod +x install.sh
./install.sh
```
**3.** The script should create the file **config.sh** along **install.sh** and stop inviting you to edit it:
```
nano config.sh
```
Change ```export projectroot="/home/username/peppercarrot"``` to the path of your folder. Save, and launch again the script again. Voilà, time for getting a coffee in front of long instalation process.

After install, here is how look like a basic file tree of a **Pepper&Carrot project** correctly installed :

```
peppercarrot/
├── fonts (git)
├── scripts (git)
├── webcomics
│   └── ep01_Potion-of-Flight
│   │   ├── lang (git)
│   │   └── zip
│   └── ep02_Rainbow-potions
│   │   ├── lang (git)
│   │   └── zip
│   └── ep03_The-secret-ingredients
│       ├── lang (git)
│       └── zip
├── wiki (git)
└── www-lang (git)
```
_Note: On this example, only three episodes subfolder are visible to keep the example tree compact._

## Usage

After instalation, you can delete **install.sh** and **config.sh** from your root folder. They are now in the folder **scripts**. A [launcher](http://www.peppercarrot.com/data/images/lab/2015-10-15-peppercarrot-script/2015-10-15_peppercarrot-script_screenshot_000_net.jpg) was copied into your system in  ```$HOME/.local/share/applications/peppercarrot-menu.desktop``` .

All operating system's menu should catch this type of launcher. So, open your menu to access **Peppercarrot main menu** ( under the programming/development category ). An [interface](http://www.peppercarrot.com/data/images/lab/2015-10-15-peppercarrot-script/2015-10-15_peppercarrot-script_screenshot_001_net.jpg) will pop-up and guide you to select an action ( eg. Select an episode, then render it ).

## Update

 To **Update** the project , there is no autotools: all folder needs to be updated with ```git pull``` manually.

 The actual repository **peppercarrot** is cloned into the folder **scripts**. By updating **scripts**, you'll receive all the new tools, including future one. All new tools will be accessible via the GUI.


## License

#### Scripts
License [GPLv3 or later](http://gnu.org/licenses/gpl.html). This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.  If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).

#### Wiki

Authors of all modifications, corrections or contributions to the Wiki accept to release their work under the license: [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).
