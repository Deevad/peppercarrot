#!/bin/bash
# Filewalker
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
printf "\033]0;%s\007\n" "*Filewalker"

clear

cd "$projectroot"

  echo ""
  echo " ${White}${RedBG}                                                               ${Off}"
  echo " ${White}${RedBG}                     [ FILEWALKER  ]                           ${Off}"
  echo " ${White}${RedBG}                                                               ${Off}"
  echo ""
  echo " * version: $scriptversion "
  echo ""


echo "${Yellow} [Checking project size]${Off}"
echo "${Yellow} =-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= ${Off}"

echo "Project size:"
du -hs "$projectroot"
echo ""
echo " * Disk size of PNGs:"
find -type f -name '*.png' -exec du -ch {} + | grep total$
echo ""
echo " * Disk size of JPGs:"
find -type f -name '*.jpg' -exec du -ch {} + | grep total$
echo ""
echo " * Disk size of Krita sources:"
find -type f -name '*.kra' -exec du -ch {} + | grep total$
echo ""
echo " * Disk size of SVGs:"
find -type f -name '*.svg' -exec du -ch {} + | grep total$
echo ""
echo " * Disk size of ZIPs:"
find -type f -name '*.zip' -exec du -ch {} + | grep total$
echo ""


echo "${Yellow} [Checking Git on Webcomic]${Off}"
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
          
          echo ""
          
          # entry door to batch in each webcomic directories
          cd "$projectroot"/webcomics/"$directories"
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
            
            #cd hi-res/gfx-only
            #for pngfile in $(find . -name '*.png')
            #do
            #jpgfile=$(echo $pngfile|sed 's/\(.*\)\..\+/\1/')".jpg"
            #echo " * converting $pngfile => $jpgfile"
            #convert -strip -interlace Plane -quality 95% "$pngfile" "$jpgfile"
            #echo " * done"
            #echo ""
            #done


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
    fi
  done

echo "${Yellow} [Checking Git Fonts]${Off}"
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

  
echo "${Yellow} [Checking Git Wiki]${Off}"
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


echo "${Yellow} [Checking Git www-lang]${Off}"
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

  
echo "${Yellow} [Checking Git scripts]${Off}"
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


# Template
# --------
# cd "$projectroot"/webcomic
# LOOP on all webcomic SVGs
# for svgfiles in $(find . -name '*.svg')
# do
    #if grep -q 'BADSTRINGTOREMOVE' "$svgfiles"; then
        #echo ""
        #echo "${Yellow}[AUTO FIXING] sed -i 's/BADSTRINGTOREMOVE/GOODSTRINGTOREPLACE/ $svgfiles "
        #echo "${Off}"
        #sed -i 's/BADSTRINGTOREMOVE/GOODSTRINGTOREPLACE/' $svgfiles
    #fi
# done

# Windows title
printf "\033]0;%s\007\n" "Filewalker"

echo ""
echo "$version"
echo -n "Press [Enter] to exit"
read end
