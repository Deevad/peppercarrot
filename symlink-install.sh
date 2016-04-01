#!/bin/bash
# Autogenerate a list of symlink as post install routine.
# To-do: merge it with install.sh

scriptversion="0.2alpha"

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

# 0_sources: symlink all webcomics to the root of the local website
if [ -d "$projectroot"/www/peppercarrot/0_sources ]; then
  echo "${Green}* $projectroot/www/peppercarrot/0_sources found${Off}"
else
  echo "${Red}* $projectroot/www/peppercarrot/0_sources not found${Off}"
  echo "${Yellow} => creating symlink ${Off}"
  mkdir -p "$projectroot"/www/peppercarrot
  ln -s "$projectroot"/webcomics/ $projectroot/www/peppercarrot/0_sources
fi

# Artworks: symlink artwork at root inside the webcomic/0ther folder to get sync via FTP on the fly.
if [ -d "$projectroot"/webcomics/0ther/artworks ]; then
  echo "${Green}* $projectroot/webcomics/0ther/artworks found${Off}"
else
  echo "${Red}* $projectroot/webcomics/0ther/artworks not found${Off}"
  echo "${Yellow} => creating symlink ${Off}"
  ln -s "$projectroot"/webcomics/0ther/artworks/ "$projectroot"/artworks
fi

# Wiki: symlink root wiki folder inside the local website
if [ -d "$projectroot"/www/peppercarrot/data/wiki ]; then
  echo "${Green}* $projectroot/www/peppercarrot/data/wiki found${Off}"
else
  echo "${Red}* $projectroot/www/peppercarrot/data/wiki not found${Off}"
  echo "${Yellow} => creating symlink ${Off}"
  mkdir -p "$projectroot"/www/peppercarrot/data
  ln -s "$projectroot"/wiki "$projectroot"/www/peppercarrot/data/wiki
fi

# Fonts: symlink git folder to a subfolder into local/share of active user. So the fonts are in use.
if [ -d $HOME/.local/share/fonts/peppercarrot ]; then
  echo "${Green}* $HOME/.local/share/fonts/peppercarrot-fonts found${Off}"
else
  echo "${Red}* $HOME/.local/share/fonts/peppercarrot-fonts not found${Off}"
  echo "${Yellow} => creating symlink ${Off}"
  ln -s "$projectroot"/fonts/ $HOME/.local/share/fonts/peppercarrot-fonts
fi

# Www-lang: symlink git website-translation located at root of the project folder to the local website code.
if [ -d "$projectroot"/www/peppercarrot/themes/peppercarrot-theme_v2/lang ]; then
  echo "${Green}* $projectroot/www/peppercarrot/themes/peppercarrot-theme_v2/lang found${Off}"
else
  echo "${Red}* $projectroot/www/peppercarrot/themes/peppercarrot-theme_v2/lang not found${Off}"
  echo "${Yellow} => creating symlink ${Off}"
  mkdir -p "$projectroot"/www/peppercarrot/themes/peppercarrot-theme_v2
  sudo ln -s "$projectroot"/www-lang "$projectroot"/www/peppercarrot/themes/peppercarrot-theme_v2/lang
fi

  echo "=====================================END==================================="
  echo -n "Press [Enter] to exit"
  read end
