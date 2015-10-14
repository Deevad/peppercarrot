#!/bin/bash

#: Title       : Pepper&Carrot Episode creator
#: Author      : David REVOY < info@davidrevoy.com >
#: License     : GPL

scriptversion="1.0b"

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


clear
echo ""
echo "   ${White}${PurpleBG}            Pepper and Carrot EPISODE CREATOR       ${Off}"
echo "   ${White}${PurpleBG}                     version 1.0                    ${Off}"
echo "   ${White}${PurpleBG}                     by David Revoy                 ${Off}"
echo ""
echo " Episode will be created in $targetfolder "
echo ""

cd $targetfolder

# class start


_GUI_questions()
{
    cd "$folder_webcomics"
    
# menu
echo -n "${Green} Enter episode number (XX, 01 to 99) to generate ${Off}"
read episodenumber
echo "${Green} Pepper&Carrot episode $episodenumber ${Off}"
echo -n "${Green} ... with how many page (1~9) ? ${Off}"
read pagemax
echo "${Green} $pagemax pages, OK. Working : ${Off}"
}


_Creation_job()
{
  cd "$folder_webcomics"
  if [ -d "$folder_webcomics"/New ]; then
       echo "${Red}==> [error] New directory already exist rename it and restart${Off}"
       exit
    else
       echo "${Blue}==> ${Yellow} generating directory :${Off} /New and /New/lang and /New/lang/fr "
       mkdir -p New/lang/fr
       cd "$folder_webcomics"/New
       
       #cover
       echo "${Blue}==> ${Yellow} generating cover     :${Off} Pepper-and-Carrot_by-David-Revoy_E"$episodenumber" "
       cp "$libpath"/cover.kra "$folder_webcomics"/New/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber".kra
       cp "$libpath"/cover.svg "$folder_webcomics"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber".svg
       sed -i 's/!XX/'$episodenumber'/g' "$folder_webcomics"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber".svg
         #autofixing SVGs
         svgfiles=Pepper-and-Carrot_by-David-Revoy_E"$episodenumber".svg
         sed -i 's/_EYY.png/'_E"$episodenumber".png'/g' "$folder_webcomics"/New/lang/fr/"$svgfiles"
       
       #header
       echo "${Blue}==> ${Yellow} generating header    :${Off} Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P00 "
       cp "$libpath"/header.kra "$folder_webcomics"/New/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P00.kra
       cp "$libpath"/header.svg "$folder_webcomics"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P00.svg
       sed -i 's/!XX/'$episodenumber'/g' "$folder_webcomics"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P00.svg
            #autofixing SVGs
            svgfiles=Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P00.svg
            sed -i 's/EYYP00/'E"$episodenumber"P00'/g' "$folder_webcomics"/New/lang/fr/"$svgfiles"
       
       #pages
       c=1
       while [ $c -le $pagemax ]
       do
         echo "${Blue}==> ${Yellow} generating pages     :${Off} Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P0"$c" "
         cp "$libpath"/page.kra "$folder_webcomics"/New/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".kra
         cp "$libpath"/page.svg "$folder_webcomics"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".svg
            #autofixing SVGs
            svgfiles=Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".svg
            sed -i 's/EYYPXX/'E"$episodenumber"P"$(printf %02d $c)"'/g' "$folder_webcomics"/New/lang/fr/"$svgfiles"
            sed -i 's/!XX/'"$(printf %02d $c)"'/g' "$folder_webcomics"/New/lang/fr/"$svgfiles"
         ((c++))
       done
       
       #credits
       echo "${Blue}==> ${Yellow} generating credits    :${Off} Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)" "
       cp "$libpath"/credit.kra "$folder_webcomics"/New/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".kra
       cp "$libpath"/credit.svg "$folder_webcomics"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".svg
          #autofixing SVGs
          svgfiles=Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".svg
          sed -i 's/EYYPXX/'E"$episodenumber"P"$(printf %02d $c)"'/g' "$folder_webcomics"/New/lang/fr/"$svgfiles"
       
       #other ( README, font, script )
       echo "${Blue}==> ${Yellow} generating others    :${Off} README.md "
       cp "$libpath"/README.md "$folder_webcomics"/New/lang/README.md
       sed -i 's/YY/'$episodenumber'/g' "$folder_webcomics"/New/lang/README.md
  fi
  
  echo ""
  echo "${Green} Done. Episode created in the 'New' folder. you can rename it. ${Off}"

}



#run
_GUI_questions
_Creation_job
  echo "==========================================================================="
  echo -n "Press [Enter] to exit"
  read end
