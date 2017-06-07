#!/bin/bash

#: Title       : Pepper&Carrot Installer and Updater ; install.sh
#: Author      : David REVOY < info@davidrevoy.com >, Mjtalkiewicz (aka Player_2)
#: License     : GPL

scriptversion="1.0b"

# a Bash script to install all the source of Pepper&Carrot inside a folder
# Usage : Launch the script on a terminal, and follow the instructions.

# Dependencies needed:
# bash 
# git
# wget
# unzip

# Utils
export scriptpath="`dirname \"$0\"`"
export projectname="${PWD##*/}"
export workingpath="${PWD}"
export isodate=$(date +%Y-%m-%d)
export version=$(date +%Y-%m-%d_%Hh%M)
export versiondaily=$(date +%Y%m%d)
export svgcount=0
export Off=$'\e[0m'
export Purple=$'\e[1;35m'
export Blue=$'\e[1;34m'
export Green=$'\e[1;32m'
export Red=$'\e[1;31m'
export Yellow=$'\e[1;33m'
export White=$'\e[1;37m'
export BlueBG=$'\e[1;44m'
export RedBG=$'\e[1;41m'
export PurpleBG=$'\e[1;45m'
export Black=$'\e[1;30m'

clear

echo ""
echo " ${Yellow}${PurpleBG}                                                                        ${Off}"
echo " ${Yellow}${PurpleBG}                 -= Pepper&Carrot Installer =-                          ${Off}"
echo " ${Yellow}${PurpleBG}                                                                        ${Off}"
echo " ${Yellow}${PurpleBG}                          /|_____|\                                     ${Off}"
echo " ${Yellow}${PurpleBG}                         /  ' ' '  \                                    ${Off}"
echo " ${Yellow}${PurpleBG}                        < ( .  . )  >                                   ${Off}"
echo " ${Yellow}${PurpleBG}                         <   '◡    >                                    ${Off}"
echo " ${Yellow}${PurpleBG}                           '''|  \                                      ${Off}"
echo " ${Yellow}${PurpleBG}                                                                        ${Off}"
echo " ${Yellow}${PurpleBG}                                                                        ${Off}"
echo ""
echo ""
echo "${Yellow} * version: $scriptversion ${Off}"
echo ""

# Config.sh external file 
# (a configuration file ignored by git)
# it store: path + ftp login and password
if [ -f "$scriptpath"/config.sh ]; then
  source "$scriptpath"/config.sh
  echo "* config.sh found"
  echo ""
  echo "${Green}   FTP user: $configuser ${Off}"
else
  echo "${Red} * config.sh not found, creating it${Off}"
  # Write file
  echo '#!/bin/bash' > "$scriptpath"/config.sh
  echo '' >> "$scriptpath"/config.sh
  echo '# Global config' >> "$scriptpath"/config.sh
  echo 'export projectroot="/home/username/peppercarrot"' >> "$scriptpath"/config.sh
  echo '' >> "$scriptpath"/config.sh
  echo '# Uploaders' >> "$scriptpath"/config.sh
  echo 'confighost="ftp.yourhostname.net"' >> "$scriptpath"/config.sh
  echo 'configuser="username"' >> "$scriptpath"/config.sh
  echo 'configpass="password"' >> "$scriptpath"/config.sh
  # Verbose
  echo "${Yellow} ==> done${Off}"
  echo " * please configure your config.sh file now"
  echo " * and launch this script again"
  exit
fi

# Define absolute path to folders in usage
export folder_webcomics="$projectroot"/webcomics
export folder_scripts="$projectroot"/scripts
export libpath="$projectroot"/scripts/lib

# Runtime counter: start
script_runtime_start=$(date +"%s")

cd "$projectroot"

echo "${Green}   Install path: $projectroot ${Off}"
echo ""
echo "   Is everything correct? "
echo ""
echo -n "   [Enter] to continue, [Ctrl+C] to cancel."
read end
echo ""

# Start with install
# ==================
echo ""
echo "${Blue} [ INSTALL ] ${Off}"
echo "${Blue} ########################################################################## ${Off}"

echo ""
echo "${Yellow} [ REPOSITORIES ] ${Off}"
echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

# Install a pretty launcher, for the OS menu.
  if [ -f $HOME/.local/share/applications/peppercarrot-menu.desktop ]; then
    echo " * $HOME/.local/share/applications/peppercarrot-menu.desktop found" 
  else
    echo "${Green} * Pepper&Carrot launcher not found, creating it in $HOME/.local/share/applications/peppercarrot-menu.desktop. ${Off}"
    # icon creation
    echo '[Desktop Entry]' > $HOME/.local/share/applications/peppercarrot-menu.desktop
    echo 'Comment=All services, uploading, rendering and more for managing Pepper&Carrot project' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
    echo 'Terminal=false' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
    echo 'Categories=Development' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
    echo 'Name=Peppercarrot Main Menu' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
    echo 'Exec='$projectroot'/scripts/peppercarrot-main-menu.sh' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
    echo 'Type=Application' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
    echo 'Icon='$projectroot'/scripts/lib/peppercarrot_icon.png' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
    # permission right: execute 
    chmod +x $HOME/.local/share/applications/peppercarrot-menu.desktop
  fi

# Check and install repository for scripts
  if [ -d "$projectroot"/scripts ]; then
    echo " * "$projectroot"/scripts found" 
  else
    echo "${Green} * "$projectroot"/scripts not found, cloning git repository. ${Off}"
    git clone https://github.com/Deevad/peppercarrot.git scripts
  fi
  if [ -f "$projectroot"/config.sh ]; then
    echo "${Green}  * "$projectroot"/config.sh found, moving it to "$projectroot"/scripts/config.sh ${Off}" 
    cp "$projectroot"/config.sh  "$projectroot"/scripts/config.sh
  fi

# Check and install repository for fonts
  if [ -d "$projectroot"/fonts ]; then
    echo " * "$projectroot"/fonts found" 
  else
    echo "${Green} * "$projectroot"/fonts not found, cloning git repository. ${Off}"
    git clone https://github.com/Deevad/peppercarrot_fonts.git fonts
  fi

# Check and install repository for wiki
  if [ -d "$projectroot"/wiki ]; then
    echo " * "$projectroot"/wiki found" 
  else
    echo "${Green} * "$projectroot"/wiki not found, cloning git repository. ${Off}"
    git clone https://github.com/Deevad/peppercarrot.wiki.git wiki
  fi

# Check and install repository for www-lang
  if [ -d "$projectroot"/www-lang ]; then
    echo " * "$projectroot"/www-lang found" 
  else
    echo "${Green} * "$projectroot"/www-lang not found, cloning git repository. ${Off}"
    git clone https://github.com/Deevad/peppercarrot_website_translation.git www-lang
  fi

# Check and install repository for webcomic
  if [ -d "$projectroot"/webcomics ]; then
    echo " * "$projectroot"/webcomics found" 
  else
    echo "${Green} * "$projectroot"/webcomics not found, building... ${Off}"
    mkdir webcomics
  fi

echo ""
echo "${Yellow} [ DATABASE ] ${Off}"
echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"
  # Retrieve a fresh list of episode from server
  echo "*  Downloading http://www.peppercarrot.com/0_sources/.episodes-list.md"
  wget http://www.peppercarrot.com/0_sources/.episodes-list.md -O "$projectroot"/webcomics/.episodes-list.md
  # parse it as an array
  cd "$projectroot"/webcomics/
  readarray input < .episodes-list.md

# Big loop on episode published so far
# Creating and updating episodes
echo ""
echo "${Yellow} [ EPISODES ] ${Off}"
echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

  for episodes in "${input[@]}"; do
    episodecleanstring=$(echo $episodes | sed -e 's/\r//g')
    
      if [ -d "$projectroot"/webcomics/"$episodecleanstring" ]; then
        echo "* $episodecleanstring found"

        # folder basic sanity check
        if [ ! -d "$projectroot"/webcomics/"$episodecleanstring"/lang/.git ]; then
          echo "${Green}  lang is missing ${Off}"
        fi

        if [ ! -d "$projectroot"/webcomics/"$episodecleanstring"/zip ]; then
          echo "${Green}  zip is missing ${Off}"
        fi
 
      else
        echo "${Green}* $episodecleanstring is missing ${Off}"
        echo "Downloading and setting up. Please wait while downloading."
        mkdir -p "$projectroot"/webcomics/"$episodecleanstring"
        # trim folder name to keep only the episode number
        episode_number=${episodecleanstring:2:2}

        # GIT: clone the lang folder
        echo "[GIT] cloning https://github.com/Deevad/peppercarrot_ep"$episode_number"_translation.git"
        git clone https://github.com/Deevad/peppercarrot_ep"$episode_number"_translation.git "$projectroot"/webcomics/"$episodecleanstring"/lang

        # WGET: get *.kra artwork big zip of sources
        echo "[WGET] Downloading http://www.peppercarrot.com/0_sources/"$episodecleanstring"/zip/"$episodecleanstring".zip"
        # wget needs URL string compatible
        episode_url=$(echo "$episodecleanstring" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
        mkdir -p "$projectroot"/webcomics/"$episodecleanstring"/zip
        wget http://www.peppercarrot.com/0_sources/"$episode_url"/zip/"$episode_url".zip -O "$projectroot"/webcomics/"$episodecleanstring"/zip/"$episodecleanstring".zip
        if [ -f "$projectroot"/webcomics/"$episodecleanstring"/zip/"$episodecleanstring".zip ]; then
          echo "  * zip file downloaded"
          echo "[UNZIP] Extract zipped *.kra artworks"
          unzip "$projectroot"/webcomics/"$episodecleanstring"/zip/"$episodecleanstring".zip -d "$projectroot"/webcomics/"$episodecleanstring"
          echo "${Green}[DONE] ${Off}"
        else
          echo "${Red}[ERROR] file couldn't be downloaded${Off}"
        fi

        echo ""
        echo ""
      fi 
  done

## Symlink everything to finish the instalation:
echo ""
echo "${Yellow} [ SYMLINKS ] ${Off}"
echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

# 0_sources: symlink all webcomics to the root of the local website
if [ -d "$projectroot"/www/peppercarrot/0_sources ]; then
  echo "* $projectroot/www/peppercarrot/0_sources found"
else
  echo "${Green}* $projectroot/www/peppercarrot/0_sources not found${Off}"
  echo "${Yellow} => creating symlink ${Off}"
  mkdir -p "$projectroot"/www/peppercarrot
  ln -s "$projectroot"/webcomics/ $projectroot/www/peppercarrot/0_sources
fi

# Artworks: symlink artwork at root inside the webcomic/0ther folder to get sync via FTP on the fly.
if [ -d "$projectroot"/webcomics/0ther/artworks ]; then
  echo "* $projectroot/webcomics/0ther/artworks found"
else
  echo "${Green}* $projectroot/webcomics/0ther/artworks not found${Off}"
  echo "${Yellow} => creating symlink ${Off}"
  ln -s "$projectroot"/webcomics/0ther/artworks/ "$projectroot"/artworks
fi

# Wiki: symlink root wiki folder inside the local website
if [ -d "$projectroot"/www/peppercarrot/data/wiki ]; then
  echo "* $projectroot/www/peppercarrot/data/wiki found"
else
  echo "${Green}* $projectroot/www/peppercarrot/data/wiki not found${Off}"
  echo "${Yellow} => creating symlink ${Off}"
  mkdir -p "$projectroot"/www/peppercarrot/data
  ln -s "$projectroot"/wiki "$projectroot"/www/peppercarrot/data/wiki
fi

# Fonts: symlink git folder to a subfolder into local/share of active user. So the fonts are in use.
if [ -d $HOME/.local/share/fonts/peppercarrot-fonts ]; then
  echo "* $HOME/.local/share/fonts/peppercarrot-fonts found"
else
  echo "${Green}* $HOME/.local/share/fonts/peppercarrot-fonts not found${Off}"
  echo "${Yellow} => creating symlink ${Off}"
  mkdir -p $HOME/.local/share/fonts
  ln -s "$projectroot"/fonts $HOME/.local/share/fonts/peppercarrot-fonts
fi

# Www-lang: symlink git website-translation located at root of the project folder to the local website code.
if [ -d "$projectroot"/www/peppercarrot/themes/peppercarrot-theme_v2/lang ]; then
  echo "* $projectroot/www/peppercarrot/themes/peppercarrot-theme_v2/lang found"
else
  echo "${Green}* $projectroot/www/peppercarrot/themes/peppercarrot-theme_v2/lang not found${Off}"
  echo "${Yellow} => creating symlink ${Off}"
  mkdir -p "$projectroot"/www/peppercarrot/themes/peppercarrot-theme_v2
  ln -s "$projectroot"/www-lang "$projectroot"/www/peppercarrot/themes/peppercarrot-theme_v2/lang
fi

# Second part: Update
# ====================
echo ""
echo "${Blue} [ UPDATE ] ${Off}"
echo "${Blue} ########################################################################## ${Off}"
echo ""

echo "${Yellow} [UPDATE WEBCOMICS]${Off}"
echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

cd "$projectroot"/webcomics

# Batch entry door to all episodes
  for directories in */ ; do
    gitdirectories=$directories"lang/"
    # Does the folder got a sub lang folder existing ?
    if [ -d "$projectroot"/webcomics/"$gitdirectories" ]; then
        #yes
        # is it a git repository ?
        if [ -d "$projectroot"/webcomics/"$gitdirectories"/.git ]; then
          
          # BATCH ENTRY DOOR : good place to batch action to do for each webcomic directories, look at the comment under for template.
          cd "$projectroot"/webcomics/"$directories"
          
            # # Eg. Auto-commit changes to all README.md files
            # # A. Do your changes on all the README.md
            # # B. Uncomment the paragraph under and customise it.
            # # enter every lang dir
            # cd "$projectroot"/webcomics/"$gitdirectories"
            # git add README.md
            # git commit -m "Fix, clean and correct contributors name for consistency"
            # git push
            
            # # Eg. Reset the change and clean the repositories and do a clean re-render:
            # # enter every lang dir
            #cd "$projectroot"/webcomics/"$gitdirectories"
            # # napalm changes
            #git checkout -- .
            # # enter the episode dir
            #cd "$projectroot"/webcomics/"$directories"
            # # Call renderfarm
            #gnome-terminal --command="$folder_scripts"/renderfarm.sh
            # # wait 30s before showing another windows. 
            #sleep 30
          
            # Eg. Entering in hires subfolder, and cleaning all PNG to JPG :
            #cd hi-res
            #for pngfile in $(find . -name '*.png')
            #do
            #jpgfile=$(echo $pngfile|sed 's/\(.*\)\..\+/\1/')".jpg"
            #echo " * converting $pngfile => $jpgfile"
            #convert -strip -interlace Plane -quality 95% "$pngfile" "$jpgfile"
            #echo " * done"
            #echo ""
            #done
            
            # Eg. Entering in hires/gfx-only and transforming all PNG to JPG, then delete PNG.
            # cd hi-res/gfx-only
            # for pngfile in $(find . -name '*.png'); do
            #   jpgfile=$(echo $pngfile|sed 's/\(.*\)\..\+/\1/')".jpg"
            #   echo " ${Blue}* Converting $pngfile ${Off}"
            #   convert -strip -interlace Plane -units PixelsPerInch -density 300 -colorspace sRGB -background white -alpha remove -quality 95% "$pngfile" "$jpgfile"
            #   if [ -f "$jpgfile" ]; then
            #      echo "${Green}* Done.${Off}."
            #      # cleaning:
            #      rm -f "$pngfile"
            #   else
            #      echo " ${Red}* Error:${Off} jpg non generated."
            #   fi
            #   echo ""
            # done
            
            # execute a command on all SVG
            # Eg. Entering in lang
            # cd "$projectroot"/webcomics/"$gitdirectories"
            # Pretty title
            # echo "${Blue}* Command on all SVGs ${Off}"
            #for svgfile in $(find . -name '*.svg'); do
            #   svgcount=$((svgcount+1))
            #   echo "[ ""$svgcount"" ]"
            #   svgfullpath=$(readlink -m $svgfile)
            #   "$projectroot"/scripts/utils/svg-sanifier.sh $svgfullpath
            #done
            
            # execute a command for white-transparency-background on all 5800 TXT-only PNGs
            # Entering Txt-only :
            #if [ -d "$projectroot"/webcomics/"$directories"/hi-res/txt-only ]; then
            #   cd "$projectroot"/webcomics/"$directories"/hi-res/txt-only
            #   # Pretty title
            #   echo "${Blue}* Command on all TXT-ONLY ${Off}"
            #   for pngfile in $(find . -name '*.png'); do
            #       pngfullpath=$(readlink -m $pngfile)
            #       convert $pngfullpath -background White -alpha Background $pngfullpath
            #       echo " * ""$pngfile"" Converted"
            #   done
            #fi
            

            echo "${Blue} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"
            # ask user to press a key before process next episode:
            #echo -n "${Blue} Press Enter to continue. ${Off}"
            #read end

          # Batch Git update them
          cd "$projectroot"/webcomics/"$gitdirectories"
          
          # refresh repo to get remote informations
          git remote update
          
          # git tools
          gitlocal=$(git rev-parse @)
          gitremote=$(git rev-parse @{u})
          gitbase=$(git merge-base @ @{u})
          
          # start git update smart decisions
          if [ $gitlocal = $gitremote ]; then
            echo "* $directories is up-to-date"
              
          elif [ $gitlocal = $gitbase ]; then
            echo "${Blue} * $directories  is outdated${Off}"
            
            # echo "${Green} ==> [git] Batch fix all to remote tree HEAD: git reset hard master ${Off}"
            # cd "$projectroot"/webcomics/"$gitdirectories"
            # git reset --hard master
            
            cd "$projectroot"/webcomics/"$directories"
            gnome-terminal --command="$projectroot"/scripts/renderfarm.sh &
            read -t 150 -p "* Hit ENTER or wait 2 minute and 30s"

                      
          elif [ $gitremote = $gitbase ]; then
            echo "${Purple} * $directories contains commit non pushed${Off}"
              
          else
            echo "${Red} * $directories error: diverging repositories${Off}"
          fi
          
        else
        echo " * $directories doesn't have a Git repository ${Off}"
        fi
    fi
  done
  echo "${Blue} * TOTAL SVGs : $svgcount${Off}"
echo ""
echo "${Yellow} [UPDATE FONTS]${Off}"
echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

directories="fonts"
cd "$projectroot"/"$directories"
          # refresh repo to get remote informations
          git remote update
          
        if [ -d "$projectroot"/"$directories"/.git ]; then 
        
          # git tools
          gitlocal=$(git rev-parse @)
          gitremote=$(git rev-parse @{u})
          gitbase=$(git merge-base @ @{u})
          
          # start git update smart decisions
          if [ $gitlocal = $gitremote ]; then
            echo " * $directories is up-to-date"
              
          elif [ $gitlocal = $gitbase ]; then
            echo "${Blue} * $directories  is outdated${Off}"
            echo "${Green} ==> [git] git pull ${Off}"
            git pull
                      
          elif [ $gitremote = $gitbase ]; then
            echo "${Purple} * $directories contains commit non pushed${Off}"
              
          else
            echo "${Red} * $directories error: diverging repositories${Off}"
          fi
          
        else
        echo " * $directories isn't a Git repository ${Off}"
        fi

echo ""
echo "${Yellow} [UPDATE WIKI]${Off}"
echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

directories="wiki"
cd "$projectroot"/"$directories"
          # refresh repo to get remote informations
          git remote update
          
        if [ -d "$projectroot"/"$directories"/.git ]; then 
        
          # git tools
          gitlocal=$(git rev-parse @)
          gitremote=$(git rev-parse @{u})
          gitbase=$(git merge-base @ @{u})
          
          # start git update smart decisions
          if [ $gitlocal = $gitremote ]; then
            echo " * $directories is up-to-date"
              
          elif [ $gitlocal = $gitbase ]; then
            echo "${Blue} * $directories  is outdated${Off}"
            echo "${Green} ==> [git] git pull ${Off}"
            git pull
                      
          elif [ $gitremote = $gitbase ]; then
            echo "${Purple} * $directories contains commit non pushed${Off}"
              
          else
            echo "${Red} * $directories error: diverging repositories${Off}"
          fi
          
        else
        echo " * $directories doesn't have a Git repository ${Off}"
        fi

echo ""
echo "${Yellow} [UPDATE WWW-LANG]${Off}"
echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

directories="www-lang"
cd "$projectroot"/"$directories"
          # refresh repo to get remote informations
          git remote update
          
        if [ -d "$projectroot"/"$directories"/.git ]; then 
        
          # git tools
          gitlocal=$(git rev-parse @)
          gitremote=$(git rev-parse @{u})
          gitbase=$(git merge-base @ @{u})
          
          # start git update smart decisions
          if [ $gitlocal = $gitremote ]; then
            echo " * $directories is up-to-date"
              
          elif [ $gitlocal = $gitbase ]; then
            echo "${Blue} * $directories  is outdated${Off}"
            echo "${Green} ==> [git] git pull ${Off}"
            git pull
                      
          elif [ $gitremote = $gitbase ]; then
            echo "${Purple} * $directories contains commit non pushed${Off}"
              
          else
            echo "${Red} * $directories error: diverging repositories${Off}"
          fi
          
        else
        echo " * $directories doesn't have a Git repository ${Off}"
        fi

echo ""
echo "${Yellow} [UPDATE SCRIPT]${Off}"
echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

directories="scripts"
cd "$projectroot"/"$directories"
          # refresh repo to get remote informations
          git remote update
          
        if [ -d "$projectroot"/"$directories"/.git ]; then 
        
          # git tools
          gitlocal=$(git rev-parse @)
          gitremote=$(git rev-parse @{u})
          gitbase=$(git merge-base @ @{u})
          
          # start git update smart decisions
          if [ $gitlocal = $gitremote ]; then
            echo " * $directories is up-to-date"
              
          elif [ $gitlocal = $gitbase ]; then
            echo "${Blue} * $directories  is outdated${Off}"
            echo "${Green} ==> [git] git pull ${Off}"
            git pull
                      
          elif [ $gitremote = $gitbase ]; then
            echo "${Purple} * $directories contains commit non pushed${Off}"
              
          else
            echo "${Red} * $directories error: diverging repositories${Off}"
          fi
          
        else
        echo " * $directories doesn't have a Git repository ${Off}"
        fi

# Script ending. Debriefing.
# Runtime counter: end and math
script_runtime_end=$(date +"%s")
diff_runtime=$(($script_runtime_end-$script_runtime_start))

# End User Interface messages
echo ""
echo " * Script did the job in $(($diff_runtime / 60))min $(($diff_runtime % 60))sec."

# Notification for system when out-of-focus
notify-send "Install.sh" "all task done in $(($diff_runtime / 60))min $(($diff_runtime % 60))sec."

echo -n " Press [Enter] to exit"
read end
