#!/bin/bash
# convert Inkscape 0.91 to 0.92.1 SVG translation format, with test and validations.
# Need full path of a SVG as input.

# Header
Off=$'\e[0m'
Red=$'\e[1;31m'
Green=$'\e[1;32m'
Blue=$'\e[1;34m'

export refactorsvglist="/home/deevad/peppercarrot/refactor/bad-svg-list.txt"
export refactorsvgpath="/home/deevad/peppercarrot/refactor"
export demotivator=0

mkdir -p "$refactorsvgpath"
mkdir -p "$refactorsvgpath"/trash

while IFS= read -r file
do
   export input=$file
   export horodate=$(date +%Y-%m-%d_%Hh%M)
   export svgpath=${input%/*}
   export svgfile=${input##*/}
   export svgpathpretty="$(echo $svgpath | sed 's/\/home\/deevad\/peppercarrot\/webcomics\///g')"
   export lang=${svgpath: -2:2}
   export giffileextension=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')"_compare.gif"
   export giffile="$lang"_"$giffileextension"
   if [ -f "$refactorsvgpath"/"$giffile" ]; then
      demotivator=$((demotivator+1))
   fi
done < "$refactorsvglist"

export remotivator=$demotivator

while IFS= read -r file
do
   export input=$file
   export horodate=$(date +%Y-%m-%d_%Hh%M)
   export svgpath=${input%/*}
   export svgfile=${input##*/}
   export svgpathpretty="$(echo $svgpath | sed 's/\/home\/deevad\/peppercarrot\/webcomics\///g')"
   export lang=${svgpath: -2:2}
   export giffileextension=$(echo $svgfile|sed 's/\(.*\)\..\+/\1/')"_compare.gif"
   export giffile="$lang"_"$giffileextension"
   
   if [ -f "$refactorsvgpath"/"$giffile" ]; then
      echo "${Green}=> ["$remotivator"/"$demotivator"] ${Off} ${Blue} $file ${Off}"
      # Request user feedback
      # =====================
      # display and ask question
      xviewer "$refactorsvgpath"/"$giffile" & (sleep 0.6 && DISPLAY=:0 wmctrl -F -a "Question" -b add,above -e 0,1300,410,-1,-1) & (DISPLAY=:0 zenity --question --title="Question" --text="Is this OK?")
      # Interpret the feedback:
      if [ $? -eq 0 ] ; then 
         echo "   Status: ${Green} SVG is ok. ${Off}"
         killall xviewer
         mv "$refactorsvgpath"/"$giffile" "$refactorsvgpath"/trash/"$giffile"
         remotivator=$((remotivator-1))
      else
         echo "   Status: ${Red} SVG is not ok. ${Off}"
         echo "   Manual fix in Inkscape necessary."
         inkscape "$file"
         echo "   Status: ${Green} SVG is fixed. ${Off}"
         killall xviewer
         mv "$refactorsvgpath"/"$giffile" "$refactorsvgpath"/trash/"$giffile"
         remotivator=$((remotivator-1))
      fi
   else
     echo " * [done] "$refactorsvgpath"/"$giffile" "
   fi
   
done < "$refactorsvglist"
exit





