#!/bin/bash

#: Title       : Pepper&Carrot Installer and Updater ; install.sh
#: Author      : David REVOY < info@davidrevoy.com >, Mjtalkiewicz (aka Player_2)
#: License     : GPL

scriptversion="0.2"

# a Bash script to install all the source of Pepper&Carrot, from remote/online sources.
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
echo " ${Yellow}${PurpleBG}              -= Pepper&Carrot Install and Update =-                    ${Off}"
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
  echo "${Green} * config.sh found${Off}"
  echo "${Green} * Welcome $configuser ${Off}"
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

echo "${Green} * install path = $projectroot ${Off}"
echo ""
echo -n "   [Enter] to continue, [Ctrl+C] to cancel."
read end
echo ""

# Start of job
# ============
echo ""
echo "${Yellow} ==> Starting job for the repositories ${Off}"
echo ""
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

# Retrieve a fresh list of episode from server
  wget -q http://www.peppercarrot.com/0_sources/.episodes-list.md -O "$projectroot"/webcomics/.episodes-list.md
  # parse it as an array
  cd "$projectroot"/webcomics/
  readarray input < .episodes-list.md

# Big loop on episode published so far
# Creating and updating episodes
echo ""
echo "${Yellow} ==> Starting big loop on all episode published ${Off}"
echo ""

  for episodes in "${input[@]}"; do
    episodecleanstring=$(echo $episodes | sed -e 's/\r//g')
    echo "${Yellow}  => $episodes ${Off}"
    cd "$projectroot"/webcomics/
    
      if [ -d "$projectroot"/webcomics/"$episodecleanstring" ]; then
        echo "  * folder exist. Auto-skip"
        # to-do: update, check sanity
        echo ""
        echo ""
      else
        echo "${Green}  * folder doesn't exist. Downloading and setting up. Please wait while downloading.${Off}"
        cd "$projectroot"/webcomics/
        mkdir $episodecleanstring
        cd $episodecleanstring
        # trim folder name to keep only the episode number
          episode_number=${episodecleanstring:2:2}
        # clone the lang folder
          git clone https://github.com/Deevad/peppercarrot_ep"$episode_number"_translation.git lang
        # get *.kra artwork big zip of sources 
        # wget needs URL string compatible
          episode_url=$(echo "$episodecleanstring" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
          wget http://www.peppercarrot.com/0_sources/"$episode_url"/zip/"$episode_url".zip
        # unzip the result
          unzip "$episodecleanstring.zip"
        # move the zip in the right location
          mkdir zip
          mv "$episodecleanstring".zip zip/"$episodecleanstring".zip
        # clean-up in case of multiple failed attempt of wget ( as zip1 , zip2 etc... )
          rm *.zip*
        echo "${Green} * work for $episodeclean done.${Off}"
        echo ""
        echo ""
      fi 
  done

# Script ending. Debriefing.
# Runtime counter: end and math
script_runtime_end=$(date +"%s")
diff_runtime=$(($script_runtime_end-$script_runtime_start))

# End User Interface messages
echo ""
echo " * Pepper&Carrot installed in $(($diff_runtime / 60))min $(($diff_runtime % 60))sec."

# Notification for system when out-of-focus
notify-send "Installer" "all task done in $(($diff_runtime / 60))min $(($diff_runtime % 60))sec."

echo -n " Press [Enter] to exit"
read end
