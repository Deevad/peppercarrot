#!/bin/bash
# lftp
scriptversion="0.3b"

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

# More utils after config loaded
export scriptsfolder="$projectroot"/scripts
export full_url="ftp://$configuser:$configpass@$confighost"

# Set windows title
printf "\033]0;%s\007\n" "*LFTP: Hi"

clear

_display_ui_header()
{
  echo ""
  echo " ${White}${PurpleBG}                                                               ${Off}"
  echo " ${White}${PurpleBG}                     [ LFTP : Low version  ]                   ${Off}"
  echo " ${White}${PurpleBG}                                                               ${Off}"
  echo ""
  echo " * version: $scriptversion "
  echo " * projectname: $projectname "
  echo " * workingpath: $workingpath "
  echo ""
}

_display_ui_header

# Runtime counter: start
script_runtime_start=$(date +"%s")

ftpurl="ftp://$configuser:$configpass@$confighost"
localdirectory="/home/deevad/peppercarrot/webcomics/"
remotedirectory="/www/0_sources/"

lftp -c "set ftp:list-options -a;
set xfer:use-temp-file yes;
open '$ftpurl';
lcd '$localdirectory';
cd '$remotedirectory';
mirror --use-cache \
       --delete \
       --no-perms \
       --reverse \
       --use-pget-n=10 \
       --verbose \
       --exclude-glob New/ \
       --exclude-glob 0_test/ \
       --exclude-glob 0_archives/ \
       --exclude-glob animation/ \
       --exclude-glob backup/ \
       --exclude-glob cache/ \
       --exclude-glob lang/ \
       --exclude-glob wip/ \
       --exclude-glob hi-res/ \
       --exclude-glob zip/ \
       --exclude-glob *.sh \
       --exclude-glob *~ \
       --exclude-glob *.kra
"

# LFTP useful option for testing purpose --dry-run
# Note: I activated the flag --delete, be cautious using/testing it:
# A wrong path, and it can clean a server! 

# Runtime counter: end and math
script_runtime_end=$(date +"%s")
diff_runtime=$(($script_runtime_end-$script_runtime_start))

# End User Interface messages
echo ""
echo " * $projectname uploaded in $(($diff_runtime / 60))min $(($diff_runtime % 60))sec."

# Notification for system when out-of-focus
notify-send "LFTP (low)" "$projectname uploaded in $(($diff_runtime / 60))min $(($diff_runtime % 60))sec."

# Windows title
printf "\033]0;%s\007\n" "LFTP: Low"

# Task is executed inside a terminal
# This line prevent terminal windows to be closed
# Necessary to read log later
echo -n " Press [Enter] to exit"
read end

