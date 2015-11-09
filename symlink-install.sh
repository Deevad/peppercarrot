#!/bin/bash
# autogenerate the symlink for the working folder
scriptversion="0.1alpha"

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


# webcomic GIT as the 0_sources in website
if [ -d "$projectroot"/www/peppercarrot ]; then
  echo "${Green}* $projectroot/www/peppercarrot found${Off}"
else
  echo "${Red}* $projectroot/www/peppercarrot not found${Off}"
  mkdir -p "$projectroot"/www/peppercarrot
fi
cd "$projectroot"/www/peppercarrot
ln -s ../../webcomics/ 0_sources


# wiki GIT for as data/wiki in website
if [ -d "$projectroot"/www/peppercarrot/data ]; then
  echo "${Green}* $projectroot/www/peppercarrot/data found${Off}"
else
  echo "${Red}* $projectroot/www/peppercarrot/data not found${Off}"
  mkdir -p "$projectroot"/www/peppercarrot/data
fi
cd "$projectroot"/www/peppercarrot/data
ln -s ../../../wiki/wiki

# website-translation GIT for as transla in theme/website
if [ -d "$projectroot"/www/peppercarrot/themes/peppercarrot-theme_v2 ]; then
  echo "${Green}* $projectroot/www/peppercarrot/themes/peppercarrot-theme_v2 found${Off}"
else
  echo "${Red}* $projectroot/www/peppercarrot/themes/peppercarrot-theme_v2 not found${Off}"
  mkdir -p "$projectroot"/www/peppercarrot/themes/peppercarrot-theme_v2
fi
cd "$projectroot"/www/peppercarrot/themes/peppercarrot-theme_v2
sudo ln -s "$projectroot"/www-lang lang

# for server localhost
cd /var/www
sudo ln -s "$projectroot"/www/ html
