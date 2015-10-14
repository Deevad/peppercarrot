#!/bin/bash

#: Title       : Pepper&Carrot Episode creator
#: Author      : David REVOY < info@davidrevoy.com >
#: License     : GPL

# /!\ path to customise
# ---------------------
# scriptpath= the folder were this script is installed on your machine. 
# targetfolder= the folder where you want the new episode structure to be generated.
scriptpath="/home/deevad/Scripts/peppercarrot/scripts"
targetfolder="/home/deevad/Production/Webcomics"
# ---------------------

# auto
libpath="$scriptpath""/lib"
isodate=$(date +%Y-%m-%d)

# colors
Off=$'\e[0m'
Purple=$'\e[1;35m'
Blue=$'\e[1;34m'
Green=$'\e[1;32m'
Red=$'\e[1;31m'
Yellow=$'\e[1;33m'
White=$'\e[1;37m'
BlueBG=$'\e[1;44m'
RedBG=$'\e[1;41m'
PurpleBG=$'\e[1;45m'
Black=$'\e[1;30m'

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
    cd "$targetfolder"
    
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
  cd "$targetfolder"
  if [ -d "$targetfolder"/New ]; then
       echo "${Red}==> [error] New directory already exist rename it and restart${Off}"
       exit
    else
       echo "${Blue}==> ${Yellow} generating directory :${Off} /New and /New/lang and /New/lang/fr "
       mkdir -p New/lang/fr
       cd "$targetfolder"/New
       
       #cover
       echo "${Blue}==> ${Yellow} generating cover     :${Off} Pepper-and-Carrot_by-David-Revoy_E"$episodenumber" "
       cp "$libpath"/cover.kra "$targetfolder"/New/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber".kra
       cp "$libpath"/cover.svg "$targetfolder"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber".svg
       sed -i 's/!XX/'$episodenumber'/g' "$targetfolder"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber".svg
         #autofixing SVGs
         svgfiles=Pepper-and-Carrot_by-David-Revoy_E"$episodenumber".svg
         sed -i 's/_EYY.png/'_E"$episodenumber".png'/g' "$targetfolder"/New/lang/fr/"$svgfiles"
       
       #header
       echo "${Blue}==> ${Yellow} generating header    :${Off} Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P00 "
       cp "$libpath"/header.kra "$targetfolder"/New/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P00.kra
       cp "$libpath"/header.svg "$targetfolder"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P00.svg
       sed -i 's/!XX/'$episodenumber'/g' "$targetfolder"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P00.svg
            #autofixing SVGs
            svgfiles=Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P00.svg
            sed -i 's/EYYP00/'E"$episodenumber"P00'/g' "$targetfolder"/New/lang/fr/"$svgfiles"
       
       #pages
       c=1
       while [ $c -le $pagemax ]
       do
         echo "${Blue}==> ${Yellow} generating pages     :${Off} Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P0"$c" "
         cp "$libpath"/page.kra "$targetfolder"/New/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".kra
         cp "$libpath"/page.svg "$targetfolder"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".svg
            #autofixing SVGs
            svgfiles=Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".svg
            sed -i 's/EYYPXX/'E"$episodenumber"P"$(printf %02d $c)"'/g' "$targetfolder"/New/lang/fr/"$svgfiles"
            sed -i 's/!XX/'"$(printf %02d $c)"'/g' "$targetfolder"/New/lang/fr/"$svgfiles"
         ((c++))
       done
       
       #credits
       echo "${Blue}==> ${Yellow} generating credits    :${Off} Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)" "
       cp "$libpath"/credit.kra "$targetfolder"/New/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".kra
       cp "$libpath"/credit.svg "$targetfolder"/New/lang/fr/Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".svg
          #autofixing SVGs
          svgfiles=Pepper-and-Carrot_by-David-Revoy_E"$episodenumber"P"$(printf %02d $c)".svg
          sed -i 's/EYYPXX/'E"$episodenumber"P"$(printf %02d $c)"'/g' "$targetfolder"/New/lang/fr/"$svgfiles"
       
       #other ( README, font, script )
       echo "${Blue}==> ${Yellow} generating others    :${Off} README.md "
       cp "$libpath"/README.md "$targetfolder"/New/lang/README.md
       sed -i 's/YY/'$episodenumber'/g' "$targetfolder"/New/lang/README.md
  fi
  
  echo ""
  echo "${Green} Done. Episode created in the 'New' folder. you can rename it. ${Off}"

}



#run
_GUI_questions
_Creation_job
  echo "============================================================================================"
  echo -n "Press [Enter] to exit"
  read end
