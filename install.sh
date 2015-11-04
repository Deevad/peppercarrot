#!/bin/bash

#: Title       : Pepper&Carrot Install
#: Author      : David REVOY < info@davidrevoy.com >, Mjtalkiewicz (aka Player_2)
#: License     : GPL

scriptversion="0.1alpha"

# a script to install all the source of Pepper&Carrot, from remote/online sources.
# Usage : Launch it in the folder of your choice.

# depend Git, Wget, Unzip mainly.

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

# Config.sh external file (gitignored)
if [ -f "$scriptpath"/config.sh ]; then
  source "$scriptpath"/config.sh
  echo "${Green}* config.sh found${Off}"
  echo "* Welcome $configuser"
else
  echo "${Red}* config.sh not found, creating it${Off}"
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
  echo "* please configure your config.sh file now"
  echo "* and launch this script again"
  exit
fi

# Define absolute path to folders in usage
export folder_webcomics="$projectroot"/webcomics
export folder_scripts="$projectroot"/scripts
export libpath="$projectroot"/scripts/lib

# Runtime counter: start
script_runtime_start=$(date +"%s")

clear

echo ""
echo " ${Yellow}${PurpleBG}                                                                          ${Off}"
echo " ${Yellow}${PurpleBG}                       -= Pepper&Carrot Install =-                        ${Off}"
echo " ${Yellow}${PurpleBG}                                                                          ${Off}"
echo ""
echo " * version: $scriptversion "
echo ""

cd "$projectroot"

echo -n " All will be installed in $projectroot [Enter] to continue, [Ctrl+C] to exit."
read end

# Git :
git clone https://github.com/Deevad/peppercarrot_fonts.git fonts

git clone https://github.com/Deevad/peppercarrot.git scripts
cp "$projectroot"/config.sh  "$projectroot"/scripts/config.sh

git clone https://github.com/Deevad/peppercarrot.wiki.git wiki
git clone https://github.com/Deevad/peppercarrot_website_translation.git www-lang

mkdir webcomics
cd webcomics

# download the listing of episode number, name, and avaibility :
rm *.md*
wget http://www.peppercarrot.com/0_sources/.episodes-list.md

# parse it as an array
readarray input < .episodes-list.md

# Install a pretty launcher, for the OS menu.
echo '[Desktop Entry]' > $HOME/.local/share/applications/peppercarrot-menu.desktop
echo 'Comment=All services, uploading, rendering and more for managing Pepper&Carrot project' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
echo 'Terminal=false' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
echo 'Categories=Development' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
echo 'Name=Peppercarrot Main Menu' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
echo 'Exec='$projectroot'/scripts/peppercarrot-main-menu.sh' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
echo 'Type=Application' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
echo 'Icon='$projectroot'/scripts/lib/peppercarrot_icon.png' >> $HOME/.local/share/applications/peppercarrot-menu.desktop
chmod +x $HOME/.local/share/applications/peppercarrot-menu.desktop

# Loop threw the list, and generate all episodes sources
for episodes in "${input[@]}"; do 
  
  cd "$projectroot"/webcomics/
  
  echo "${Yellow} ==> Starting work for $episodes${Off}"
  if [ ! -f "$projectroot"/webcomics/"$episodes" ]; then
  
      echo " * directory $episodes is already existing."
      
  else
  
  # Create the folder
  mkdir $episodes
  cd $episodes
  
  # trim folder name to keep only the episode number
  episode_number=${episodes:2:2}
  
  # clone the lang folder
  git clone https://github.com/Deevad/peppercarrot_ep"$episode_number"_translation.git lang
  
  # get *.kra artwork sources by zip
  episode_url=$(echo "$episodes" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')
  wget http://www.peppercarrot.com/0_sources/"$episode_url"/zip/"$episode_url".zip
  
  # unzip the result
  episodeclean=$(echo $episodes | sed -e 's/\r//g')
  unzip "$episodeclean.zip"
  mkdir zip
  mv "$episodeclean".zip zip/"$episodeclean".zip
  # clean in case of multiple attempt, as zip1 , zip2 etc...
  rm *.zip*
  
  echo "${Green} * work for $episodeclean done.${Off}"
  
  fi
  
done

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
